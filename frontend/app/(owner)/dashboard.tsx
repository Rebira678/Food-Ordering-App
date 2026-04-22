import React from 'react';
import { View, Text, StyleSheet, ScrollView, SafeAreaView, TouchableOpacity, Dimensions } from 'react-native';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'expo-router';
import { LineChart } from 'react-native-chart-kit';

export default function OwnerDashboard() {
    const theme = useColorScheme() ?? 'light';
    const colors = Colors[theme];
    const { user, logout } = useAuthStore();
    const router = useRouter();

    const handleLogout = () => {
        logout();
        router.replace('/auth');
    };

    const mockStats = {
        todayRevenue: 845.50,
        totalRevenue: 24500.00,
        ordersToday: 34,
        popularItems: [
            { name: 'Truffle Burger', sold: 12 },
            { name: 'Vegan Bowl', sold: 8 },
            { name: 'Sweet Potato Fries', sold: 5 },
            { name: 'Margherita Pizza', sold: 4 }
        ]
    };

    return (
        <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
            <ScrollView contentContainerStyle={styles.container}>
                <View style={styles.header}>
                    <Text style={[styles.title, { color: colors.text }]}>Welcome back,</Text>
                    <Text style={[styles.restaurantName, { color: colors.primary }]}>{user?.name} Restaurant</Text>
                </View>

                <Text style={[styles.sectionTitle, { color: colors.text, marginBottom: 12 }]}>Today's Growth</Text>

                <View style={{ alignItems: 'center', marginBottom: 25 }}>
                    <LineChart
                        data={{
                            labels: ["Jul 11 (Mon)", "Jul 12 (Tue)", "Jul 13 (Wed)", "Jul 14 (Thu)", "Jul 15 (Fri)", "Today"],
                            datasets: [{ data: [120, 350, 410, 520, 780, 845.50] }]
                        }}
                        width={Dimensions.get("window").width - 40}
                        height={220}
                        yAxisLabel="$"
                        chartConfig={{
                            backgroundColor: colors.card,
                            backgroundGradientFrom: colors.card,
                            backgroundGradientTo: colors.card,
                            decimalPlaces: 0,
                            color: (opacity = 1) => `rgba(255, 122, 0, ${opacity})`,
                            labelColor: (opacity = 1) => colors.text,
                            style: { borderRadius: 16 },
                            propsForDots: { r: "5", strokeWidth: "2", stroke: "#ffa726" }
                        }}
                        bezier
                        style={{ marginVertical: 8, borderRadius: 16, shadowColor: '#000', shadowOpacity: 0.05, shadowRadius: 5, elevation: 1 }}
                    />
                </View>

                <View style={styles.metricsGrid}>
                    <View style={[styles.metricCard, { backgroundColor: colors.card }]}>
                        <Text style={[styles.metricLabel, { color: colors.icon }]}>Today's Revenue</Text>
                        <Text style={[styles.metricValue, { color: colors.text }]}>${mockStats.todayRevenue.toFixed(2)}</Text>
                    </View>
                    <View style={[styles.metricCard, { backgroundColor: colors.card }]}>
                        <Text style={[styles.metricLabel, { color: colors.icon }]}>Orders Today</Text>
                        <Text style={[styles.metricValue, { color: colors.text }]}>{mockStats.ordersToday}</Text>
                    </View>
                </View>

                <Text style={[styles.sectionTitle, { color: colors.text }]}>Most Ordered Items</Text>
                <Text style={{ color: colors.icon, marginBottom: 12 }}>Distribution over the last 24 hours</Text>

                <View style={[styles.listCard, { backgroundColor: colors.card }]}>
                    {mockStats.popularItems.map((item, idx) => (
                        <View key={idx} style={[styles.listItem, idx < mockStats.popularItems.length - 1 && { borderBottomColor: 'rgba(0,0,0,0.05)', borderBottomWidth: 1 }]}>
                            <Text style={[styles.itemName, { color: colors.text }]}>{item.name}</Text>
                            <Text style={[styles.itemSold, { color: colors.primary }]}>{item.sold} orders</Text>
                        </View>
                    ))}
                </View>

                <TouchableOpacity
                    style={[styles.logoutBtn, { borderColor: colors.primary }]}
                    onPress={handleLogout}
                >
                    <Text style={[styles.logoutText, { color: colors.primary }]}>Sign Out of Dashboard</Text>
                </TouchableOpacity>
            </ScrollView>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: { padding: 20, paddingTop: 40, paddingBottom: 100 },
    header: { marginBottom: 20 },
    title: { fontSize: 24, fontWeight: '600' },
    restaurantName: { fontSize: 32, fontWeight: '800' },
    metricsGrid: { flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'space-between', marginBottom: 30 },
    metricCard: { width: '48%', padding: 20, borderRadius: 16, shadowColor: '#000', shadowOpacity: 0.05, shadowRadius: 5, elevation: 1 },
    metricLabel: { fontSize: 13, fontWeight: '700', textTransform: 'uppercase', marginBottom: 8 },
    metricValue: { fontSize: 24, fontWeight: '800' },
    sectionTitle: { fontSize: 20, fontWeight: 'bold' },
    listCard: { borderRadius: 16, padding: 16, marginBottom: 40, shadowColor: '#000', shadowOpacity: 0.05, shadowRadius: 5, elevation: 1 },
    listItem: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 14 },
    itemName: { fontSize: 16, fontWeight: '600' },
    itemSold: { fontSize: 16, fontWeight: '800' },
    logoutBtn: { padding: 16, borderRadius: 12, borderWidth: 1, alignItems: 'center' },
    logoutText: { fontSize: 16, fontWeight: 'bold' }
});
