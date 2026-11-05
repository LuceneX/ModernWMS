<template>
  <main class="dashboard" aria-labelledby="dashboard-title">
    <section class="dashboardHero">
      <div>
        <div class="eyebrow">{{ $t('homepage.eyebrow') }}</div>
        <h1 id="dashboard-title">{{ $t('homepage.greeting', { name: userName }) }}</h1>
        <p class="heroCopy">{{ $t('homepage.subTitle') }}</p>
        <div class="contextLine">
          <span class="contextItem"><v-icon icon="mdi-account-badge-outline" size="17" />{{ roleName }}</span>
          <span class="contextItem"><v-icon icon="mdi-office-building-outline" size="17" />{{ tenantName }}</span>
          <span class="contextItem"><v-icon icon="mdi-warehouse" size="17" />{{ warehouseName }}</span>
        </div>
      </div>
      <div class="heroSignal" aria-hidden="true">
        <div class="signalLabel">{{ $t('homepage.signal') }} <strong>01</strong></div>
        <div class="signalBars"><i></i><i></i><i></i><i></i><i></i></div>
        <div class="signalRule"></div>
        <div class="signalMeta"><span>{{ $t('homepage.signalReady') }}</span><b>{{ currentTime }}</b></div>
      </div>
    </section>

    <section class="metricSection" aria-labelledby="metrics-title">
      <div class="sectionHeading">
        <div>
          <div class="eyebrow">{{ $t('homepage.overviewEyebrow') }}</div>
          <h2 id="metrics-title">{{ $t('homepage.metricsTitle') }}</h2>
        </div>
        <v-btn variant="outlined" prepend-icon="mdi-refresh" :loading="isLoading" @click="method.loadDashboard">{{ $t('homepage.refresh') }}</v-btn>
      </div>

      <div v-if="isLoading" class="metricGrid" aria-label="Loading metrics">
        <div v-for="item in 4" :key="item" class="metricCard metricSkeleton"><span></span><span></span><span></span></div>
      </div>
      <div v-else class="metricGrid">
        <article v-for="metric in metrics" :key="metric.key" class="metricCard" :class="{ 'metricCardAccent': metric.key === 'inbound' }">
          <div class="metricTopline"><v-icon :icon="metric.icon" size="19" /><span>{{ metric.label }}</span></div>
          <div class="metricValue">{{ metric.value }}</div>
          <div class="metricFootline"><span>{{ metric.detail }}</span><v-icon icon="mdi-arrow-top-right" size="16" /></div>
        </article>
      </div>
      <v-alert v-if="dashboardError" class="dashboardError" type="error" variant="tonal" density="compact">
        <div class="errorContent"><span>{{ $t('homepage.metricsError') }}</span><v-btn size="small" variant="outlined" @click="method.loadDashboard">{{ $t('homepage.retry') }}</v-btn></div>
      </v-alert>
    </section>

    <section class="lowerGrid">
      <article class="queuePanel" aria-labelledby="queue-title">
        <div class="panelHeading">
          <div>
            <div class="eyebrow">{{ $t('homepage.queueEyebrow') }}</div>
            <h2 id="queue-title">{{ $t('homepage.queueTitle') }}</h2>
          </div>
          <span class="queueState"><i></i>{{ $t('homepage.queueLive') }}</span>
        </div>
        <div class="queueSummary"><strong>{{ queueOpenCount }}</strong><span>{{ $t('homepage.queueOpen') }}</span><small>{{ $t('homepage.queueUpdated', { time: currentTime }) }}</small></div>
        <div class="queueList">
          <button v-for="item in queueItems" :key="item.key" class="queueRow" type="button" @click="method.open(item.path)">
            <span class="queueStatus" :class="`queueStatus-${item.level}`"><i></i>{{ item.status }}</span>
            <span class="queueCopy"><strong>{{ item.label }}</strong><small>{{ item.detail }}</small></span>
            <span class="queueCount">{{ item.count }}</span>
            <span class="queueOpenLink">{{ $t('homepage.openQueue') }}<v-icon icon="mdi-arrow-up-right" size="16" /></span>
          </button>
          <div v-if="!queueItems.length" class="emptyQueue"><v-icon icon="mdi-check-circle-outline" size="26" /><span>{{ $t('homepage.queueEmpty') }}</span></div>
        </div>
      </article>

      <article class="routePanel" aria-labelledby="route-title">
        <div class="panelHeading">
          <div>
            <div class="eyebrow">{{ $t('homepage.flowEyebrow') }}</div>
            <h2 id="route-title">{{ $t('homepage.flowTitle') }}</h2>
          </div>
          <span class="statusDot"><i></i>{{ $t('homepage.live') }}</span>
        </div>
        <div class="routeGraphic" aria-hidden="true">
          <div class="routeGrid"></div>
          <div class="routeLine lineOne"><i></i><i></i><i></i></div>
          <div class="routeLine lineTwo"><i></i><i></i></div>
          <div class="routeLegend"><span><b></b>{{ $t('homepage.receiving') }}</span><span><b></b>{{ $t('homepage.movement') }}</span><span><b></b>{{ $t('homepage.shipping') }}</span></div>
        </div>
        <div class="routeNote"><v-icon icon="mdi-information-outline" size="17" />{{ $t('homepage.flowNote') }}</div>
      </article>
    </section>
  </main>
