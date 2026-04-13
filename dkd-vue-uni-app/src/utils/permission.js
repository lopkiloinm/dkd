import { useUserStore } from '@/store/modules/user'

/**
 * Check if user has the required permission
 * @param {string|string[]} permission - Permission string or array of permissions
 * @returns {boolean} - Whether the user has the permission
 */
export function hasPermission(permission) {
  const userStore = useUserStore()
  const permissions = userStore.permissions || []
  
  if (!permission) return true
  if (!permissions || permissions.length === 0) return false
  
  if (Array.isArray(permission)) {
    return permission.some(p => permissions.includes(p))
  }
  
  return permissions.includes(permission)
}

/**
 * Check if user has any of the required permissions
 * @param {string[]} permissions - Array of permissions
 * @returns {boolean} - Whether the user has any of the permissions
 */
export function hasAnyPermission(permissions) {
  if (!permissions || permissions.length === 0) return true
  return hasPermission(permissions)
}

/**
 * Check if user has all of the required permissions
 * @param {string[]} permissions - Array of permissions
 * @returns {boolean} - Whether the user has all of the permissions
 */
export function hasAllPermissions(permissions) {
  const userStore = useUserStore()
  const userPermissions = userStore.permissions || []
  
  if (!permissions || permissions.length === 0) return true
  if (!userPermissions || userPermissions.length === 0) return false
  
  return permissions.every(p => userPermissions.includes(p))
}
