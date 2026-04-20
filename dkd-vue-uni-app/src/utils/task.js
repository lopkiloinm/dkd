export const TASK_STATUS = {
  pending: 1,
  inProgress: 2,
  cancelled: 3,
  completed: 4
}

export const TASK_TYPE = {
  deploy: 1,
  restock: 2,
  maintenance: 3,
  revoke: 4
}

export function getTaskStatusText(status) {
  switch (Number(status)) {
    case TASK_STATUS.pending:
      return 'Pending'
    case TASK_STATUS.inProgress:
      return 'In Progress'
    case TASK_STATUS.cancelled:
      return 'Cancelled'
    case TASK_STATUS.completed:
      return 'Completed'
    default:
      return 'Unknown'
  }
}

export function getTaskStatusVariant(status) {
  switch (Number(status)) {
    case TASK_STATUS.pending:
      return 'warning'
    case TASK_STATUS.inProgress:
      return 'primary'
    case TASK_STATUS.cancelled:
      return 'error'
    case TASK_STATUS.completed:
      return 'success'
    default:
      return 'default'
  }
}

export function getTaskTypeText(typeId) {
  switch (Number(typeId)) {
    case TASK_TYPE.deploy:
      return 'Deploy'
    case TASK_TYPE.restock:
      return 'Restock'
    case TASK_TYPE.maintenance:
      return 'Maintenance'
    case TASK_TYPE.revoke:
      return 'Revoke'
    default:
      return 'Unknown'
  }
}
