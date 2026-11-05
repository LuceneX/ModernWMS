<template>
  <div class="appViewContainer">
    <v-alert v-if="apiFailure" class="apiFailureBanner" type="error" variant="tonal" closable @click:close="apiFailure = ''">
      <div class="apiFailureContent">
        <span>{{ apiFailure }}</span>
        <v-btn size="small" variant="outlined" @click="method.retryView">Retry</v-btn>
      </div>
    </v-alert>
    <v-dialog v-model="loadingFlag" :scrim="false" persistent max-width="200">
      <v-card class="appLoadingCard">
        <v-card-text>
          <div class="loadingEyebrow">LUCENEX / OPERATIONS</div>
          <div class="loadingLabel">Loading workspace</div>
          <v-progress-linear indeterminate color="primary"></v-progress-linear>
        </v-card-text>
      </v-card>
    </v-dialog>
    <div v-show="loadingFlag" class="mask"></div>
    <router-view v-if="data.isShow"></router-view>
  </div>
</template>

<script setup lang="ts">
import { reactive, nextTick, onMounted, ref, computed, watch } from 'vue'
import { emitter } from './utils/bus'
import { store } from './store'
import { installNewLang } from '@/languages/method/index'

const loadingFlag = ref(false)
const apiFailure = ref('')

const data = reactive({
  isShow: true // Used to refresh the interface when switching languages
})

const method = reactive({
  refreshSystem: () => {
    data.isShow = false
    installNewLang()
    nextTick(() => {
      data.isShow = true
      store.commit('system/setRefreshFlag', false)
    })
  },
  getClientSize: () => {
    const clientHeight = document.documentElement.clientHeight
    const clientWidth = document.documentElement.clientWidth
    store.commit('system/setClientHeight', clientHeight)
    store.commit('system/setClientWidth', clientWidth)
  },
  retryView: () => window.location.reload()
})

const refreshFlag = computed(() => store.getters['system/refreshFlag'])

watch(
  () => refreshFlag.value,
  (flag) => {
    if (flag) {
      method.refreshSystem()
    }
  }
)

onMounted(() => {
  emitter.on('showLoading', () => {
    loadingFlag.value = true
  })
  emitter.on('closeLoading', () => {
    loadingFlag.value = false
  })
  emitter.on('apiFailure', (message) => {
    apiFailure.value = String(message)
  })

  method.getClientSize()

  window.onresize = function () {
    method.getClientSize()
  }
})
</script>

<style scoped>
.appViewContainer {
  height: 100%;
  width: 100%;
  background-color: #f5f3ef;
}

.mask {
  position: absolute;
  z-index: 9999;
  width: 100vw;
  height: 100vh;
}

.appLoadingCard { background: #fff !important; border: 1px solid #ded9d1; border-radius: 14px !important; box-shadow: 0 16px 40px rgba(24, 23, 21, .12) !important; }
.apiFailureBanner { position: fixed; z-index: 10000; top: 16px; left: 50%; transform: translateX(-50%); width: min(680px, calc(100vw - 32px)); border: 1px solid rgba(180, 35, 24, .24); box-shadow: 0 12px 30px rgba(24, 23, 21, .12); }
.apiFailureContent { display: flex; align-items: center; justify-content: space-between; gap: 18px; }
.loadingEyebrow { color: #c65a2e; font-size: .68rem; font-weight: 800; letter-spacing: .16em; margin-bottom: 8px; }
.loadingLabel { color: #181715; font-weight: 700; margin-bottom: 14px; }
</style>
