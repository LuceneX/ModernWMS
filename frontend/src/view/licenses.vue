<template>
  <main class="licensesPage">
    <header class="licensesHeader">
      <RouterLink class="brand" to="/login"><span class="brandMark"><i></i><i></i><i></i></span>Lucene<span>X</span></RouterLink>
      <RouterLink class="backLink" to="/login">Back to sign in</RouterLink>
    </header>
    <section class="licensesContent">
      <div class="eyebrow">LUCENEX / LEGAL</div>
      <h1>Licenses &amp; acknowledgements</h1>
      <p class="intro">LuceneX Warehouse Operations is built with open-source software. We are grateful to the maintainers whose work makes this product possible.</p>
      <div class="licenseBlock">
        <h2>Application</h2>
        <p>LuceneX Warehouse Operations · © LuceneX SIA. All rights reserved.</p>
      </div>
      <div class="licenseBlock">
        <h2>Third-party software</h2>
        <ul>
          <li><a href="https://vuejs.org/" target="_blank" rel="noreferrer">Vue</a> · MIT License</li>
          <li><a href="https://vuetifyjs.com/" target="_blank" rel="noreferrer">Vuetify</a> · MIT License</li>
          <li><a href="https://vitejs.dev/" target="_blank" rel="noreferrer">Vite</a> · MIT License</li>
          <li><a href="https://www.typescriptlang.org/" target="_blank" rel="noreferrer">TypeScript</a> · Apache License 2.0</li>
          <li><a href="https://github.com/intlify/vue-i18n" target="_blank" rel="noreferrer">Vue I18n</a> · MIT License</li>
          <li><a href="https://github.com/airbnb/javascript" target="_blank" rel="noreferrer">Airbnb JavaScript Style Guide</a> · MIT License</li>
        </ul>
      </div>
      <p class="note">For the complete dependency manifest and exact license text, see the project’s package metadata and lockfiles.</p>
    </section>
  </main>
</template>

<style scoped lang="less">
.licensesPage { min-height: 100vh; background: #f5f3ef; color: #181715; }
.licensesHeader { height: 78px; padding: 0 6vw; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #ded9d1; }
.brand { color: #181715; font-size: 24px; font-weight: 800; letter-spacing: -.06em; text-decoration: none; display: flex; align-items: center; gap: 9px; }.brand span:last-child { color: #c65a2e; }
.brandMark { display: inline-flex; align-items: end; gap: 3px; height: 20px; transform: skew(-12deg); }.brandMark i { width: 5px; background: #c65a2e; border-radius: 2px; }.brandMark i:nth-child(1) { height: 11px; }.brandMark i:nth-child(2) { height: 16px; }.brandMark i:nth-child(3) { height: 20px; background: #df825d; }
.backLink { color: #6f6a63; font-size: 13px; text-decoration: none; }.backLink:hover { color: #c65a2e; }
.licensesContent { max-width: 780px; padding: 12vh 6vw; }.eyebrow { color: #c65a2e; font-size: 11px; font-weight: 800; letter-spacing: .16em; }h1 { font-size: clamp(2.8rem, 6vw, 5.4rem); line-height: .95; letter-spacing: -.07em; max-width: 11ch; margin: 18px 0 26px; }.intro { max-width: 55ch; color: #6f6a63; line-height: 1.65; }.licenseBlock { border-top: 1px solid #ded9d1; padding: 24px 0; margin-top: 32px; }.licenseBlock h2 { font-size: 1rem; margin: 0 0 12px; }.licenseBlock p, li { color: #6f6a63; line-height: 1.7; }.licenseBlock ul { list-style: none; padding: 0; margin: 0; }.licenseBlock li::before { content: '↗'; color: #c65a2e; margin-right: 10px; }.licenseBlock a { color: #181715; text-underline-offset: 3px; }.note { color: #8a847c; font-size: .82rem; margin-top: 28px; }
</style>
