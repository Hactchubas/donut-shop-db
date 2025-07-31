export interface Customer {
  cpf: string;
  email: string;
  telefone: string;
  nome: string;
  rua: string;
  numero: string;
  bairro: string;
  cidade: string;
  senha?: string;
}

export interface Order {
  pedido_num: number;
  data_h: string;
  valor: number;
  status: 'Pendente' | 'Em Preparo' | 'Entregue' | 'Cancelado';
  cpf_cliente: string;
  cliente_nome?: string;
  metodo_pagamento?: string;
}

export interface Donut {
  id_donut: number;
  massa: string;
  cobertura?: string;
  recheio?: string;
  toppings?: string;
  preco_total: number;
}

export interface InventoryItem {
  id_estoque?: number;
  tipo_ingrediente: 'massa' | 'cobertura' | 'recheio' | 'topping';
  id_ingrediente: number;
  quantidade_disponivel: number;
  quantidade_minima: number;
  nome_ingrediente: string;
  data_ultima_atualizacao?: string;
}

export interface Massa {
  id_massa: number;
  tipo: string;
  preco: number;
}

export interface Cobertura {
  id_cobertura: number;
  tipo: string;
  preco: number;
}

export interface Recheio {
  id_recheio: number;
  tipo: string;
  preco: number;
}

export interface Topping {
  id_topping: number;
  tipo: string;
  preco: number;
}

export interface Pedido {
  pedido_num: number;
  data_h: string;
  valor: number;
  status: 'Pendente' | 'Em Preparo' | 'Entregue' | 'Cancelado';
  cpf_cliente: string;
}

export interface Pagamento {
  id_pagamento: number;
  metodo: string;
  id_pedido: number;
}

export interface EstoqueIngredientes {
  id_estoque: number;
  tipo_ingrediente: 'massa' | 'cobertura' | 'recheio' | 'topping';
  id_ingrediente: number;
  quantidade_disponivel: number;
  quantidade_minima: number;
  data_ultima_atualizacao: string;
}

export interface DonutCobertura {
  id_donut: number;
  id_cobertura: number;
}

export interface DonutRecheio {
  id_donut: number;
  id_recheio: number;
}

export interface DonutTopping {
  id_donut: number;
  id_topping: number;
}

export interface PedidoDonut {
  id_pedido: number;
  id_donut: number;
}

export interface Favorito {
  cpf_cliente: string;
  id_donut: number;
}

export interface AuditoriaPedido {
  id_auditoria: number;
  pedido_num: number;
  status_anterior?: string;
  status_novo?: string;
  data_alteracao: string;
  motivo?: string;
}

export interface DashboardStats {
  totalCustomers: number;
  totalOrders: number;
  pendingOrders: number;
  totalRevenue: number;
  lowStockItems: number;
  recentOrders: Order[];
  statusDistribution: { status: string; count: string }[];
}

export interface DashboardSupplementary {
  totalCustomers: number;
  pendingOrders: number;
  lowStockItems: number;
  recentOrders: Order[];
  statusDistribution: { status: string; count: string }[];
}

export interface SalesReport {
  total_pedidos: number;
  valor_total: number;
  valor_medio: number;
  donut_mais_vendido: string;
  cliente_mais_ativo: string;
  metodo_pagamento_preferido: string;
}