import React from 'react';
import { TouchableOpacity, View, Text, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';
import { useCartStore } from '@/store/useCartStore';

export default function CartIcon() {
    const router = useRouter();
    const items = useCartStore((state) => state.items);

    const totalItems = items.reduce((sum, item) => sum + item.quantity, 0);

    if (totalItems === 0) return null;

    return (
        <TouchableOpacity style={styles.container} onPress={() => router.push('/cart')}>
            <View style={styles.iconBox}>
                <Text style={styles.emoji}>🛒</Text>
                <View style={styles.badge}>
                    <Text style={styles.badgeText}>{totalItems}</Text>
                </View>
            </View>
        </TouchableOpacity>
    );
}

const styles = StyleSheet.create({
    container: {
        position: 'absolute',
        top: 55,
        right: 20,
        zIndex: 1000,
        elevation: 10,
        shadowColor: '#000',
        shadowOpacity: 0.15,
        shadowRadius: 10,
    },
    iconBox: {
        backgroundColor: '#fff',
        width: 46,
        height: 46,
        borderRadius: 23,
        justifyContent: 'center',
        alignItems: 'center',
        shadowColor: '#FF7A00',
        shadowOpacity: 0.2,
        shadowRadius: 5,
        elevation: 5,
    },
    emoji: {
        fontSize: 20,
    },
    badge: {
        position: 'absolute',
        top: -5,
        right: -5,
        backgroundColor: '#FF7A00',
        width: 20,
        height: 20,
        borderRadius: 10,
        justifyContent: 'center',
        alignItems: 'center',
        borderWidth: 2,
        borderColor: '#fff',
    },
    badgeText: {
        color: '#fff',
        fontSize: 10,
        fontWeight: 'bold',
    }
});
