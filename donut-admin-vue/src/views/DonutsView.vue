<template>
  <div class="donuts">
    <div class="header">
      <h1>Donut Menu</h1>
      <button @click="showAddForm = !showAddForm" class="btn-primary">
        {{ showAddForm ? 'Cancel' : 'Create Donut' }}
      </button>
    </div>

    <!-- Create Donut Form -->
    <div v-if="showAddForm" class="add-form">
      <h2>Create New Donut</h2>
      <form @submit.prevent="createDonut">
        <div class="form-section">
          <h3>Base Donut</h3>
          <div class="form-grid">
            <div class="form-group">
              <label>Base Price (R$)</label>
              <input 
                v-model.number="newDonut.preco" 
                type="number" 
                step="0.01" 
                min="0" 
                required 
                placeholder="5.00"
              />
            </div>
            <div class="form-group">
              <label>Massa (Required)</label>
              <select v-model="newDonut.id_massa" required>
                <option value="">Select a massa...</option>
                <option 
                  v-for="massa in ingredients.massas" 
                  :key="massa.id_massa" 
                  :value="massa.id_massa"
                >
                  {{ massa.tipo }} (+R$ {{ massa.preco.toFixed(2) }})
                </option>
              </select>
            </div>
          </div>
        </div>

        <div class="form-section">
          <h3>Coberturas (Optional)</h3>
          <div class="ingredients-grid">
            <label 
              v-for="cobertura in ingredients.coberturas" 
              :key="cobertura.id_cobertura"
              class="ingredient-checkbox"
            >
              <input 
                type="checkbox" 
                :value="cobertura.id_cobertura" 
                v-model="newDonut.coberturas"
              />
              <span>{{ cobertura.tipo }} (+R$ {{ cobertura.preco.toFixed(2) }})</span>
            </label>
          </div>
        </div>

        <div class="form-section">
          <h3>Recheios (Optional)</h3>
          <div class="ingredients-grid">
            <label 
              v-for="recheio in ingredients.recheios" 
              :key="recheio.id_recheio"
              class="ingredient-checkbox"
            >
              <input 
                type="checkbox" 
                :value="recheio.id_recheio" 
                v-model="newDonut.recheios"
              />
              <span>{{ recheio.tipo }} (+R$ {{ recheio.preco.toFixed(2) }})</span>
            </label>
          </div>
        </div>

        <div class="form-section">
          <h3>Toppings (Optional)</h3>
          <div class="ingredients-grid">
            <label 
              v-for="topping in ingredients.toppings" 
              :key="topping.id_topping"
              class="ingredient-checkbox"
            >
              <input 
                type="checkbox" 
                :value="topping.id_topping" 
                v-model="newDonut.toppings"
              />
              <span>{{ topping.tipo }} (+R$ {{ topping.preco.toFixed(2) }})</span>
            </label>
          </div>
        </div>

        <div class="form-section price-preview">
          <h3>Estimated Total Price: R$ {{ estimatedPrice.toFixed(2) }}</h3>
        </div>

        <div class="form-actions">
          <button type="submit" class="btn-primary" :disabled="creating || !newDonut.id_massa">
            {{ creating ? 'Creating...' : 'Create Donut' }}
          </button>
        </div>
      </form>
    </div>

    <div v-if="loading" class="loading">Loading donuts...</div>

    <div v-else-if="error" class="error">{{ error }}</div>

    <div v-else class="donuts-grid">
      <div v-for="donut in donuts" :key="donut.id_donut" class="donut-card">
        <div class="donut-header">
          <h3>Donut #{{ donut.id_donut }}</h3>
          <span class="price">R$ {{ (Number(donut.preco_total) || 0).toFixed(2) }}</span>
        </div>

        <div class="donut-details">
          <div class="detail-item">
            <strong>Massa:</strong> {{ donut.massa }}
          </div>

          <div v-if="donut.cobertura" class="detail-item">
            <strong>Cobertura:</strong> {{ donut.cobertura }}
          </div>

          <div v-if="donut.recheio" class="detail-item">
            <strong>Recheio:</strong> {{ donut.recheio }}
          </div>

          <div v-if="donut.toppings" class="detail-item">
            <strong>Topping:</strong> {{ donut.toppings }}
          </div>
        </div>

      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { getDonuts, createDonut as createDonutApi, getIngredients } from '@/services/api'
import type { Donut } from '@/types'

const donuts = ref<Donut[]>([])
const loading = ref(true)
const error = ref('')
const showAddForm = ref(false)
const creating = ref(false)
const ingredients = ref<{
  massas: any[];
  coberturas: any[];
  recheios: any[];
  toppings: any[];
}>({
  massas: [],
  coberturas: [],
  recheios: [],
  toppings: []
})

