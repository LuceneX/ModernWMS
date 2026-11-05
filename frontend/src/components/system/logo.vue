<template>
  <div class="SysTitleLogo" :class="{ 'logoOnDark': dark }" :style="{ height: height + 'px', top: top + 'px', left: left + 'px' }">
    <span class="logoMark" aria-hidden="true"><i></i><i></i><i></i></span>
    <span class="logoWord">Lucene<span>X</span></span>
  </div>
</template>
<script setup lang="ts">
defineProps({
  height: {
    type: Number,
    default: 80
  },
  top: {
    type: Number,
    default: 20
  },
  left: {
    type: Number,
    default: 20
  },
  dark: {
    type: Boolean,
    default: false
  }
})
</script>
<style lang="less">
.SysTitleLogo {
  position: absolute;
  display: inline-flex;
  align-items: center;
  gap: 10px;
  color: #181715;
  font-size: 26px;
  font-weight: 800;
  letter-spacing: -0.06em;
  z-index: 2;
  white-space: nowrap;
  .logoMark { display: inline-flex; align-items: flex-end; gap: 3px; height: 22px; transform: skew(-14deg); i { display: block; width: 5px; background: #c65a2e; border-radius: 2px; &:nth-child(1) { height: 12px; } &:nth-child(2) { height: 18px; } &:nth-child(3) { height: 22px; } } }
  .logoWord span { color: #c65a2e; }
  &.logoOnDark { color: #fff; .logoWord span { color: #df825d; } }
}
</style>
