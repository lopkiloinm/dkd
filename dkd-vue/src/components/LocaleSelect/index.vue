<template>
  <el-dropdown class="international" trigger="click" @command="handleSetLanguage">
    <div class="lang-select">
      <svg-icon icon-class="language" />
    </div>
    <template #dropdown>
      <el-dropdown-menu>
        <el-dropdown-item :disabled="language === 'zh-CN'" command="zh-CN">
          中文
        </el-dropdown-item>
        <el-dropdown-item :disabled="language === 'en-US'" command="en-US">
          English
        </el-dropdown-item>
      </el-dropdown-menu>
    </template>
  </el-dropdown>
</template>

<script setup>
import { useI18n } from 'vue-i18n'
import useLocaleStore from '@/store/modules/locale'
import { setI18nLanguage } from '@/i18n'

const { locale } = useI18n()
const localeStore = useLocaleStore()
const language = computed(() => localeStore.language)

function handleSetLanguage(lang) {
  // Update i18n locale reactively
  locale.value = lang
  setI18nLanguage(lang)
  localeStore.setLanguage(lang)
  
  // Reload page to apply locale changes
  // Element Plus locale is set on app initialization based on localStorage
  location.reload()
}
</script>

<style lang='scss' scoped>
.international {
  .lang-select {
    font-size: 18px;
    line-height: 50px;
    padding-right: 7px;
    cursor: pointer;
    color: #5a5e66;
  }
}
</style>
