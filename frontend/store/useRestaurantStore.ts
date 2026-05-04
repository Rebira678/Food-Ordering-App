import { create } from 'zustand';
import { RESTAURANTS } from '@/constants/Data';

export interface Restaurant {
    id: number;
    name: string;
    location: string;
    rating?: string | number;
    distance?: string;
    time: string;
    deliveryFee: number;
    image: string;
    tags: string[];
    description: string;
    specialFeature?: string;
    offer?: string;
    categories: any[];
}

interface RestaurantStore {
    restaurants: Restaurant[];
    addRestaurant: (restaurant: Restaurant) => void;
}

export const useRestaurantStore = create<RestaurantStore>((set) => ({
    restaurants: RESTAURANTS,
    addRestaurant: (restaurant) => set((state) => ({
        restaurants: [restaurant, ...state.restaurants]
    })),
}));
