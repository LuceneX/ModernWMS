<template>
  <div class="container">
    <div class="textBox">
      <div class="eyebrow">LUCENEX / WAREHOUSE OPERATIONS</div>
      <div class="mainTitle">Make the next move <em>obvious.</em></div>
      <div class="subTitle">{{ i18n.global.t('homepage.subTitle') }}</div>
    </div>
    <div class="content" aria-label="Warehouse route overview">
      <div class="warehousePanel">
        <div class="panelLabel">LIVE FLOOR SIGNAL <span>01</span></div>
        <div class="warehouseGrid"></div>
        <div class="route routeA"><i></i><i></i><i></i></div>
        <div class="route routeB"><i></i><i></i></div>
        <div class="panelFooter"><span>RECEIVE</span><span>MOVE</span><span>SHIP</span></div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import i18n from '@/languages/i18n'
</script>

<style scoped lang="less">
.container {
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: flex-start;
  position: relative;
  align-items: flex-start;
  padding: 8vh 5vw;
  box-sizing: border-box;
}
.VWMS{
  position: absolute;
  top: 0;
  display: flex;
  align-items: center;
  width: 40%;
  z-index: 999999999;
}

.content { width: 58%; min-height: 70%; display: flex; align-items: center; justify-content: center; }

.textBox {
  width: 54%;
  position: absolute;
  left: 50%;
  left: 0;
  top: 0;
  transform: none;
  letter-spacing: -.04em;
  z-index: 999;
  font-family: inherit;
}

.mainTitle {
  width: 100%;
  color: #181715;
  font-weight: bold;
  font-size: clamp(3.2rem, 6vw, 6.8rem);
  line-height: .94;
  em { color: #c65a2e; font-style: normal; }
}

.subTitle {
  display: flex;
  justify-content: flex-start;
  width: 100%;
  font-size: 1rem;
  letter-spacing: .02em;
  color: #73706b;
  margin-top: 22px;
  max-width: 34ch;
}

.warehousePanel { position: relative; width: min(650px, 90%); height: 390px; overflow: hidden; border: 1px solid #ded9d1; border-radius: 14px; background: #fff; box-shadow: 0 22px 50px rgba(24,23,21,.08); }
.panelLabel { position: absolute; top: 22px; left: 24px; z-index: 2; color: #6f6a63; font-size: .66rem; font-weight: 800; letter-spacing: .14em; }
.panelLabel span { color: #c65a2e; margin-left: 14px; }
.warehouseGrid { position: absolute; inset: 72px 24px 54px; background-image: linear-gradient(#ded9d1 1px, transparent 1px), linear-gradient(90deg, #ded9d1 1px, transparent 1px); background-size: 48px 48px; opacity: .68; }
.route { position: absolute; height: 8px; display: flex; align-items: center; gap: 76px; transform-origin: left center; }
.route::before { content: ''; position: absolute; left: 0; right: 0; height: 2px; background: #c65a2e; }
.route i { position: relative; z-index: 1; width: 9px; height: 9px; border-radius: 50%; border: 2px solid #fff; background: #c65a2e; box-shadow: 0 0 0 4px #f4ded3; }
.routeA { left: 74px; top: 190px; width: 420px; transform: rotate(-11deg); }
.routeB { left: 228px; top: 278px; width: 260px; transform: rotate(8deg); }
.panelFooter { position: absolute; left: 24px; right: 24px; bottom: 20px; display: flex; justify-content: space-between; color: #6f6a63; font-size: .64rem; font-weight: 800; letter-spacing: .12em; border-top: 1px solid #ded9d1; padding-top: 14px; }
@media (max-width: 900px) { .container { padding: 6vh 6vw; } .textBox { position: relative; width: 100%; } .content { width: 100%; min-height: 0; margin-top: 34px; } .warehousePanel { height: 300px; } }
</style>
