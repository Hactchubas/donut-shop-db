<template>
  <div class="dashboard">
    <div class="header">
      <h1>Dashboard</h1>
      <div class="header-controls">
        <div class="date-filter">
          <div class="date-input-wrapper">
            <label class="date-label">From:</label>
            <input
              type="date"
              v-model="startDate"
              class="date-input"
              @change="() => loadSalesReport()"
            />
          </div>
          <div class="date-input-wrapper">
            <label class="date-label">To:</label>
            <input
              type="date"
              v-model="endDate"
              class="date-input"
              @change="() => loadSalesReport()"
            />
          </div>
          <button @click="() => loadSalesReport()" class="filter-btn" :disabled="loadingSalesReport">
            {{ loadingSalesReport ? 'Loading...' : 'Filter' }}
          </button>
          <button @click="clearFilter" class="clear-btn" v-if="salesReport">
            Clear Filter
          </button>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading">Loading dashboard data...</div>

    <div v-else-if="error" class="error">
      {{ error }}
    </div>

    <div v-else>
      <!-- Stats Cards -->
      <div class="section">
        <h2 v-if="startDate && endDate">
          Dashboard Stats ({{ formatDate(startDate) }} - {{ formatDate(endDate) }})
        </h2>
        <h2 v-else>Dashboard Stats (All Time)</h2>
        <div class="stats-grid">
        <div class="stat-card">
          <h3>Total Customers</h3>
          <p class="stat-number">{{ stats.totalCustomers }}</p>
        </div>
        <div class="stat-card">
          <h3>Total Orders (not canceled)</h3>
          <p class="stat-number">{{ stats.totalOrders }}</p>
        </div>
        <div class="stat-card">
          <h3>Pending Orders</h3>
          <p class="stat-number pending">{{ stats.pendingOrders }}</p>
        </div>
        <div class="stat-card">
          <h3>Total Revenue</h3>
          <p class="stat-number revenue">R$ {{ (Number(stats.totalRevenue) || 0).toFixed(2) }}</p>
        </div>
        <div class="stat-card">
          <h3>Low Stock Items</h3>
          <p class="stat-number warning">{{ stats.lowStockItems }}</p>
        </div>
      </div>
      </div>

      <!-- Recent Orders -->
      <div class="section">
        <h2>Recent Orders</h2>
        <div class="table-container">
          <table>
            <thead>
              <tr>
                <th>Order #</th>
                <th>Customer</th>
                <th>Date</th>
                <th>Value</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="order in stats.recentOrders" :key="order.pedido_num">
                <td>{{ order.pedido_num }}</td>
                <td>{{ order.cliente_nome || 'N/A' }}</td>
                <td>{{ new Date(order.data_h).toLocaleDateString('pt-BR') }}</td>
                <td>R$ {{ (Number(order.valor) || 0).toFixed(2) }}</td>
                <td>
                  <span :class="['status', getStatusClass(order.status)]">
                    {{ order.status }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Sales Report -->  
      <div v-if="salesReport" class="section">
        <h2 v-if="startDate && endDate">Sales Report ({{ formatDate(startDate) }} - {{ formatDate(endDate) }})</h2>
        <h2 v-else>Sales Report (All Time)</h2>
        <div class="sales-report-grid">
          <div class="report-card">
            <h3>Total Orders (not canceled)</h3>
            <p class="report-number">{{ salesReport.total_pedidos }}</p>
          </div>
          <div class="report-card">
            <h3>Total Revenue</h3>
            <p class="report-number revenue">R$ {{ salesReport.valor_total.toFixed(2) }}</p>
          </div>
          <div class="report-card">
            <h3>Average Order Value</h3>
            <p class="report-number">R$ {{ salesReport.valor_medio.toFixed(2) }}</p>
          </div>
          <div class="report-card">
            <h3>Most Popular Donut</h3>
            <p class="report-text">{{ salesReport.donut_mais_vendido }}</p>
          </div>
          <div class="report-card">
            <h3>Most Active Customer</h3>
            <p class="report-text">{{ salesReport.cliente_mais_ativo }}</p>
          </div>
          <div class="report-card">
            <h3>Preferred Payment Method</h3>
            <p class="report-text">{{ salesReport.metodo_pagamento_preferido }}</p>
          </div>
        </div>
      </div>

      <!-- Order Status Distribution -->
      <div class="section">
        <h2>Order Status Distribution</h2>
        <div class="chart-container">
          <div v-for="status in stats.statusDistribution" :key="status.status" class="chart-item">
            <span class="chart-label">{{ status.status }}</span>
            <div class="chart-bar">
              <div
                class="chart-fill"
                :style="{ width: (parseInt(status.count) / maxStatusCount * 100) + '%' }"
                :class="getStatusClass(status.status)"
              ></div>
              <span class="chart-value">{{ status.count }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { getDashboardSupplementary, getSalesReport, getDateRange } from '@/services/api'
import type { DashboardStats, DashboardSupplementary, SalesReport } from '@/types'

const stats = ref<DashboardStats>({
  totalCustomers: 0,
  totalOrders: 0,
  pendingOrders: 0,
  totalRevenue: 0,
  lowStockItems: 0,
  recentOrders: [],
  statusDistribution: []
})
const loading = ref(true)
const error = ref('')

// Sales report state
const salesReport = ref<SalesReport | null>(null)
const loadingSalesReport = ref(false)
const salesReportError = ref('')

// Date filter state
const startDate = ref('')
const endDate = ref('')

// Initialize with empty dates for UI, use big range for data loading
const initializeDates = () => {
  // Start with empty date inputs - user can set their own filter
  startDate.value = ''
  endDate.value = ''
}

const maxStatusCount = computed(() => {
  if (stats.value.statusDistribution.length === 0) return 1;
  return Math.max(...stats.value.statusDistribution.map(s => parseInt(s.count)))
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

const formatDate = (dateStr: string) => {
  return new Date(dateStr).toLocaleDateString('pt-BR')
}

const clearFilter = async () => {
  // Clear the date inputs
  startDate.value = ''
  endDate.value = ''
  salesReport.value = null
  salesReportError.value = ''
  await loadAllData() // Load all-time data
}

const loadAllData = async () => {
  try {
    loading.value = true
    error.value = ''

    // Use big date range for all-time data
    const bigStartDate = '1900-01-01'
    const bigEndDate = '2099-12-31'

    // Load both stored procedure data and supplementary data
    const [salesResponse, supplementaryResponse] = await Promise.all([
      getSalesReport(bigStartDate, bigEndDate),
      getDashboardSupplementary()
    ])

    // Always show sales report for consistency
    salesReport.value = salesResponse.data

    // Merge stored procedure data with supplementary data
    stats.value = {
      totalOrders: salesResponse.data.total_pedidos,
      totalRevenue: salesResponse.data.valor_total,
      totalCustomers: supplementaryResponse.data.totalCustomers,
      pendingOrders: supplementaryResponse.data.pendingOrders,
      lowStockItems: supplementaryResponse.data.lowStockItems,
      recentOrders: supplementaryResponse.data.recentOrders,
      statusDistribution: supplementaryResponse.data.statusDistribution
    }
  } catch (err: any) {
    error.value = err.response?.data?.error || 'Failed to load dashboard'
  } finally {
    loading.value = false
  }
}

const loadSalesReport = async (showLoadingSpinner = true) => {
  if (!startDate.value || !endDate.value) return

  try {
    if (showLoadingSpinner) {
      loadingSalesReport.value = true
    }
    salesReportError.value = ''

    // Load both stored procedure data and supplementary data with date filter
    const [salesResponse, supplementaryResponse] = await Promise.all([
      getSalesReport(startDate.value, endDate.value),
      getDashboardSupplementary(startDate.value, endDate.value)
    ])

    salesReport.value = salesResponse.data

    // Merge stored procedure data with supplementary data
    stats.value = {
      totalOrders: salesResponse.data.total_pedidos,
      totalRevenue: salesResponse.data.valor_total,
      totalCustomers: supplementaryResponse.data.totalCustomers,
      pendingOrders: supplementaryResponse.data.pendingOrders,
      lowStockItems: supplementaryResponse.data.lowStockItems,
      recentOrders: supplementaryResponse.data.recentOrders,
      statusDistribution: supplementaryResponse.data.statusDistribution
    }
  } catch (err: any) {
    salesReportError.value = err.response?.data?.error || 'Failed to load sales report'
    salesReport.value = null
    throw err // Re-throw to be caught by onMounted
  } finally {
    if (showLoadingSpinner) {
      loadingSalesReport.value = false
    }
  }
}

onMounted(async () => {
  try {
    loading.value = true
    initializeDates() // No await needed since it's sync now
    await loadAllData() // Load all-time data with big date range
  } catch (err) {
    console.error('Failed to initialize dashboard:', err)
    error.value = 'Failed to initialize dashboard'
  } finally {
    loading.value = false
  }
})
</script>

<style scoped>
.dashboard {
  padding: 0;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 3rem;
}

.header-controls {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.date-filter {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(20px);
  padding: 1rem 1.5rem;
  border-radius: 12px;
  border: 1px solid rgba(255, 255, 255, 0.2);
}

.date-input-wrapper {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.date-label {
  color: rgba(255, 255, 255, 0.8);
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.date-input {
  background: rgba(255, 255, 255, 0.1);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 8px;
  padding: 0.5rem 0.75rem;
  color: white;
  font-weight: 500;
  font-size: 0.9rem;
}

.date-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.3);
}

.date-separator {
  color: rgba(255, 255, 255, 0.7);
  font-weight: 500;
  font-size: 0.9rem;
}

.filter-btn {
  background: linear-gradient(135deg, #34d399 0%, #10b981 100%);
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.filter-btn:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 15px rgba(52, 211, 153, 0.3);
}

.filter-btn:disabled {
  background: linear-gradient(135deg, #9ca3af 0%, #6b7280 100%);
  cursor: not-allowed;
  transform: none;
}

.clear-btn {
  background: linear-gradient(135deg, #f87171 0%, #ef4444 100%);
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.clear-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 15px rgba(248, 113, 113, 0.3);
}

.header h1 {
  font-size: 2.5rem;
  font-weight: 800;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0;
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

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.stat-card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(20px);
  padding: 2rem;
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.stat-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  background: rgba(255, 255, 255, 0.15);
}

.stat-card h3 {
  margin: 0 0 1rem 0;
  color: rgba(255, 255, 255, 0.8);
  font-size: 0.95rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.stat-number {
  margin: 0;
  font-size: 2.75rem;
  font-weight: 800;
  color: white;
  line-height: 1;
}

.stat-number.pending {
  color: #fbbf24;
}

.stat-number.revenue {
  color: #34d399;
}

.stat-number.warning {
  color: #f87171;
}

.section {
  margin-bottom: 3rem;
}

.section h2 {
  margin-bottom: 1.5rem;
  color: white;
  font-size: 1.75rem;
  font-weight: 700;
  letter-spacing: -0.02em;
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

.chart-container {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(20px);
  padding: 2rem;
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.chart-item {
  display: flex;
  align-items: center;
  margin-bottom: 1.5rem;
}

.chart-item:last-child {
  margin-bottom: 0;
}

.chart-label {
  min-width: 140px;
  font-weight: 600;
  color: white;
  font-size: 0.95rem;
}

.chart-bar {
  flex: 1;
  position: relative;
  height: 2.5rem;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 12px;
  margin: 0 1rem;
  overflow: hidden;
}

.chart-fill {
  height: 100%;
  border-radius: 12px;
  transition: all 0.6s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
}

.chart-fill::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(90deg, transparent 0%, rgba(255, 255, 255, 0.2) 50%, transparent 100%);
  animation: shimmer 2s infinite;
}

@keyframes shimmer {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

.chart-fill.pending {
  background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
}

.chart-fill.preparing {
  background: linear-gradient(135deg, #60a5fa 0%, #3b82f6 100%);
}

.chart-fill.delivered {
  background: linear-gradient(135deg, #34d399 0%, #10b981 100%);
}

.chart-fill.cancelled {
  background: linear-gradient(135deg, #f87171 0%, #ef4444 100%);
}

.chart-value {
  position: absolute;
  right: 1rem;
  top: 50%;
  transform: translateY(-50%);
  font-weight: 700;
  color: white;
  font-size: 0.95rem;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.sales-report-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.report-card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(20px);
  padding: 2rem;
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.report-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(135deg, #34d399 0%, #10b981 100%);
}

.report-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  background: rgba(255, 255, 255, 0.15);
}

.report-card h3 {
  margin: 0 0 1rem 0;
  color: rgba(255, 255, 255, 0.8);
  font-size: 0.95rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.report-number {
  margin: 0;
  font-size: 2rem;
  font-weight: 800;
  color: white;
  line-height: 1;
}

.report-number.revenue {
  color: #34d399;
}

.report-text {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
  color: white;
  line-height: 1.3;
}

</style>
