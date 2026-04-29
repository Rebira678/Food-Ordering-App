import { create } from 'zustand';
import { CartItem } from './useCartStore';

export interface Order {
    id: string;
    items: CartItem[];
    total: number;
    tip: number;
    status: 'Placed' | 'Preparing' | 'Delivering' | 'Delivered';
    date: string;
    restaurantName: string;
}

interface OrderStore {
    orders: Order[];
    addOrder: (order: Order) => void;
}

export const useOrderStore = create<OrderStore>((set) => ({
    orders: [],
    addOrder: (order) => set((state) => ({ orders: [order, ...state.orders] })),
}));
