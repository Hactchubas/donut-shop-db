<template>
  <div class="customers">
    <div class="header">
      <h1>Customers</h1>
      <button @click="showAddForm = !showAddForm" class="btn-primary">
        {{ showAddForm ? 'Cancel' : 'Add Customer' }}
      </button>
    </div>

    <!-- Add Customer Form -->
    <div v-if="showAddForm" class="add-form">
      <h2>Add New Customer</h2>
      <form @submit.prevent="createCustomer">
        <div class="form-grid">
          <div class="form-group">
            <label>CPF</label>
            <input v-model="newCustomer.cpf" type="text" required maxlength="11" />
          </div>
          <div class="form-group">
            <label>Name</label>
            <input v-model="newCustomer.nome" type="text" required />
          </div>
          <div class="form-group">
            <label>Email</label>
            <input v-model="newCustomer.email" type="email" required />
          </div>
          <div class="form-group">
            <label>Phone</label>
            <input v-model="newCustomer.telefone" type="text" required />
          </div>
          <div class="form-group">
            <label>Street</label>
            <input v-model="newCustomer.rua" type="text" required />
          </div>
          <div class="form-group">
            <label>Number</label>
            <input v-model="newCustomer.numero" type="text" required />
          </div>
          <div class="form-group">
            <label>Neighborhood</label>
            <input v-model="newCustomer.bairro" type="text" required />
          </div>
          <div class="form-group">
            <label>City</label>
            <input v-model="newCustomer.cidade" type="text" required />
          </div>
        </div>
        <div class="form-actions">
          <button type="submit" class="btn-primary" :disabled="creating">
            {{ creating ? 'Creating...' : 'Create Customer' }}
          </button>
        </div>
      </form>
    </div>

    <!-- Edit Customer Form -->
    <div v-if="showEditForm && editingCustomer" class="edit-form">
      <h2>Edit Customer</h2>
      <form @submit.prevent="updateCustomerHandler">
        <div class="form-grid">
          <div class="form-group">
            <label>CPF (Cannot be changed)</label>
            <input v-model="editingCustomer.cpf" type="text" disabled />
          </div>
          <div class="form-group">
            <label>Name</label>
            <input v-model="editingCustomer.nome" type="text" required />
          </div>
          <div class="form-group">
            <label>Email</label>
            <input v-model="editingCustomer.email" type="email" required />
          </div>
          <div class="form-group">
            <label>Phone</label>
            <input v-model="editingCustomer.telefone" type="text" required />
          </div>
          <div class="form-group">
            <label>Street</label>
            <input v-model="editingCustomer.rua" type="text" required />
          </div>
          <div class="form-group">
            <label>Number</label>
            <input v-model="editingCustomer.numero" type="text" required />
          </div>
          <div class="form-group">
            <label>Neighborhood</label>
            <input v-model="editingCustomer.bairro" type="text" required />
          </div>
          <div class="form-group">
            <label>City</label>
            <input v-model="editingCustomer.cidade" type="text" required />
          </div>
        </div>
        <div class="form-actions">
          <button type="submit" class="btn-primary" :disabled="updating">
            {{ updating ? 'Updating...' : 'Update Customer' }}
          </button>
          <button type="button" @click="cancelEdit" class="btn-secondary">
            Cancel
          </button>
        </div>
      </form>
    </div>

    <div v-if="loading" class="loading">Loading customers...</div>

    <div v-else-if="error" class="error">{{ error }}</div>

    <div v-else class="table-container">
      <table>
        <thead>
          <tr>
            <th>CPF</th>
            <th>Name</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Address</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="customer in customers" :key="customer.cpf">
            <td>{{ customer.cpf }}</td>
            <td>{{ customer.nome }}</td>
            <td>{{ customer.email }}</td>
            <td>{{ customer.telefone }}</td>
            <td>{{ customer.rua }}, {{ customer.numero }}, {{ customer.bairro }}, {{ customer.cidade }}</td>
            <td>
              <button @click="startEdit(customer)" class="btn-edit" :disabled="deleting === customer.cpf || updating">
                Edit
              </button>
              <button @click="confirmDelete(customer)" class="btn-delete" :disabled="deleting === customer.cpf || updating">
                {{ deleting === customer.cpf ? 'Deleting...' : 'Delete' }}
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getCustomers, createCustomer as createCustomerApi, updateCustomer, deleteCustomer } from '@/services/api'
import type { Customer } from '@/types'

const customers = ref<Customer[]>([])
const loading = ref(true)
const error = ref('')
const showAddForm = ref(false)
const creating = ref(false)
const deleting = ref('')
const editingCustomer = ref<Customer | null>(null)
const showEditForm = ref(false)
const updating = ref(false)

const newCustomer = ref({
  cpf: '',
  nome: '',
  email: '',
  telefone: '',
  rua: '',
  numero: '',
  bairro: '',
  cidade: ''
})

