import axios from 'axios';
import type { Customer, Order, Donut, InventoryItem, DashboardStats, DashboardSupplementary, SalesReport } from '@/types';

// API base URL - use relative path with nginx proxy
const API_BASE_URL = '/api';

const api = axios.create({
  baseURL: API_BASE_URL,
});

// Test connection
export const testConnection = () => api.get('/test');

// Customers
export const getCustomers = (): Promise<{ data: Customer[] }> => api.get('/customers');
export const createCustomer = (customer: Omit<Customer, 'cpf'> & { cpf: string }) => 
  api.post('/customers', customer);
export const updateCustomer = (cpf: string, customer: Omit<Customer, 'cpf' | 'senha'>) => 
  api.put(`/customers/${cpf}`, customer);
export const deleteCustomer = (cpf: string) => api.delete(`/customers/${cpf}`);

// Orders
export const getOrders = (): Promise<{ data: Order[] }> => api.get('/orders');
export const updateOrderStatus = (id: number, status: string) => 
  api.put(`/orders/${id}/status`, { status });
export const getOrderDonuts = (orderId: number): Promise<{ data: Donut[] }> => 
  api.get(`/orders/${orderId}/donuts`);

// Donuts
export const getDonuts = (): Promise<{ data: Donut[] }> => api.get('/donuts');
export const createDonut = (donut: { preco: number; id_massa: number; coberturas?: number[]; recheios?: number[]; toppings?: number[] }) => 
  api.post('/donuts', donut);
export const getIngredients = (): Promise<{ data: { massas: any[]; coberturas: any[]; recheios: any[]; toppings: any[] } }> => 
  api.get('/ingredients');

// Inventory
export const getInventory = (): Promise<{ data: InventoryItem[] }> => api.get('/inventory');
export const getLowStockItems = (): Promise<{ data: InventoryItem[] }> => api.get('/inventory/low-stock');

// Analytics
export const getSalesReport = (startDate: string, endDate: string): Promise<{ data: SalesReport }> => 
  api.get('/analytics/sales-report', { params: { startDate, endDate } });
export const getDashboardSupplementary = (startDate?: string, endDate?: string): Promise<{ data: DashboardSupplementary }> => 
  api.get('/analytics/dashboard-supplementary', { params: startDate && endDate ? { startDate, endDate } : {} });
export const getDateRange = (): Promise<{ data: { startDate: string; endDate: string } }> => 
  api.get('/analytics/date-range');