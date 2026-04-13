<template>
  <div v-if="!item.hidden">
    <template v-if="hasOneShowingChild(item.children, item) && (!onlyOneChild.children || onlyOneChild.noShowingChildren) && !item.alwaysShow">
      <app-link v-if="onlyOneChild.meta" :to="resolvePath(onlyOneChild.path, onlyOneChild.query)">
        <el-menu-item :index="resolvePath(onlyOneChild.path)" :class="{ 'submenu-title-noDropdown': !isNest }">
          <svg-icon :icon-class="onlyOneChild.meta.icon || (item.meta && item.meta.icon)"/>
          <template #title><span class="menu-title" :title="hasTitle(translateTitle(onlyOneChild.meta.title, onlyOneChild))">{{ translateTitle(onlyOneChild.meta.title, onlyOneChild) }}</span></template>
        </el-menu-item>
      </app-link>
    </template>

    <el-sub-menu v-else ref="subMenu" :index="resolvePath(item.path)" teleported>
      <template v-if="item.meta" #title>
        <svg-icon :icon-class="item.meta && item.meta.icon" />
        <span class="menu-title" :title="hasTitle(translateTitle(item.meta.title, item))">{{ translateTitle(item.meta.title, item) }}</span>
      </template>

      <sidebar-item
        v-for="(child, index) in item.children"
        :key="child.path + index"
        :is-nest="true"
        :item="child"
        :base-path="resolvePath(child.path)"
        class="nest-menu"
      />
    </el-sub-menu>
  </div>
</template>

<script setup>
import { isExternal } from '@/utils/validate'
import AppLink from './Link'
import { getNormalPath } from '@/utils/ruoyi'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const props = defineProps({
  // route object
  item: {
    type: Object,
    required: true
  },
  isNest: {
    type: Boolean,
    default: false
  },
  basePath: {
    type: String,
    default: ''
  }
})

const onlyOneChild = ref({});

// Map Chinese menu titles to i18n keys
const menuTitleMap = {
  '首页': 'route.home',
  '点位管理': 'node.title',
  '区域管理': 'region.title',
  '合作商管理': 'partner.title',
  '设备管理': 'vm.title',
  '设备类型管理': 'vmType.title',
  '人员管理': 'emp.title',
  '人员列表': 'emp.title',
  '系统管理': 'route.system',
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

const menuPathMap = {
  log: 'system.logManagement'
}

function translateTitle(title, routeItem = null) {
  if (!title) return ''
  const normalizedTitle = String(title).trim()
  // If it's already an i18n key (contains dots), use it directly
  if (normalizedTitle.includes('.')) return t(normalizedTitle) || normalizedTitle
  // Otherwise, check if it's in the Chinese title map
  const compactTitle = normalizedTitle.replace(/\s+/g, '')
  let i18nKey = menuTitleMap[normalizedTitle] || menuTitleMap[compactTitle]
  if (!i18nKey && routeItem && routeItem.path) {
    const normalizedPath = String(routeItem.path).trim().toLowerCase()
    i18nKey = menuPathMap[normalizedPath]
  }
  if (i18nKey) {
    const translated = t(i18nKey)
    return translated === i18nKey ? normalizedTitle : translated
  }
  // Fall back to original title
  return normalizedTitle
}

function hasOneShowingChild(children = [], parent) {
  if (!children) {
    children = [];
  }
  const showingChildren = children.filter(item => {
    if (item.hidden) {
      return false
    } else {
      // Temp set(will be used if only has one showing child)
      onlyOneChild.value = item
      return true
    }
  })

  // When there is only one child router, the child router is displayed by default
  if (showingChildren.length === 1) {
    return true
  }

  // Show parent if there are no child router to display
  if (showingChildren.length === 0) {
    onlyOneChild.value = { ...parent, path: '', noShowingChildren: true }
    return true
  }

  return false
};

function resolvePath(routePath, routeQuery) {
  if (isExternal(routePath)) {
    return routePath
  }
  if (isExternal(props.basePath)) {
    return props.basePath
  }
  if (routeQuery) {
    let query = JSON.parse(routeQuery);
    return { path: getNormalPath(props.basePath + '/' + routePath), query: query }
  }
  return getNormalPath(props.basePath + '/' + routePath)
}

function hasTitle(title){
  if (!title) {
    return ""
  }
  if (title.length > 5) {
    return title;
  } else {
    return "";
  }
}
</script>
