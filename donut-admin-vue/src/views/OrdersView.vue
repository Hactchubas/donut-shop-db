<template>
  <div class="orders">
    <div class="header">
      <h1>Orders Management</h1>
    </div>

    <div v-if="loading" class="loading">Loading orders...</div>

    <div v-else-if="error" class="error">{{ error }}</div>

    <div v-else>
      <!-- Filter Tabs -->
      <div class="filter-tabs">
        <button 
          v-for="status in orderStatuses" 
          :key="status"
          @click="selectedStatus = status"
          :class="['tab', { active: selectedStatus === status }]"
        >
          {{ status === 'all' ? 'All Orders' : status }}
        </button>
      </div>

      <div class="table-container">
      <table>
        <thead>
          <tr>
            <th>Order #</th>
            <th>Customer</th>
            <th>Date</th>
            <th>Value</th>
            <th>Payment Method</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <template v-for="order in filteredOrders" :key="order.pedido_num">
            <!-- Main order row -->
            <tr 
              @click="toggleOrderExpansion(order.pedido_num)" 
              :class="['order-row', { expanded: expandedOrders.has(order.pedido_num) }]"
            >
              <td>
                <span class="expand-icon">
                  {{ expandedOrders.has(order.pedido_num) ? '▼' : '▶' }}
                </span>
                {{ order.pedido_num }}
              </td>
              <td>{{ order.cliente_nome || 'N/A' }}</td>
              <td>{{ new Date(order.data_h).toLocaleString() }}</td>
              <td>R$ {{ (Number(order.valor) || 0).toFixed(2) }}</td>
              <td>{{ order.metodo_pagamento || 'N/A' }}</td>
              <td>
                <span :class="['status', getStatusClass(order.status)]">
                  {{ order.status }}
                </span>
              </td>
              <td @click.stop>
                <select
                  @change="updateStatus(order.pedido_num, $event)"
                  :value="order.status"
                  :disabled="updatingOrder === order.pedido_num"
                  class="status-select"
                >
                  <option value="Pendente">Pendente</option>
                  <option value="Em Preparo">Em Preparo</option>
                  <option value="Entregue">Entregue</option>
                  <option value="Cancelado">Cancelado</option>
                </select>
              </td>
            </tr>
            
            <!-- Expanded donut details row -->
            <tr v-if="expandedOrders.has(order.pedido_num)" class="expanded-row">
              <td colspan="7" class="expanded-content">
                <div v-if="loadingDonuts.has(order.pedido_num)" class="loading-donuts">
                  Loading donuts...
                </div>
                <div v-else-if="orderDonuts[order.pedido_num]?.length > 0" class="donuts-list">
                  <h4>Donuts in this order:</h4>
                  <div class="donut-grid">
                    <div 
                      v-for="donut in orderDonuts[order.pedido_num]" 
                      :key="donut.id_donut"
                      class="donut-card"
                    >
                      <div class="donut-header">
                        <span class="donut-id">Donut #{{ donut.id_donut }}</span>
                        <span class="donut-price">R$ {{ (Number(donut.preco_total) || 0).toFixed(2) }}</span>
                      </div>
                      <div class="donut-details">
                        <div class="donut-ingredient">
                          <strong>Massa:</strong> {{ donut.massa }}
                        </div>
                        <div class="donut-ingredient">
                          <strong>Cobertura:</strong> {{ donut.cobertura }}
                        </div>
                        <div class="donut-ingredient">
                          <strong>Recheio:</strong> {{ donut.recheio }}
                        </div>
                        <div class="donut-ingredient">
                          <strong>Toppings:</strong> {{ donut.toppings }}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div v-else class="no-donuts">
                  No donuts found for this order.
                </div>
              </td>
            </tr>
          </template>
        </tbody>
      </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { getOrders, updateOrderStatus, getOrderDonuts } from '@/services/api'
import type { Order, Donut } from '@/types'

const orders = ref<Order[]>([])
const loading = ref(true)
const error = ref('')
const updatingOrder = ref<number | null>(null)
const selectedStatus = ref('all')
const expandedOrders = ref<Set<number>>(new Set())
const orderDonuts = ref<Record<number, Donut[]>>({})
const loadingDonuts = ref<Set<number>>(new Set())

const orderStatuses = ['all', 'Pendente', 'Em Preparo', 'Entregue', 'Cancelado']

const filteredOrders = computed(() => {
  if (selectedStatus.value === 'all') {
    return orders.value
  }
  return orders.value.filter(order => order.status === selectedStatus.value)
})

const getStatusClass = (status: string) => {
  switch (status) {
    case 'Pendente': return 'pending'
    case 'Em Preparo': return 'preparing'
    case 'Entregue': return 'delivered'
    case 'Cancelado': return 'cancelled'
    default: return ''
  }
}

const loadOrders = async () => {
  try {
    loading.value = true
    const response = await getOrders()
    orders.value = response.data
  } catch (err: any) {
    error.value = err.response?.data?.error || 'Failed to load orders'
  } finally {
    loading.value = false
  }
}

