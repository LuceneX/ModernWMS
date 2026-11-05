// Get different languages according to the key
import enUS from 'vxe-table/lib/locale/lang/en-US'
import { store } from '@/store'
import i18n from '../i18n'

import en from '../langsJson/en.json'
import lv from '../langsJson/lv.json'

export function getSelectedLang(lang: string) {
  switch (lang) {
    case 'en':
      return 'en_US'
    case 'lv':
      return 'lv_LV'
    default:
      return 'en_US'
  }
}

// Obtain default language pack based on language
export function getLangPackage(lang: string) {
  const result = { lv_LV: {}, en_US: {} }
  switch (lang) {
    case 'lv_LV':
      result.lv_LV = { ...en, ...lv, ...enUS }
      break
    case 'en_US':
    default:
      result.en_US = { ...en, ...enUS }
      break
  }
  return result
}

// Because it is lazy to load the language pack, the user will reload the language pack after switching languages
export function installNewLang() {
  let lang = store.getters['system/language']
  lang = getSelectedLang(lang)
  const messages = getLangPackage(lang)
  if (lang && messages) {
    // Use setLocaleMessage to add or update language packs
    i18n.global.setLocaleMessage(lang, messages[lang])
    return
  }
  // Default English
  i18n.global.setLocaleMessage('en_US', { ...en, ...enUS })
}
