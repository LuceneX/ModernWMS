<template>
  <div class="HomeContainer">
    <HomeSideBar />
    <div class="homeRight">
      <div class="homeRouterContainer">
        <RouterView v-slot="{ Component }">
          <keep-alive :include="openedMenus">
            <component :is="Component"></component>
          </keep-alive>
        </RouterView>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { computed } from 'vue'
import { store } from '@/store'
import HomeSideBar from './homeSideBar.vue'

const openedMenus = computed(() => store.getters['system/openedMenus'])
</script>

<style scoped lang="less">
@sideBarWidth: 272px;

.HomeContainer {
  width: 100vw;
  height: 100vh;
  display: flex;
  flex-wrap: wrap;

  .homeRight {
    width: calc(100% - @sideBarWidth);
    height: 100%;
    overflow: auto;
    background: #f5f3ef;

    .homeRouterContainer {
      min-height: 100%;
      box-sizing: border-box;
    }
  }
}
</style>
