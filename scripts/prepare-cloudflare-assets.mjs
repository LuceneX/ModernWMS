import { cp, mkdir, rm } from 'node:fs/promises'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const repositoryRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const source = path.join(repositoryRoot, 'frontend', 'dist')
const target = path.join(repositoryRoot, 'frontend', 'cloudflare-dist')

await rm(target, { recursive: true, force: true })
await mkdir(target, { recursive: true })
await cp(source, target, {
  recursive: true,
  filter: (entry) => !entry.split(path.sep).includes('unity')
})

console.log(`Prepared Cloudflare assets in ${target}; Unity assets are deployed to R2.`)
