<template>
  <div class="inventory">
    <div class="header">
      <h1>Inventory Management</h1>
      <button @click="loadInventory" class="btn-primary" :disabled="loading">
        {{ loading ? 'Loading...' : 'Refresh' }}
      </button>
    </div>

    <!-- Low Stock Alert -->
    <div v-if="lowStockItems.length > 0" class="alert alert-warning">
      <h3>⚠️ Low Stock Alert</h3>
      <p>{{ lowStockItems.length }} items are below minimum stock levels</p>
    </div>

    <div v-if="loading" class="loading">Loading inventory...</div>
    
    <div v-else-if="error" class="error">{{ error }}</div>
    
    <div v-else>
      <!-- Filter Tabs -->
      <div class="filter-tabs">
        <button 
          v-for="type in ingredientTypes" 
          :key="type"
          @click="selectedType = type"
          :class="['tab', { active: selectedType === type }]"
        >
          {{ type.charAt(0).toUpperCase() + type.slice(1) }}
        </button>
      </div>

      <!-- Inventory Table -->
      <div class="table-container">
        <table>
          <thead>
            <tr>
              <th>Ingredient</th>
              <th>Type</th>
              <th>Available Quantity</th>
              <th>Minimum Quantity</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <tr 
              v-for="item in filteredInventory" 
              :key="`${item.tipo_ingrediente}-${item.id_ingrediente}`"
              :class="{ 'low-stock': item.quantidade_disponivel <= item.quantidade_minima }"
            >
              <td>{{ item.nome_ingrediente }}</td>
              <td>
                <span :class="['type-badge', item.tipo_ingrediente]">
                  {{ item.tipo_ingrediente }}
                </span>
              </td>
              <td>{{ item.quantidade_disponivel }}</td>
              <td>{{ item.quantidade_minima }}</td>
              <td>
                <span 
                  :class="['status', getStockStatus(item.quantidade_disponivel, item.quantidade_minima)]"
                >
                  {{ getStockStatusText(item.quantidade_disponivel, item.quantidade_minima) }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { getInventory, getLowStockItems } from '@/services/api'
import type { InventoryItem } from '@/types'

const inventory = ref<InventoryItem[]>([])
const lowStockItems = ref<InventoryItem[]>([])
const loading = ref(true)
const error = ref('')
const selectedType = ref('all')

const ingredientTypes = ['all', 'massa', 'cobertura', 'recheio', 'topping']

const filteredInventory = computed(() => {
  if (selectedType.value === 'all') {
    return inventory.value
  }
  return inventory.value.filter(item => item.tipo_ingrediente === selectedType.value)
})

const getStockStatus = (available: number, minimum: number) => {
  if (available <= minimum) return 'low'
  if (available <= minimum * 1.5) return 'warning'
  return 'good'
}

const getStockStatusText = (available: number, minimum: number) => {
  if (available <= minimum) return 'Low Stock'
  if (available <= minimum * 1.5) return 'Running Low'
  return 'In Stock'
}

const loadInventory = async () => {
  try {
    loading.value = true
    const [inventoryResponse, lowStockResponse] = await Promise.all([
      getInventory(),
      getLowStockItems()
    ])
    inventory.value = inventoryResponse.data
    lowStockItems.value = lowStockResponse.data
  } catch (err: any) {
    error.value = err.response?.data?.error || 'Failed to load inventory'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadInventory()
})
</script>

<style scoped>
.inventory {
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
  margin: 0;
  letter-spacing: -0.02em;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.95rem;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
}

.btn-primary:disabled {
  background: linear-gradient(135deg, #9ca3af 0%, #6b7280 100%);
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

.alert {
  background: rgba(251, 191, 36, 0.1);
  backdrop-filter: blur(20px);
  padding: 2rem;
  border-radius: 20px;
  margin-bottom: 2rem;
  border: 1px solid rgba(251, 191, 36, 0.3);
  color: white;
}

.alert-warning {
  background: rgba(251, 191, 36, 0.1);
  border: 1px solid rgba(251, 191, 36, 0.3);
  color: #fbbf24;
}

.alert h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1.25rem;
  font-weight: 700;
  color: #fbbf24;
}

.alert p {
  margin: 0;
  font-weight: 500;
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

tr.low-stock td {
  background: rgba(239, 68, 68, 0.1);
}

tr.low-stock:hover td {
  background: rgba(239, 68, 68, 0.15);
}

.type-badge {
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.type-badge.massa {
  background: rgba(59, 130, 246, 0.2);
  color: #60a5fa;
  border: 1px solid rgba(59, 130, 246, 0.3);
}

.type-badge.cobertura {
  background: rgba(239, 68, 68, 0.2);
  color: #f87171;
  border: 1px solid rgba(239, 68, 68, 0.3);
}

.type-badge.recheio {
  background: rgba(251, 191, 36, 0.2);
  color: #fbbf24;
  border: 1px solid rgba(251, 191, 36, 0.3);
}

.type-badge.topping {
  background: rgba(16, 185, 129, 0.2);
  color: #34d399;
  border: 1px solid rgba(16, 185, 129, 0.3);
}

.status {
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.status.good {
  background: rgba(16, 185, 129, 0.2);
  color: #34d399;
  border: 1px solid rgba(16, 185, 129, 0.3);
}

.status.warning {
  background: rgba(251, 191, 36, 0.2);
  color: #fbbf24;
  border: 1px solid rgba(251, 191, 36, 0.3);
}

.status.low {
  background: rgba(239, 68, 68, 0.2);
  color: #f87171;
  border: 1px solid rgba(239, 68, 68, 0.3);
}
</style>