const updateStatus = async (orderId: number, event: Event) => {
  const target = event.target as HTMLSelectElement
  const newStatus = target.value

  try {
    updatingOrder.value = orderId
    await updateOrderStatus(orderId, newStatus)

    // Update local state
    const order = orders.value.find(o => o.pedido_num === orderId)
    if (order) {
      order.status = newStatus as Order['status']
    }
  } catch (err: any) {
    error.value = err.response?.data?.error || 'Failed to update order status'
    // Reload to reset the select value
    await loadOrders()
  } finally {
    updatingOrder.value = null
  }
}

const toggleOrderExpansion = async (orderId: number) => {
  if (expandedOrders.value.has(orderId)) {
    // Collapse
    expandedOrders.value.delete(orderId)
  } else {
    // Expand and load donuts if not already loaded
    expandedOrders.value.add(orderId)
    
    if (!orderDonuts.value[orderId]) {
      await loadOrderDonuts(orderId)
    }
  }
}

const loadOrderDonuts = async (orderId: number) => {
  try {
    loadingDonuts.value.add(orderId)
    const response = await getOrderDonuts(orderId)
    orderDonuts.value[orderId] = response.data
  } catch (err: any) {
    error.value = err.response?.data?.error || 'Failed to load order donuts'
  } finally {
    loadingDonuts.value.delete(orderId)
  }
}

onMounted(() => {
  loadOrders()
})
</script>

<style scoped>
.orders {
  padding: 0;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 3rem;
}

.header h1 {
  font-size: 2.5rem;
  font-weight: 800;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0 0 3rem 0;
  letter-spacing: -0.02em;
}

.loading, .error {
  text-align: center;
  padding: 3rem 2rem;
  font-size: 1.25rem;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  color: white;
  font-weight: 500;
}

.error {
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.2);
  color: #fecaca;
}

.filter-tabs {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
}

.tab {
  padding: 0.75rem 1.5rem;
  border: 1px solid rgba(255, 255, 255, 0.2);
  background: rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  transition: all 0.3s ease;
  color: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(20px);
}

.tab:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateY(-1px);
}

.tab.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-color: transparent;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.table-container {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  overflow: hidden;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

table {
  width: 100%;
  border-collapse: collapse;
}

th, td {
  padding: 1rem 1.5rem;
  text-align: left;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

th {
  background: rgba(255, 255, 255, 0.05);
  font-weight: 700;
  color: white;
  font-size: 0.95rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

td {
  color: rgba(255, 255, 255, 0.9);
  font-weight: 500;
}

tr:hover td {
  background: rgba(255, 255, 255, 0.05);
}

.status {
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.status.pending {
  background: rgba(251, 191, 36, 0.2);
  color: #fbbf24;
  border: 1px solid rgba(251, 191, 36, 0.3);
}

.status.preparing {
  background: rgba(59, 130, 246, 0.2);
  color: #60a5fa;
  border: 1px solid rgba(59, 130, 246, 0.3);
}

.status.delivered {
  background: rgba(16, 185, 129, 0.2);
  color: #34d399;
  border: 1px solid rgba(16, 185, 129, 0.3);
}

.status.cancelled {
  background: rgba(239, 68, 68, 0.2);
  color: #f87171;
  border: 1px solid rgba(239, 68, 68, 0.3);
}

.status-select {
  padding: 0.5rem 1rem;
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  font-size: 0.875rem;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  font-weight: 600;
  transition: all 0.3s ease;
}

.status-select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.3);
  background: rgba(255, 255, 255, 0.15);
}

.status-select:disabled {
  background: rgba(255, 255, 255, 0.05);
  cursor: not-allowed;
  opacity: 0.5;
}

.status-select option {
  background: #1e3c72;
  color: white;
}

.order-row {
  cursor: pointer;
  transition: all 0.3s ease;
}

.order-row:hover {
  background: rgba(255, 255, 255, 0.08) !important;
}

.order-row.expanded {
  background: rgba(102, 126, 234, 0.1);
}

.expand-icon {
  display: inline-block;
  margin-right: 0.5rem;
  transition: transform 0.3s ease;
  font-size: 0.8rem;
  width: 1rem;
}

.expanded-row {
  background: rgba(255, 255, 255, 0.02);
}

.expanded-content {
  padding: 2rem !important;
}

.loading-donuts {
  text-align: center;
  color: rgba(255, 255, 255, 0.7);
  font-style: italic;
}

.donuts-list h4 {
  color: white;
  margin: 0 0 1.5rem 0;
  font-size: 1.1rem;
  font-weight: 600;
}

.donut-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1rem;
}

.donut-card {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  padding: 1.5rem;
  transition: all 0.3s ease;
}

.donut-card:hover {
  background: rgba(255, 255, 255, 0.15);
  transform: translateY(-2px);
}

.donut-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
}

.donut-id {
  font-weight: 700;
  color: #667eea;
  font-size: 1rem;
}

.donut-price {
  font-weight: 600;
  color: #34d399;
  font-size: 1.1rem;
}

.donut-details {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.donut-ingredient {
  color: rgba(255, 255, 255, 0.9);
  font-size: 0.9rem;
}

.donut-ingredient strong {
  color: rgba(255, 255, 255, 0.7);
  font-weight: 600;
  display: inline-block;
  width: 80px;
}

.no-donuts {
  text-align: center;
  color: rgba(255, 255, 255, 0.6);
  font-style: italic;
  padding: 2rem;
}
</style>