const newDonut = ref({
  preco: 0,
  id_massa: '',
  coberturas: [] as number[],
  recheios: [] as number[],
  toppings: [] as number[]
})

const estimatedPrice = computed(() => {
  let total = newDonut.value.preco || 0
  
  // Add massa price
  const selectedMassa = ingredients.value.massas.find(m => m.id_massa == newDonut.value.id_massa)
  if (selectedMassa) {
    total += selectedMassa.preco
  }
  
  // Add cobertura prices
  newDonut.value.coberturas.forEach(id => {
    const cobertura = ingredients.value.coberturas.find(c => c.id_cobertura === id)
    if (cobertura) total += cobertura.preco
  })
  
  // Add recheio prices
  newDonut.value.recheios.forEach(id => {
    const recheio = ingredients.value.recheios.find(r => r.id_recheio === id)
    if (recheio) total += recheio.preco
  })
  
  // Add topping prices
  newDonut.value.toppings.forEach(id => {
    const topping = ingredients.value.toppings.find(t => t.id_topping === id)
    if (topping) total += topping.preco
  })
  
  return total
})

const loadDonuts = async () => {
  try {
    loading.value = true
    const response = await getDonuts()
    donuts.value = response.data
  } catch (err: any) {
    error.value = err.response?.data?.error || 'Failed to load donuts'
  } finally {
    loading.value = false
  }
}

const loadIngredients = async () => {
  try {
    const response = await getIngredients()
    ingredients.value = response.data
  } catch (err: any) {
    error.value = err.response?.data?.error || 'Failed to load ingredients'
  }
}

const createDonut = async () => {
  try {
    creating.value = true
    
    const donutData = {
      preco: newDonut.value.preco,
      id_massa: Number(newDonut.value.id_massa),
      coberturas: newDonut.value.coberturas.length > 0 ? newDonut.value.coberturas : undefined,
      recheios: newDonut.value.recheios.length > 0 ? newDonut.value.recheios : undefined,
      toppings: newDonut.value.toppings.length > 0 ? newDonut.value.toppings : undefined
    }
    
    await createDonutApi(donutData)
    await loadDonuts() // Refresh the donut list
    
    // Reset form
    showAddForm.value = false
    newDonut.value = {
      preco: 0,
      id_massa: '',
      coberturas: [],
      recheios: [],
      toppings: []
    }
    
  } catch (err: any) {
    error.value = err.response?.data?.error || 'Failed to create donut'
  } finally {
    creating.value = false
  }
}

onMounted(() => {
  loadDonuts()
  loadIngredients()
})
</script>

<style scoped>
.donuts {
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

.form-section {
  margin-bottom: 2rem;
}

.form-section h3 {
  color: white;
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.ingredients-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
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

.form-group input, .form-group select {
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

.form-group input:focus, .form-group select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.3);
  background: rgba(255, 255, 255, 0.15);
}

.form-group select option {
  background: #1e3c72;
  color: white;
}

.ingredient-checkbox {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.75rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  color: rgba(255, 255, 255, 0.9);
  font-weight: 500;
}

.ingredient-checkbox:hover {
  background: rgba(255, 255, 255, 0.1);
  border-color: rgba(255, 255, 255, 0.2);
}

.ingredient-checkbox input[type="checkbox"] {
  width: 18px;
  height: 18px;
  margin: 0;
  accent-color: #667eea;
}

.price-preview {
  background: rgba(52, 211, 153, 0.1);
  border: 1px solid rgba(52, 211, 153, 0.3);
  border-radius: 12px;
  padding: 1.5rem;
  text-align: center;
}

.price-preview h3 {
  color: #34d399;
  font-size: 1.5rem;
  font-weight: 700;
  margin: 0;
  border: none;
}

.form-actions {
  display: flex;
  justify-content: flex-start;
  margin-top: 2rem;
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

.donuts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 2rem;
}

.donut-card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  padding: 2rem;
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.donut-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.donut-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
  background: rgba(255, 255, 255, 0.15);
}

.donut-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid rgba(255, 255, 255, 0.2);
}

.donut-header h3 {
  margin: 0;
  color: white;
  font-size: 1.5rem;
  font-weight: 700;
  letter-spacing: -0.02em;
}

.price {
  font-size: 1.5rem;
  font-weight: 800;
  color: #34d399;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
}

.donut-details {
  margin-bottom: 0;
}

.detail-item {
  margin-bottom: 1rem;
  color: rgba(255, 255, 255, 0.9);
  line-height: 1.6;
  font-size: 1rem;
  font-weight: 500;
}

.detail-item:last-child {
  margin-bottom: 0;
}

.detail-item strong {
  color: white;
  font-weight: 700;
}
</style>