</template>

<script lang="ts" setup>
import { computed, onMounted, onUnmounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { store } from '@/store'
import i18n from '@/languages/i18n'
import { getWarehouseSelect } from '@/api/base/warehouseSetting'
import { getStockAsnList } from '@/api/wms/stockAsn'
import { getNewShipment } from '@/api/wms/deliveryManagement'
import { getStockList } from '@/api/wms/stockManagement'
import { getStockMoveList } from '@/api/wms/warehouseMove'

const router = useRouter()
const isLoading = ref(true)
const dashboardError = ref(false)
const currentTime = ref(new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }))
let clockTimer: ReturnType<typeof setInterval> | undefined

const userInfo = computed(() => store.getters['user/userInfo'] || {})
const menuList = computed(() => store.getters['user/menulist'] || [])
const userName = computed(() => userInfo.value.user_name || userInfo.value.userName || userInfo.value.name || 'operator')
const roleName = computed(() => userInfo.value.role_name || userInfo.value.roleName || userInfo.value.role || i18n.global.t('homepage.operator'))
const tenantName = computed(() => userInfo.value.company_name || userInfo.value.tenant_name || userInfo.value.tenant?.name || (userInfo.value.tenant_id ? `Tenant ${userInfo.value.tenant_id}` : i18n.global.t('homepage.workspace')))
const warehouseName = ref(i18n.global.t('homepage.allWarehouses'))
const totals = reactive({ inbound: null as number | null, outbound: null as number | null, stock: null as number | null, moves: null as number | null })

const canAccess = (path: string) => menuList.value.some((item: any) => item.vue_path === path)

const metrics = computed(() => [
  { key: 'inbound', icon: 'mdi-truck-download-outline', label: i18n.global.t('homepage.inbound'), value: formatMetric(totals.inbound), detail: i18n.global.t('homepage.inboundDetail') },
  { key: 'outbound', icon: 'mdi-truck-fast-outline', label: i18n.global.t('homepage.outbound'), value: formatMetric(totals.outbound), detail: i18n.global.t('homepage.outboundDetail') },
  { key: 'stock', icon: 'mdi-package-variant-closed', label: i18n.global.t('homepage.stock'), value: formatMetric(totals.stock), detail: i18n.global.t('homepage.stockDetail') },
  { key: 'moves', icon: 'mdi-swap-horizontal', label: i18n.global.t('homepage.moves'), value: formatMetric(totals.moves), detail: i18n.global.t('homepage.movesDetail') }
])