const loadCustomers = async () => {
  try {
    loading.value = true
    const response = await getCustomers()
    customers.value = response.data
  } catch (err: any) {
    error.value = err.response?.data?.error || 'Failed to load customers'
  } finally {
    loading.value = false
  }
}

const createCustomer = async () => {
  try {
    creating.value = true
    await createCustomerApi(newCustomer.value)
    await loadCustomers()
    showAddForm.value = false
    newCustomer.value = {
      cpf: '',
      nome: '',
      email: '',
      telefone: '',
      rua: '',
      numero: '',
      bairro: '',
      cidade: ''
    }
  } catch (err: any) {
    error.value = err.response?.data?.error || 'Failed to create customer'
  } finally {
    creating.value = false
  }
}

const confirmDelete = async (customer: any) => {
  const message = `Are you sure you want to delete customer ${customer.nome} (CPF: ${customer.cpf})?\n\nThis will permanently delete:\n• The customer record\n• All their orders and payments\n• All their favorites\n• All related audit records`
  if (confirm(message)) {
    await deleteCustomerHandler(customer.cpf)
  }
}

const deleteCustomerHandler = async (cpf: string) => {
  try {
    deleting.value = cpf
    const response = await deleteCustomer(cpf)
    
    // Show success message with details if available
    if (response.data?.deletedData) {
      const { orders, favorites } = response.data.deletedData
      alert(`Customer deleted successfully!\n\nDeleted data:\n• Orders: ${orders}\n• Favorites: ${favorites}`)
    }
    
    await loadCustomers()
  } catch (err: any) {
    error.value = err.response?.data?.error || 'Failed to delete customer'
  } finally {
    deleting.value = ''
  }
}

const startEdit = (customer: Customer) => {
  editingCustomer.value = { ...customer }
  showEditForm.value = true
  showAddForm.value = false
}

const cancelEdit = () => {
  editingCustomer.value = null
  showEditForm.value = false
  error.value = ''
}

const updateCustomerHandler = async () => {
  if (!editingCustomer.value) return
  
  try {
    updating.value = true
    await updateCustomer(editingCustomer.value.cpf, {
      email: editingCustomer.value.email,
      telefone: editingCustomer.value.telefone,
      nome: editingCustomer.value.nome,
      rua: editingCustomer.value.rua,
      numero: editingCustomer.value.numero,
      bairro: editingCustomer.value.bairro,
      cidade: editingCustomer.value.cidade
    })
    
    await loadCustomers()
    cancelEdit()
  } catch (err: any) {
    error.value = err.response?.data?.error || 'Failed to update customer'
  } finally {
    updating.value = false
  }
}

onMounted(() => {
  loadCustomers()
})
</script>

<style scoped>
.customers {
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

.add-form {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(20px);
  padding: 2.5rem;
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  margin-bottom: 3rem;
}

.add-form h2 {
  margin-top: 0;
  margin-bottom: 2rem;
  color: white;
  font-size: 1.75rem;
  font-weight: 700;
  letter-spacing: -0.02em;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  margin-bottom: 0.75rem;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.9);
  font-size: 0.95rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.form-group input {
  padding: 1rem;
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  font-size: 1rem;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  transition: all 0.3s ease;
}

.form-group input::placeholder {
  color: rgba(255, 255, 255, 0.5);
}

.form-group input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.3);
  background: rgba(255, 255, 255, 0.15);
}

.form-actions {
  display: flex;
  justify-content: flex-start;
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

.btn-delete {
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.875rem;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(239, 68, 68, 0.3);
}

.btn-delete:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.4);
}

.btn-delete:disabled {
  background: linear-gradient(135deg, #9ca3af 0%, #6b7280 100%);
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

.btn-edit {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.875rem;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
  margin-right: 0.5rem;
}

.btn-edit:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
}

.btn-edit:disabled {
  background: linear-gradient(135deg, #9ca3af 0%, #6b7280 100%);
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

.btn-secondary {
  background: linear-gradient(135deg, #6b7280 0%, #4b5563 100%);
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 12px;
  cursor: pointer;
  font-weight: 600;
  font-size: 0.95rem;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(107, 114, 128, 0.3);
  margin-left: 1rem;
}

.btn-secondary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(107, 114, 128, 0.4);
}

.edit-form {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(20px);
  padding: 2.5rem;
  border-radius: 20px;
  border: 1px solid rgba(255, 255, 255, 0.2);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  margin-bottom: 3rem;
}

.edit-form h2 {
  margin-top: 0;
  margin-bottom: 2rem;
  color: white;
  font-size: 1.75rem;
  font-weight: 700;
  letter-spacing: -0.02em;
}

.form-group input:disabled {
  background: rgba(255, 255, 255, 0.05);
  color: rgba(255, 255, 255, 0.6);
  cursor: not-allowed;
}

</style>
