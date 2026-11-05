<template>
  <div class="loginContainer">
    <Logo dark />
    <div class="loginLeft">
      <div class="leftCopy">
        <div class="eyebrow">LUCENEX / WAREHOUSE SYSTEMS</div>
        <h1>Make the next move<br /><em>obvious.</em></h1>
        <p>One operational view for stock, movement, and the people keeping goods in motion.</p>
        <div class="signalRow"><span></span><span></span><span></span><span></span><b>LIVE FLOOR SIGNAL</b></div>
      </div>
      <div class="warehouseVisual" aria-hidden="true">
        <div class="gridFloor"></div>
        <div class="rack rackOne"><i></i><i></i><i></i><i></i></div>
        <div class="rack rackTwo"><i></i><i></i><i></i></div>
        <div class="routeLine"></div>
        <div class="routeNode nodeOne"></div><div class="routeNode nodeTwo"></div>
      </div>
    </div>
    <div class="loginRight">
      <div class="LanguagesSwitchContainer">
        <LanguagesSwitch />
      </div>
      <LoginForm />
    </div>

    <RouterLink class="licensesLink" to="/licenses">Licenses</RouterLink>
  </div>
</template>

<script lang="ts" setup>
import { onMounted } from 'vue'
import LoginForm from '@/components/login/login-form.vue'
import LanguagesSwitch from '@/components/system/languages.vue'
import Logo from '@/components/system/logo.vue'
import { emitter } from '@/utils/bus'

// Return to the login interface to clear the status
onMounted(() => {
  emitter.emit('closeLoading')
})
</script>

<style scoped lang="less">
.LanguagesSwitchContainer {
  position: absolute;
  right: 10px;
  top: 10px;
}
.loginContainer {
  width: 100%;
  height: 100%;
  display: flex;
  background-color: #f5f3ef;
  // position: relative;
  .loginLeft {
    width: 68%;
    min-height: 100%;
    position: relative;
    overflow: hidden;
    background: #181715;
    color: #fff;
    padding: 12vh 8vw;
    box-sizing: border-box;
    align-items: flex-start;
    justify-content: flex-start;
    flex-direction: column;
    &::before { content: ''; position: absolute; inset: 0; background: radial-gradient(circle at 80% 12%, rgba(198,90,46,.28), transparent 30%), linear-gradient(135deg, rgba(255,255,255,.02), transparent 45%); pointer-events: none; }
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .loginRight {
    width: 32%;
    min-width: 360px;
    background-color: #fff;
    display: flex;
    align-items: center;
  }
}

.leftCopy { position: relative; z-index: 1; max-width: 620px; }
.leftCopy .eyebrow { color: #df825d; font-size: .68rem; font-weight: 800; letter-spacing: .18em; }
.leftCopy h1 { margin: 18px 0 20px; font-size: clamp(3.5rem, 6vw, 6.8rem); line-height: .92; letter-spacing: -.08em; font-weight: 800; }
.leftCopy h1 em { color: #df825d; font-style: normal; }
.leftCopy p { max-width: 34ch; color: #aaa39a; font-size: 1.05rem; line-height: 1.55; }
.warehouseVisual { position: absolute; width: min(70%, 820px); height: 48%; right: -2%; bottom: 2%; opacity: .78; transform: perspective(600px) rotateX(54deg) rotateZ(-8deg); transform-origin: center bottom; }
.gridFloor { position: absolute; inset: 8% 0 0; background-image: linear-gradient(rgba(198,90,46,.24) 1px, transparent 1px), linear-gradient(90deg, rgba(198,90,46,.24) 1px, transparent 1px); background-size: 42px 42px; mask-image: linear-gradient(to top, #000, transparent 78%); }
.rack { position: absolute; bottom: 23%; display: flex; align-items: flex-end; gap: 16px; padding: 14px; border: 2px solid rgba(255,255,255,.25); border-bottom-color: #c65a2e; transform: skewY(-5deg); background: linear-gradient(90deg, rgba(255,255,255,.04), transparent); }
.rack i { display: block; width: 58px; height: 34px; border: 1px solid rgba(223,130,93,.8); background: rgba(198,90,46,.22); box-shadow: inset 0 -8px rgba(198,90,46,.14); }
.rackOne { right: 14%; height: 170px; }.rackTwo { right: 48%; height: 120px; transform: skewY(3deg) scale(.82); opacity: .7; }
.routeLine { position: absolute; right: 7%; bottom: 17%; width: 68%; height: 2px; background: linear-gradient(90deg, transparent, #df825d 15%, #df825d 86%, transparent); transform: rotate(-12deg); box-shadow: 0 0 18px rgba(223,130,93,.8); }
.routeNode { position: absolute; width: 12px; height: 12px; border: 2px solid #fff; background: #c65a2e; border-radius: 50%; box-shadow: 0 0 0 6px rgba(198,90,46,.2); }.nodeOne { right: 68%; bottom: 24%; }.nodeTwo { right: 16%; bottom: 35%; }
.signalRow { display: flex; align-items: center; gap: 5px; margin-top: 52px; color: #89847c; font-size: .62rem; letter-spacing: .14em; font-weight: 800; }
.signalRow span { width: 7px; height: 7px; border-radius: 50%; background: #c65a2e; box-shadow: 0 0 0 5px rgba(198,90,46,.12); }
.signalRow span:nth-child(2) { opacity: .7; }.signalRow span:nth-child(3) { opacity: .45; }.signalRow span:nth-child(4) { opacity: .2; }.signalRow b { margin-left: 12px; font-weight: 800; }

.licensesLink {
  color: #73706b;
  font-size: 12px;
  position: absolute;
  bottom: 24px;
  right: 28px;
  text-decoration: none;

  &:hover {
    color: #c65a2e;
    text-decoration: underline;
  }
}

@media (max-width: 900px) {
  .loginContainer .loginLeft { width: 52%; padding: 12vh 5vw; }
  .loginContainer .loginRight { width: 48%; min-width: 0; }
  .leftCopy h1 { font-size: clamp(3rem, 7vw, 5rem); }
  .warehouseVisual { width: 100%; right: -25%; }
}
@media (max-width: 640px) {
  .loginContainer { overflow: auto; min-height: 100%; }
  .loginContainer .loginLeft { display: none; }
  .loginContainer .loginRight { width: 100%; min-height: 100vh; }
}
</style>
