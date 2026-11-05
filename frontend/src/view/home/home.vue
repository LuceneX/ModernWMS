<template>
  <div class="HomeContainer">
    <HomeSideBar />
    <div class="homeRight">
      <HomeHeader />
      <div class="homeRouterContainer pt-2">
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
import HomeHeader from './homeHeader.vue'
import HomeSideBar from './homeSideBar.vue'

const openedMenus = computed(() => store.getters['system/openedMenus'])
</script>

<style scoped lang="less">
@headerHeight: 72px;
@sideBarWidth: 272px;
@sideBarTitleHeight: 80px;

.HomeContainer {
  width: 100vw;
  height: 100vh;
  display: flex;
  flex-wrap: wrap;

  .homeRight {
    width: calc(100% - @sideBarWidth);
    padding: 0 3.5%;
    background: #f5f3ef;

    .homeRouterContainer {
      height: calc(100% - @headerHeight);
      box-sizing: border-box;
    }
  }
}
</style>
