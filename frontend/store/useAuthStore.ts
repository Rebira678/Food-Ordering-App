import { create } from 'zustand';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface User {
    id: number;
    name: string;
    email: string;
    role?: string;
    address?: string;
    referralCode?: string;
    availableDiscounts?: number[]; // list of restaurant IDs where discount is available
    pushEnabled?: boolean;
    emailEnabled?: boolean;
}

interface AuthStore {
    token: string | null;
    user: User | null;
    setAuth: (token: string, user: User) => Promise<void>;
    updateUser: (partialUser: Partial<User>) => Promise<void>;
    logout: () => Promise<void>;
}

export const useAuthStore = create<AuthStore>((set, get) => ({
    token: null,
    user: null,
    setAuth: async (token, user) => {
        await AsyncStorage.setItem('token', token);
        await AsyncStorage.setItem('user', JSON.stringify(user));
        set({ token, user });
    },
    updateUser: async (partialUser) => {
        const currentUser = get().user;
        if (!currentUser) return;
        const updatedUser = { ...currentUser, ...partialUser };
        await AsyncStorage.setItem('user', JSON.stringify(updatedUser));
        set({ user: updatedUser });
    },
    logout: async () => {
        await AsyncStorage.removeItem('token');
        await AsyncStorage.removeItem('user');
        set({ token: null, user: null });
    },
}));