const queueItems = computed(() => {
  const items = [] as any[]
  if (canAccess('stockAsn')) items.push({ key: 'receiving', path: 'stockAsn', level: (totals.inbound || 0) > 0 ? 'attention' : 'clear', status: (totals.inbound || 0) > 0 ? i18n.global.t('homepage.queueAttention') : i18n.global.t('homepage.queueClear'), label: i18n.global.t('homepage.queueReceiving'), detail: i18n.global.t('homepage.queueReceivingDetail'), count: formatMetric(totals.inbound) })
  if (canAccess('deliveryManagement')) items.push({ key: 'shipping', path: 'deliveryManagement', level: (totals.outbound || 0) > 0 ? 'attention' : 'clear', status: (totals.outbound || 0) > 0 ? i18n.global.t('homepage.queueAttention') : i18n.global.t('homepage.queueClear'), label: i18n.global.t('homepage.queueShipping'), detail: i18n.global.t('homepage.queueShippingDetail'), count: formatMetric(totals.outbound) })
  if (canAccess('warehouseMove')) items.push({ key: 'moves', path: 'warehouseMove', level: (totals.moves || 0) > 0 ? 'attention' : 'clear', status: (totals.moves || 0) > 0 ? i18n.global.t('homepage.queueAttention') : i18n.global.t('homepage.queueClear'), label: i18n.global.t('homepage.queueMoves'), detail: i18n.global.t('homepage.queueMovesDetail'), count: formatMetric(totals.moves) })
  return items
})
const queueOpenCount = computed(() => queueItems.value.reduce((sum, item) => sum + (Number.isFinite(Number(item.count)) ? Number(item.count) : 0), 0).toLocaleString())

function formatMetric(value: number | null) { return value === null ? '—' : value.toLocaleString() }

async function readTotal(request: Promise<any>) {
  try {
    const response = await request
    const result = response?.data
    if (!result?.isSuccess) return null
    return Number(result.data?.totals ?? result.data?.total ?? 0)
  } catch { return null }
}

const method = {
  loadDashboard: async () => {
    isLoading.value = true
    dashboardError.value = false
    const requests: Promise<number | null>[] = []
    if (canAccess('stockAsn')) requests.push(readTotal(getStockAsnList({ pageIndex: 1, pageSize: 1, sqlTitle: 'asn_status:0' })).then((value) => { totals.inbound = value; return value }))
    if (canAccess('deliveryManagement')) requests.push(readTotal(getNewShipment({ pageIndex: 1, pageSize: 1 })).then((value) => { totals.outbound = value; return value }))
    if (canAccess('stockManagement')) requests.push(readTotal(getStockList({ pageIndex: 1, pageSize: 1 })).then((value) => { totals.stock = value; return value }))
    if (canAccess('warehouseMove')) requests.push(readTotal(getStockMoveList({ pageIndex: 1, pageSize: 1, sqlTitle: 'move_status:0' })).then((value) => { totals.moves = value; return value }))
    if (canAccess('warehouseSetting')) {
      try {
        const response = await getWarehouseSelect()
        const result = response?.data
        if (result?.isSuccess && Array.isArray(result.data) && result.data.length) warehouseName.value = result.data[0].warehouse_name || warehouseName.value
      } catch { /* global API error surface handles service failures */ }
    }
    const values = await Promise.all(requests)
    dashboardError.value = values.length > 0 && values.every((value) => value === null)
    isLoading.value = false
  },
  open: (path: string) => router.push(path)
}

onMounted(() => {
  method.loadDashboard()
  clockTimer = setInterval(() => { currentTime.value = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) }, 60000)
})
onUnmounted(() => { if (clockTimer) clearInterval(clockTimer) })
</script>

