import { ref } from 'vue'

interface Notification {
  id: number
  message: string
  type: 'success' | 'error' | 'warning' | 'info'
  duration?: number
}

const notifications = ref<Notification[]>([])
let notificationId = 0

export function useNotifications() {
  const addNotification = (message: string, type: Notification['type'] = 'info', duration = 5000) => {
    const notification: Notification = {
      id: ++notificationId,
      message,
      type,
      duration
    }
    
    notifications.value.push(notification)
    
    if (duration > 0) {
      setTimeout(() => {
        removeNotification(notification.id)
      }, duration)
    }
    
    return notification.id
  }
  
  const removeNotification = (id: number) => {
    const index = notifications.value.findIndex(n => n.id === id)
    if (index > -1) {
      notifications.value.splice(index, 1)
    }
  }
  
  const success = (message: string) => addNotification(message, 'success')
  const error = (message: string) => addNotification(message, 'error', 8000)
  const warning = (message: string) => addNotification(message, 'warning')
  const info = (message: string) => addNotification(message, 'info')
  
  return {
    notifications,
    addNotification,
    removeNotification,
    success,
    error,
    warning,
    info
  }
}