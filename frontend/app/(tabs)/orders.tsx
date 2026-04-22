import React from 'react';
import { View, Text, StyleSheet, SafeAreaView, ScrollView } from 'react-native';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { useOrderStore } from '@/store/useOrderStore';

export default function OrdersScreen() {
    const theme = useColorScheme() ?? 'light';
    const colors = Colors[theme];
    const { orders } = useOrderStore();

    return (
        <SafeAreaView style={[styles.safe, { backgroundColor: colors.background }]}>
            <ScrollView contentContainerStyle={styles.container}>
                <Text style={[styles.header, { color: colors.text }]}>Active Orders</Text>

                {orders.length === 0 ? (
                    <Text style={{ color: colors.icon, textAlign: 'center', marginTop: 20 }}>You have no placed orders yet.</Text>
                ) : (
                    orders.map(order => (
                        <View key={order.id} style={[styles.card, { backgroundColor: colors.card }]}>
                            <Text style={[styles.restaurant, { color: colors.text }]}>{order.restaurantName}</Text>
                            <Text style={{ color: colors.icon, marginBottom: 16 }}>Order #{order.id} • {order.items.length} items • ${(order.total + 2.99 + order.tip).toFixed(2)}</Text>

                            {/* Stepper Timeline */}
                            <View style={styles.timeline}>
                                <View style={styles.step}>
                                    <View style={[styles.dot, { backgroundColor: colors.success }]} />
                                    <View style={[styles.line, { backgroundColor: colors.success }]} />
                                    <Text style={[styles.stepText, { color: colors.success }]}>Placed</Text>
                                </View>
                                <View style={styles.step}>
                                    <View style={[styles.dot, { backgroundColor: colors.primary }]} />
                                    <View style={[styles.line, { backgroundColor: '#E5E7EB' }]} />
                                    <Text style={[styles.stepText, { color: colors.primary, fontWeight: 'bold' }]}>Preparing</Text>
                                </View>
                                <View style={styles.step}>
                                    <View style={[styles.dot, { backgroundColor: '#E5E7EB' }]} />
                                    <Text style={[styles.stepText, { color: colors.icon }]}>Delivering</Text>
                                </View>
                            </View>

                            <View style={[styles.statusBox, { backgroundColor: 'rgba(255, 90, 95, 0.1)', borderColor: 'rgba(255, 90, 95, 0.2)', borderWidth: 1 }]}>
                                <Text style={{ color: colors.primary, fontWeight: 'bold', fontSize: 16 }}>Arriving at {order.date}</Text>
                                <Text style={{ color: colors.text, marginTop: 4 }}>Chef is currently preparing your meal.</Text>
                            </View>
                        </View>
                    ))
                )}
            </ScrollView>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    safe: { flex: 1 },
    container: { padding: 20 },
    header: { fontSize: 24, fontWeight: '800', marginBottom: 16, marginTop: 20 },
    card: { padding: 20, borderRadius: 16, marginBottom: 16, shadowColor: '#000', shadowOpacity: 0.05, shadowRadius: 10, elevation: 2 },
    restaurant: { fontSize: 18, fontWeight: '700', marginBottom: 4 },
    timeline: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 20, paddingHorizontal: 10 },
    step: { alignItems: 'center', width: 60 },
    dot: { width: 16, height: 16, borderRadius: 8, marginBottom: 8, zIndex: 2 },
    line: { position: 'absolute', top: 7, left: 30, right: -40, height: 2, zIndex: 1 },
    stepText: { fontSize: 12 },
    statusBox: { padding: 16, borderRadius: 12, marginTop: 8 },
});
