<template>
  <el-breadcrumb class="app-breadcrumb" separator="/">
    <transition-group name="breadcrumb">
      <el-breadcrumb-item v-for="(item,index) in levelList" :key="item.path">
        <span v-if="item.redirect === 'noRedirect' || index == levelList.length - 1" class="no-redirect">{{ translateTitle(item.meta.title) }}</span>
        <a v-else @click.prevent="handleLink(item)">{{ translateTitle(item.meta.title) }}</a>
      </el-breadcrumb-item>
    </transition-group>
  </el-breadcrumb>
</template>

<script setup>
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const route = useRoute();
const router = useRouter();
const levelList = ref([])

// Map Chinese menu titles to i18n keys
const menuTitleMap = {
  '首页': 'route.home',
  '点位管理': 'business.pointManagement',
  '区域管理': 'business.areaManagement',
  '合作商管理': 'business.partnerManagement',
  '设备管理': 'business.deviceManagement',
  '设备类型管理': 'vmType.title',
  '人员管理': 'business.personnelManagement',
  '人员列表': 'emp.personnelList',
  '系统管理': 'system.title',
  '系统监控': 'monitor.title',
  '系统工具': 'tool.title',
  '若依官网': 'route.officialWebsite',
  '用户管理': 'user.title',
  '角色管理': 'role.title',
  '菜单管理': 'menu.title',
  '部门管理': 'dept.title',
  '岗位管理': 'post.title',
  '字典管理': 'dict.title',
  '参数设置': 'config.title',
  '通知公告': 'notice.title',
  '日志管理': 'system.logManagement',
  '在线用户': 'monitor.onlineUsers',
  '定时任务': 'monitor.scheduledTasks',
  '调度日志': 'monitor.scheduledLog',
  '服务监控': 'monitor.serverMonitor',
  '数据监控': 'monitor.dataMonitor',
  '缓存监控': 'monitor.cacheMonitor',
  '缓存列表': 'monitor.cacheList',
  '表单构建': 'tool.formBuild',
  '代码生成': 'tool.codeGeneration',
  '系统接口': 'tool.swaggerDoc',
  '操作日志': 'system.operationLog',
  '登录日志': 'system.loginLog'
}

function translateTitle(title) {
  if (!title) return ''
  // If it's already an i18n key (contains dots), use it directly
  if (title.includes('.')) return t(title) || title
  // Otherwise, check if it's in the Chinese title map
  const i18nKey = menuTitleMap[title]
  if (i18nKey) return t(i18nKey)
  // Fall back to original title
  return title
}

function getBreadcrumb() {
  // only show routes with meta.title
  let matched = route.matched.filter(item => item.meta && item.meta.title);
  const first = matched[0]
  // 判断是否为首页
  if (!isDashboard(first)) {
    matched = [{ path: '/index', meta: { title: 'route.home' } }].concat(matched)
  }

  levelList.value = matched.filter(item => item.meta && item.meta.title && item.meta.breadcrumb !== false)
}
function isDashboard(route) {
  const name = route && route.name
  if (!name) {
    return false
  }
  return name.trim() === 'Index'
}
function handleLink(item) {
  const { redirect, path } = item
  if (redirect) {
    router.push(redirect)
    return
  }
  router.push(path)
}

watchEffect(() => {
  // if you go to the redirect page, do not update the breadcrumbs
  if (route.path.startsWith('/redirect/')) {
    return
  }
  getBreadcrumb()
})
getBreadcrumb();
</script>

<style lang='scss' scoped>
.app-breadcrumb.el-breadcrumb {
  display: inline-block;
  font-size: 14px;
  line-height: 50px;
  margin-left: 8px;

  .no-redirect {
    color: #97a8be;
    cursor: text;
  }
}
</style>