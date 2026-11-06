import { DurableObject } from 'cloudflare:workers'

export class ModernWMSContainer extends DurableObject<Env> {
  private starting: Promise<void> | undefined

  private async startAndWaitForPort(): Promise<void> {
    const container = this.ctx.container!
    if (!container.running) {
      container.start({ instance: 'lite', enableInternet: false })
    }

    const port = container.getTcpPort(5555)
    let lastError: unknown
    for (let attempt = 0; attempt < 60; attempt += 1) {
      try {
        const response = await port.fetch('http://container/')
        await response.body?.cancel()
        return
      } catch (error) {
        lastError = error
        await scheduler.wait(500)
      }
    }
    throw new Error('ModernWMS backend container did not become ready', { cause: lastError })
  }

  override async fetch(request: Request): Promise<Response> {
    this.starting ??= this.startAndWaitForPort().finally(() => {
      this.starting = undefined
    })
    await this.starting

    const url = new URL(request.url)
    url.protocol = 'http:'
    url.host = 'container'
    const forwarded = new Request(url, request)
    forwarded.headers.delete('host')
    return this.ctx.container!.getTcpPort(5555).fetch(forwarded)
  }
}

async function unityAsset(request: Request, env: Env): Promise<Response> {
  const url = new URL(request.url)
  const key = url.pathname.replace(/^\//, '')
  const object = await env.UNITY_ASSETS.get(key)

  if (!object) {
    return new Response('Unity asset not found', { status: 404 })
  }

  const headers = new Headers()
  object.writeHttpMetadata(headers)
  headers.set('etag', object.httpEtag)
  return new Response(object.body, { headers })
}

function backendRequest(request: Request, env: Env): Promise<Response> {
  const incoming = new URL(request.url)
  const backendPath = incoming.pathname.replace(/^\/api(?=\/|$)/, '') || '/'
  const backendUrl = new URL(backendPath + incoming.search, 'https://modernwms-backend.internal')
  const backendRequest = new Request(backendUrl, request)
  return env.MODERNWMS_CONTAINER.getByName('production').fetch(backendRequest)
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url)

    if (url.pathname.startsWith('/unity/')) {
      return unityAsset(request, env)
    }

    if (url.pathname === '/api' || url.pathname.startsWith('/api/')) {
      console.log(JSON.stringify({ message: 'Proxying API request', method: request.method, path: url.pathname }))
      try {
        return await backendRequest(request, env)
      } catch (error) {
        console.error(JSON.stringify({
          message: 'Backend proxy failed',
          method: request.method,
          path: url.pathname,
          error: error instanceof Error ? error.message : String(error)
        }))
        return Response.json({ message: 'Backend unavailable', code: 'backend_unavailable' }, { status: 503 })
      }
    }

    return env.ASSETS.fetch(request)
  }
} satisfies ExportedHandler<Env>