<style scoped lang="less">
.dashboard { min-height: 100%; padding: clamp(28px, 4vw, 64px) clamp(18px, 3vw, 44px) 56px; color: #181715; }
.eyebrow { color: #c65a2e; font-size: .68rem; font-weight: 800; letter-spacing: .16em; text-transform: uppercase; }
.dashboardHero { display: flex; align-items: flex-end; justify-content: space-between; gap: 32px; padding-bottom: 42px; border-bottom: 1px solid #ded9d1; }
h1 { margin: 13px 0; max-width: 760px; font-size: clamp(2.55rem, 5vw, 5.25rem); line-height: .95; letter-spacing: -.075em; font-weight: 800; }
.heroCopy { max-width: 58ch; margin: 0; color: #6f6a63; font-size: 1rem; line-height: 1.65; }
.contextLine { display: flex; flex-wrap: wrap; gap: 10px 20px; margin-top: 24px; color: #6f6a63; font-size: .78rem; }.contextItem { display: inline-flex; align-items: center; gap: 7px; }.contextItem .v-icon { color: #c65a2e; }
.heroSignal { width: min(260px, 28%); padding: 22px 0 0 26px; border-left: 1px solid #ded9d1; }.signalLabel, .signalMeta { display: flex; justify-content: space-between; color: #6f6a63; font-size: .65rem; font-weight: 800; letter-spacing: .12em; text-transform: uppercase; }.signalLabel strong { color: #c65a2e; }.signalBars { display: flex; align-items: flex-end; gap: 5px; height: 72px; margin: 16px 0 14px; }.signalBars i { width: 8px; background: #c65a2e; border-radius: 2px 2px 0 0; }.signalBars i:nth-child(1) { height: 25%; opacity: .2; }.signalBars i:nth-child(2) { height: 46%; opacity: .38; }.signalBars i:nth-child(3) { height: 70%; opacity: .58; }.signalBars i:nth-child(4) { height: 88%; opacity: .78; }.signalBars i:nth-child(5) { height: 100%; }.signalRule { height: 1px; background: #ded9d1; margin-bottom: 12px; }.signalMeta b { color: #181715; letter-spacing: .06em; }
.metricSection { padding: 40px 0; }.sectionHeading, .panelHeading { display: flex; justify-content: space-between; align-items: flex-end; gap: 16px; }h2 { margin: 7px 0 0; font-size: 1.3rem; letter-spacing: -.03em; }.metricGrid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 12px; margin-top: 18px; }.metricCard { min-height: 152px; padding: 19px 20px 16px; border: 1px solid #ded9d1; border-radius: 14px; background: #fff; display: flex; flex-direction: column; justify-content: space-between; transition: transform .2s ease, border-color .2s ease, box-shadow .2s ease; }.metricCard:hover { transform: translateY(-2px); border-color: #c65a2e; box-shadow: 0 12px 24px rgba(24,23,21,.08); }.metricCardAccent { border-top: 3px solid #c65a2e; }.metricTopline, .metricFootline { display: flex; align-items: center; justify-content: space-between; gap: 10px; color: #6f6a63; font-size: .7rem; font-weight: 800; letter-spacing: .1em; text-transform: uppercase; }.metricTopline .v-icon { color: #c65a2e; }.metricValue { margin: 11px 0; font-size: 2.35rem; font-weight: 800; letter-spacing: -.07em; }.metricFootline { font-size: .72rem; font-weight: 500; letter-spacing: 0; text-transform: none; }.metricFootline .v-icon { color: #c65a2e; }.metricSkeleton { gap: 12px; }.metricSkeleton span { display: block; height: 14px; border-radius: 4px; background: linear-gradient(90deg, #f5f3ef 25%, #ebe6df 50%, #f5f3ef 75%); background-size: 200% 100%; animation: loading 1.2s infinite; }.metricSkeleton span:nth-child(2) { width: 50%; height: 39px; }.metricSkeleton span:nth-child(3) { width: 75%; }.dashboardError { margin-top: 14px; }.errorContent { display: flex; align-items: center; justify-content: space-between; gap: 14px; }
.lowerGrid { display: grid; grid-template-columns: minmax(0, 1.05fr) minmax(0, .95fr); gap: 16px; }.queuePanel, .routePanel { min-height: 340px; padding: 24px; border: 1px solid #ded9d1; border-radius: 14px; background: #fff; }.queuePanel { background: #181715; color: #fff; border-color: #181715; }.queuePanel .eyebrow { color: #df825d; }.routePanel .panelHeading { margin-bottom: 24px; }.queueState { display: inline-flex; align-items: center; gap: 7px; color: #aaa39a; font-size: .66rem; font-weight: 800; letter-spacing: .12em; text-transform: uppercase; }.queueState i { width: 7px; height: 7px; border-radius: 50%; background: #c65a2e; box-shadow: 0 0 0 4px rgba(198,90,46,.16); }.queueSummary { display: grid; grid-template-columns: auto 1fr; align-items: baseline; column-gap: 10px; margin: 24px 0 15px; padding-bottom: 16px; border-bottom: 1px solid rgba(255,255,255,.14); }.queueSummary strong { font-size: 2.8rem; line-height: .9; letter-spacing: -.08em; color: #fff; }.queueSummary span { color: #df825d; font-size: .8rem; font-weight: 800; letter-spacing: .08em; text-transform: uppercase; }.queueSummary small { grid-column: 2; color: #8d887f; font-size: .72rem; }.queueList { display: grid; }.queueRow { width: 100%; display: grid; grid-template-columns: 80px 1fr auto; grid-template-rows: auto auto; align-items: center; column-gap: 12px; row-gap: 4px; padding: 14px 0; border: 0; border-bottom: 1px solid rgba(255,255,255,.14); color: #fff; background: transparent; text-align: left; cursor: pointer; transition: padding .2s ease, background .2s ease; }.queueRow:hover { padding-left: 8px; background: rgba(255,255,255,.035); }.queueStatus { grid-row: 1 / span 2; display: inline-flex; align-items: center; gap: 6px; align-self: start; padding-top: 2px; color: #aaa39a; font-size: .61rem; font-weight: 800; letter-spacing: .08em; text-transform: uppercase; }.queueStatus i { width: 6px; height: 6px; border-radius: 50%; background: #8d887f; }.queueStatus-attention { color: #df825d; }.queueStatus-attention i { background: #c65a2e; }.queueCopy { display: grid; gap: 3px; }.queueCopy strong { font-size: .85rem; }.queueCopy small { color: #aaa39a; font-size: .72rem; }.queueCount { grid-column: 3; grid-row: 1 / span 2; font-size: 1.45rem; font-weight: 800; letter-spacing: -.06em; }.queueOpenLink { grid-column: 2; display: inline-flex; align-items: center; gap: 5px; color: #df825d; font-size: .7rem; font-weight: 700; opacity: 0; transition: opacity .2s ease; }.queueRow:hover .queueOpenLink { opacity: 1; }.emptyQueue { display: flex; gap: 10px; align-items: center; color: #aaa39a; padding: 28px 0; }.emptyQueue .v-icon { color: #df825d; }
.statusDot { display: inline-flex; align-items: center; gap: 7px; color: #6f6a63; font-size: .68rem; font-weight: 800; letter-spacing: .12em; text-transform: uppercase; }.statusDot i { width: 7px; height: 7px; border-radius: 50%; background: #c65a2e; box-shadow: 0 0 0 4px #f4ded3; }.routeGraphic { position: relative; height: 206px; overflow: hidden; border: 1px solid #ded9d1; border-radius: 10px; background: #f5f3ef; }.routeGrid { position: absolute; inset: 0; background-image: linear-gradient(#ded9d1 1px, transparent 1px), linear-gradient(90deg, #ded9d1 1px, transparent 1px); background-size: 34px 34px; opacity: .6; }.routeLine { position: absolute; height: 8px; display: flex; align-items: center; gap: 48px; }.routeLine::before { content: ''; position: absolute; left: 0; right: 0; height: 2px; background: #c65a2e; }.routeLine i { position: relative; z-index: 1; width: 8px; height: 8px; border: 2px solid #fff; border-radius: 50%; background: #c65a2e; box-shadow: 0 0 0 4px #f4ded3; }.lineOne { top: 76px; left: 42px; width: 280px; transform: rotate(-10deg); }.lineTwo { top: 130px; left: 155px; width: 190px; transform: rotate(9deg); }.routeLegend { position: absolute; right: 14px; bottom: 12px; display: grid; gap: 5px; color: #6f6a63; font-size: .63rem; }.routeLegend span { display: inline-flex; align-items: center; gap: 6px; }.routeLegend b { width: 6px; height: 6px; border-radius: 50%; background: #c65a2e; }.routeNote { display: flex; gap: 8px; align-items: center; margin-top: 17px; color: #6f6a63; font-size: .78rem; line-height: 1.45; }.routeNote .v-icon { color: #c65a2e; }
@keyframes loading { to { background-position: -200% 0; } }@media (max-width: 1050px) { .metricGrid { grid-template-columns: repeat(2, minmax(0, 1fr)); }.lowerGrid { grid-template-columns: 1fr; } }@media (max-width: 720px) { .dashboardHero { display: block; }.heroSignal { width: auto; margin-top: 28px; padding: 18px 0 0; border-left: 0; border-top: 1px solid #ded9d1; }.metricGrid { grid-template-columns: 1fr 1fr; }.sectionHeading { align-items: flex-start; }.sectionHeading .v-btn { min-width: 0; }.metricCard { min-height: 140px; padding: 16px; }.metricValue { font-size: 2rem; }.queuePanel, .routePanel { padding: 19px; }.queueRow { grid-template-columns: 70px 1fr auto; } }@media (max-width: 480px) { .metricGrid { grid-template-columns: 1fr; }.lowerGrid { gap: 12px; }.queuePanel, .routePanel { padding: 19px; }.contextLine { display: grid; gap: 8px; } }
</style>
