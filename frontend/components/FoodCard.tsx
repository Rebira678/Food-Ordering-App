import React from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity } from 'react-native';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/use-color-scheme';

export default function FoodCard({ food, onAdd }: any) {
    const theme = useColorScheme() ?? 'light';
    const colors = Colors[theme];

    return (
        <View style={[styles.card, { backgroundColor: colors.card }]}>
            <View style={styles.textContainer}>
                <Text style={[styles.name, { color: colors.text }]}>{food.name}</Text>
                {food.description && (
                    <Text style={[styles.description, { color: colors.icon }]} numberOfLines={2}>
                        {food.description}
                    </Text>
                )}
                <Text style={[styles.price, { color: colors.primary }]}>${food.price.toFixed(2)}</Text>
            </View>
            <TouchableOpacity onPress={onAdd}>
                <Image
                    source={{ uri: food.image || 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=200&q=80' }}
                    style={styles.image}
                />
                <View style={[styles.addButton, { backgroundColor: colors.primary }]}>
                    <Text style={styles.addText}>+</Text>
                </View>
            </TouchableOpacity>
        </View>
    );
}

const styles = StyleSheet.create({
    card: {
        flexDirection: 'row',
        padding: 16,
        borderBottomWidth: 1,
        borderBottomColor: 'rgba(0,0,0,0.05)',
    },
    textContainer: {
        flex: 1,
        paddingRight: 16,
    },
    name: {
        fontSize: 16,
        fontWeight: '700',
        marginBottom: 4,
    },
    description: {
        fontSize: 14,
        marginBottom: 8,
        lineHeight: 20,
    },
    price: {
        fontSize: 16,
        fontWeight: '600',
    },
    image: {
        width: 100,
        height: 100,
        borderRadius: 12,
    },
    addButton: {
        position: 'absolute',
        bottom: -10,
        right: 30,
        width: 40,
        height: 40,
        borderRadius: 20,
        justifyContent: 'center',
        alignItems: 'center',
        elevation: 3,
        shadowColor: '#000',
        shadowOpacity: 0.2,
        shadowRadius: 5,
    },
    addText: {
        color: '#fff',
        fontSize: 24,
        fontWeight: 'bold',
        marginTop: -2,
    },
});
