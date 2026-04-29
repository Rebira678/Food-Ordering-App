import React from 'react';
import { View, Text, StyleSheet, ScrollView, SafeAreaView, TouchableOpacity } from 'react-native';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { useAuthStore } from '@/store/useAuthStore';
import { RESTAURANTS } from '@/constants/Data';
import Toast from 'react-native-root-toast';

export default function SuperAdminDashboard() {
    const theme = useColorScheme() ?? 'light';
    const colors = Colors[theme];
    const { logout } = useAuthStore();

    const handleAction = (msg: string) => {
        Toast.show(`SuperAdmin Action Triggered: ${msg}`, { backgroundColor: colors.primary, duration: Toast.durations.SHORT });
    };

    return (
        <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
            <ScrollView contentContainerStyle={styles.container}>
                <View style={styles.header}>
                    <Text style={[styles.title, { color: colors.text }]}>Platform Command</Text>
                    <Text style={[styles.subtitle, { color: colors.icon }]}>Super Admin Access Only</Text>
                </View>

                <Text style={[styles.sectionTitle, { color: colors.text }]}>Global Actions</Text>
                <View style={styles.actionGrid}>
                    <TouchableOpacity style={[styles.actionBtn, { backgroundColor: colors.card }]} onPress={() => handleAction('Launch Native "Add Hotel" Editor')}>
                        <Text style={[styles.actionText, { color: colors.text }]}>+ Add Hotel/Restaurant</Text>
                    </TouchableOpacity>
                    <TouchableOpacity style={[styles.actionBtn, { backgroundColor: colors.card }]} onPress={() => handleAction('Launch Menu & Pricing Configuration')}>
                        <Text style={[styles.actionText, { color: colors.text }]}>+ Manage Foods & Prices</Text>
                    </TouchableOpacity>
                </View>

                <Text style={[styles.sectionTitle, { color: colors.text, marginTop: 20 }]}>Active Partnerships ({RESTAURANTS.length})</Text>
                <Text style={{ color: colors.icon, marginBottom: 12 }}>You have tracking access. Detailed order history is hidden for privacy.</Text>

                {RESTAURANTS.map((restaurant) => (
                    <View key={restaurant.id} style={[styles.restaurantCard, { backgroundColor: colors.card }]}>
                        <View>
                            <Text style={[styles.restaurantName, { color: colors.text }]}>{restaurant.name}</Text>
                            <Text style={{ color: colors.icon }}>{restaurant.location} • ★ {restaurant.rating}</Text>
                        </View>
                        <TouchableOpacity
                            style={[styles.manageBtn, { backgroundColor: 'rgba(255, 122, 0, 0.1)' }]}
                            onPress={() => handleAction(`Edit details for ${restaurant.name}`)}
                        >
                            <Text style={{ color: colors.primary, fontWeight: 'bold' }}>Manage</Text>
                        </TouchableOpacity>
                    </View>
                ))}

                <TouchableOpacity
                    style={[styles.logoutBtn, { borderColor: colors.primary, marginTop: 30 }]}
                    onPress={() => logout()}
                >
                    <Text style={[styles.logoutText, { color: colors.primary }]}>Exit Admin Portal</Text>
                </TouchableOpacity>
            </ScrollView>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: { padding: 20, paddingTop: 40, paddingBottom: 100 },
    header: { marginBottom: 30 },
    title: { fontSize: 28, fontWeight: '900' },
    subtitle: { fontSize: 16, fontWeight: '600', color: '#EF4444' }, // Red to imply highly permissive access
    sectionTitle: { fontSize: 18, fontWeight: '800', marginBottom: 12 },
    actionGrid: { gap: 12, marginBottom: 30 },
    actionBtn: { padding: 20, borderRadius: 12, shadowColor: '#000', shadowOpacity: 0.05, shadowRadius: 5, elevation: 1 },
    actionText: { fontSize: 16, fontWeight: 'bold', color: '#FF7A00' },
    restaurantCard: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', padding: 16, borderRadius: 12, marginBottom: 12, shadowColor: '#000', shadowOpacity: 0.05, shadowRadius: 5, elevation: 1 },
    restaurantName: { fontSize: 18, fontWeight: '800', marginBottom: 4 },
    manageBtn: { paddingHorizontal: 16, paddingVertical: 8, borderRadius: 8 },
    logoutBtn: { padding: 16, borderRadius: 12, borderWidth: 1, alignItems: 'center' },
    logoutText: { fontSize: 16, fontWeight: 'bold' }
});
