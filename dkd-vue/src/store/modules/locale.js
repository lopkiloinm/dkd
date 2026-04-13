const useLocaleStore = defineStore(
  'locale',
  {
    state: () => ({
      language: localStorage.getItem('language') || 'zh-CN'
    }),
    actions: {
      setLanguage(language) {
        this.language = language
        localStorage.setItem('language', language)
      }
    }
  }
)

export default useLocaleStore
