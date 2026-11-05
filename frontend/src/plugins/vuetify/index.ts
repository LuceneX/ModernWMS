// Vuetify
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import { aliases, mdi } from 'vuetify/iconsets/mdi'
// Translations provided by Vuetify
import { en } from 'vuetify/locale'
import { getSelcectedLangForVuetify } from './method/index'

import 'material-design-icons-iconfont/dist/material-design-icons.css'
import 'vuetify/dist/vuetify.min.css'
import '@mdi/font/css/materialdesignicons.css'

const vuetify = createVuetify({
  theme: {
    defaultTheme: 'lucenex',
    themes: {
      lucenex: {
        dark: false,
        colors: {
          primary: '#C65A2E',
          secondary: '#181715',
          background: '#F5F3EF',
          surface: '#FFFFFF',
          'surface-variant': '#F4DED3',
          error: '#B42318',
          success: '#C65A2E',
          warning: '#C65A2E',
          info: '#6F6A63',
          'on-primary': '#FFFFFF',
          'on-secondary': '#FFFFFF'
        }
      }
    }
  },
  locale: {
    locale: getStorageLang(),
    messages: { en }
  },
  components,
  directives,
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: {
      mdi
    }
  }
})

// get language in storage or default
function getStorageLang() {
  const lang = localStorage.getItem('language')
  if (lang) {
    return getSelcectedLangForVuetify(lang)
  }
  return 'en'
}

export { vuetify }
