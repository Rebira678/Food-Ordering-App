import React from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity } from 'react-native';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/use-color-scheme';

export default function RestaurantCard({ restaurant, onPress }: any) {
    const theme = useColorScheme() ?? 'light';
    const colors = Colors[theme];

    return (
        <TouchableOpacity style={[styles.card, { backgroundColor: colors.card }]} onPress={onPress}>
            <Image
                source={{ uri: restaurant.image }}
                style={styles.image}
            />
            <View style={styles.content}>
                <Text style={[styles.name, { color: colors.text }]}>{restaurant.name}</Text>
                <Text style={[styles.details, { color: colors.icon }]}>★ 4.8 • {restaurant.location} • 25-35 min</Text>
            </View>
        </TouchableOpacity>
    );
}

const styles = StyleSheet.create({
    card: {
        borderRadius: 16,
        overflow: 'hidden',
        marginBottom: 16,
        shadowColor: '#000',
        shadowOpacity: 0.05,
        shadowRadius: 10,
        elevation: 2,
    },
    image: {
        width: '100%',
        height: 160,
    },
    content: {
        padding: 16,
    },
    name: {
        fontSize: 18,
        fontWeight: '700',
        marginBottom: 4,
    },
    details: {
        fontSize: 14,
    },
});
