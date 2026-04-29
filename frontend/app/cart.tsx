import React, { useState } from 'react';
import { View, Text, ScrollView, StyleSheet, TouchableOpacity, TextInput, Alert, KeyboardAvoidingView, Platform } from 'react-native';
import { useRouter } from 'expo-router';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { useCartStore } from '@/store/useCartStore';
import { useAuthStore } from '@/store/useAuthStore';
import { useOrderStore } from '@/store/useOrderStore';
import * as Haptics from 'expo-haptics';
import Toast from 'react-native-root-toast';

export default function CartScreen() {
    const router = useRouter();
    const theme = useColorScheme() ?? 'light';
    const colors = Colors[theme];
    const cartStore = useCartStore();
    const orderStore = useOrderStore();
    const { user } = useAuthStore();

    const [name, setName] = useState(user?.name || '');
    const [addressOption, setAddressOption] = useState<'profile' | 'new'>('profile');
    const [newAddress, setNewAddress] = useState('');
    const [screenshotUri, setScreenshotUri] = useState<string | null>(null);
    const [tipAmount, setTipAmount] = useState(0);

    const handlePickImage = async () => {
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
        setScreenshotUri('https://images.unsplash.com/photo-1563013544-824ae1b704d3?auto=format&fit=crop&w=400&q=80');
        Toast.show('✅ Payment Proof Uploaded', { duration: Toast.durations.SHORT, backgroundColor: colors.success });
    };

    const handleCheckout = () => {
        if (!name.trim()) {
            Alert.alert('Required', 'Please enter your name for the order.');
            return;
        }
        const activeAddress = addressOption === 'profile' ? user?.address : newAddress;
        if (!activeAddress || !activeAddress.trim()) {
            Alert.alert('Required', 'Please provide a valid delivery address.');
            return;
        }
        if (!screenshotUri) {
            Alert.alert('Required', 'Please upload a screenshot of your payment receipt.');
            return;
        }

        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
        orderStore.addOrder({
            id: 'ORD' + Math.floor(Math.random() * 10000),
            items: cartStore.items,
            total: cartStore.getTotal(),
            tip: tipAmount,
            status: 'Placed',
            date: new Date().toLocaleTimeString(),
            restaurantName: cartStore.items[0]?.restaurantName || 'Restaurant'
        });

        cartStore.clearCart();
        Toast.show('🎉 Order Placed Successfully! Will arrive soon.', { duration: Toast.durations.LONG, position: Toast.positions.CENTER });
        router.replace('/(tabs)/orders' as any);
    };

    return (
        <KeyboardAvoidingView style={{ flex: 1, backgroundColor: colors.background }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
            <View style={styles.header}>
                <TouchableOpacity style={styles.backButton} onPress={() => router.back()}>
                    <Text style={{ color: colors.text, fontSize: 24, fontWeight: 'bold' }}>←</Text>
                </TouchableOpacity>
                <Text style={[styles.headerTitle, { color: colors.text }]}>Let's Feast! 🍽️</Text>
                <View style={{ width: 40 }} />
            </View>

            <ScrollView contentContainerStyle={styles.scrollContent}>
                {cartStore.items.length === 0 ? (
                    <Text style={{ textAlign: 'center', marginTop: 50, color: colors.icon }}>Your cart is empty.</Text>
                ) : (
                    <>
                        <Text style={[styles.sectionTitle, { color: colors.text }]}>Your Items</Text>
                        {cartStore.items.map((item, index) => (
                            <View key={`${item.id}-${index}`} style={[styles.cartItem, { backgroundColor: colors.card }]}>
                                <View style={styles.qtyBox}><Text style={{ color: colors.primary, fontWeight: 'bold' }}>{item.quantity}x</Text></View>
                                <View style={{ flex: 1, marginHorizontal: 12 }}>
                                    <Text style={[styles.itemName, { color: colors.text }]}>{item.name}</Text>
                                    <Text style={{ color: colors.icon, fontSize: 12, marginBottom: 2 }}>from {item.restaurantName || 'Restaurant'}</Text>
                                    <Text style={{ color: colors.icon }}>${item.price.toFixed(2)}</Text>
                                </View>
                                <Text style={[styles.itemTotal, { color: colors.text }]}>${(item.price * item.quantity).toFixed(2)}</Text>
                            </View>
                        ))}

                        <View style={styles.deliveryBox}>
                            <Text style={{ fontSize: 16, fontWeight: 'bold', color: colors.text }}>Estimated Delivery Time</Text>
                            <Text style={{ fontSize: 14, color: colors.primary, marginTop: 4 }}>35 - 45 Minutes on average</Text>
                        </View>

                        <View style={styles.summaryBox}>
                            <View style={styles.row}>
                                <Text style={{ color: colors.icon, fontSize: 16 }}>Subtotal</Text>
                                <Text style={{ color: colors.text, fontSize: 16 }}>${cartStore.getTotal().toFixed(2)}</Text>
                            </View>
                            <View style={styles.row}>
                                <Text style={{ color: colors.icon, fontSize: 16 }}>Delivery Fee</Text>
                                <Text style={{ color: colors.text, fontSize: 16 }}>$2.99</Text>
                            </View>
                            <View style={[styles.row, { marginTop: 10 }]}>
                                <Text style={{ color: colors.icon, fontSize: 16 }}>Tip for driver (100% goes to them!)</Text>
                                <Text style={{ color: colors.text, fontSize: 16 }}>${tipAmount.toFixed(2)}</Text>
                            </View>
                            <View style={{ flexDirection: 'row', gap: 10, marginVertical: 15 }}>
                                {[0, 2, 5, 10].map(tip => (
                                    <TouchableOpacity key={tip} style={[styles.tipBtn, tipAmount === tip && { backgroundColor: colors.primary }]} onPress={() => setTipAmount(tip)}>
                                        <Text style={{ color: tipAmount === tip ? '#fff' : colors.text, fontWeight: 'bold' }}>${tip}</Text>
                                    </TouchableOpacity>
                                ))}
                            </View>
                            <View style={[styles.row, { marginTop: 12, borderTopWidth: 1, borderTopColor: 'rgba(0,0,0,0.1)', paddingTop: 12 }]}>
                                <Text style={{ color: colors.text, fontSize: 20, fontWeight: 'bold' }}>Total</Text>
                                <Text style={{ color: colors.primary, fontSize: 20, fontWeight: 'bold' }}>${(cartStore.getTotal() + 2.99 + tipAmount).toFixed(2)}</Text>
                            </View>
                        </View>

                        <Text style={[styles.sectionTitle, { color: colors.text, marginTop: 24 }]}>Delivery Details</Text>
                        <TextInput
                            style={[styles.input, { backgroundColor: colors.card, color: colors.text }]}
                            placeholder="Full Name (for order delivery)"
                            placeholderTextColor={colors.icon}
                            value={name}
                            onChangeText={setName}
                        />

                        <View style={styles.addressToggle}>
                            <TouchableOpacity style={[styles.addressBtn, addressOption === 'profile' && { backgroundColor: colors.primary }]} onPress={() => setAddressOption('profile')}>
                                <Text style={{ color: addressOption === 'profile' ? '#fff' : colors.text, fontWeight: 'bold' }}>Profile Address</Text>
                            </TouchableOpacity>
                            <TouchableOpacity style={[styles.addressBtn, addressOption === 'new' && { backgroundColor: colors.text }]} onPress={() => setAddressOption('new')}>
                                <Text style={{ color: addressOption === 'new' ? colors.background : colors.text, fontWeight: 'bold' }}>New Address</Text>
                            </TouchableOpacity>
                        </View>

                        {addressOption === 'profile' ? (
                            <Text style={{ color: colors.icon, marginBottom: 16, paddingLeft: 4 }}>Delivering to: {user?.address || 'No address recorded. Please add one.'}</Text>
                        ) : (
                            <TextInput
                                style={[styles.input, { backgroundColor: colors.card, color: colors.text }]}
                                placeholder="Enter specific delivery address"
                                placeholderTextColor={colors.icon}
                                value={newAddress}
                                onChangeText={setNewAddress}
                            />
                        )}

                        <Text style={[styles.sectionTitle, { color: colors.text, marginTop: 16 }]}>Payment Verification</Text>
                        <TouchableOpacity style={[styles.uploadButton, { borderColor: colors.primary }]} onPress={handlePickImage}>
                            <Text style={{ color: colors.primary, fontWeight: 'bold' }}>
                                {screenshotUri ? '✅ Payment Screenshot Uploaded' : '📤 Upload Payment Screenshot'}
                            </Text>
                        </TouchableOpacity>

                        <Text style={{ color: colors.icon, fontSize: 12, marginTop: 8, textAlign: 'center' }}>
                            Please transfer ${(cartStore.getTotal() + 2.99 + tipAmount).toFixed(2)} to our bank and upload the receipt proof above to finalize. We will cook it with love! ❤️
                        </Text>
                    </>
                )}
            </ScrollView>

            {cartStore.items.length > 0 && (
                <TouchableOpacity style={[styles.checkoutBtn, { backgroundColor: colors.primary }]} onPress={handleCheckout}>
                    <Text style={styles.checkoutBtnText}>Confirm Order • ${(cartStore.getTotal() + 2.99 + tipAmount).toFixed(2)}</Text>
                </TouchableOpacity>
            )}
        </KeyboardAvoidingView >
    );
}

const styles = StyleSheet.create({
    header: {
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingHorizontal: 20,
        paddingTop: 60,
        paddingBottom: 20,
        backgroundColor: 'transparent',
    },
    headerTitle: { fontSize: 20, fontWeight: 'bold' },
    backButton: { width: 40, height: 40, justifyContent: 'center' },
    scrollContent: { padding: 20, paddingBottom: 150 },
    sectionTitle: { fontSize: 18, fontWeight: '800', marginBottom: 12 },
    cartItem: { flexDirection: 'row', alignItems: 'center', padding: 16, borderRadius: 12, marginBottom: 12 },
    qtyBox: { width: 32, height: 32, borderRadius: 8, backgroundColor: '#FFE8D6', justifyContent: 'center', alignItems: 'center' },
    itemName: { fontSize: 16, fontWeight: '600' },
    itemTotal: { fontSize: 16, fontWeight: 'bold' },
    summaryBox: { padding: 20, borderRadius: 16, backgroundColor: 'rgba(0,0,0,0.02)' },
    row: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: 8 },
    deliveryBox: { padding: 16, borderRadius: 12, backgroundColor: 'rgba(0,168,107,0.1)', marginBottom: 20, marginTop: 10, borderWidth: 1, borderColor: 'rgba(0,168,107,0.3)' },
    addressToggle: { flexDirection: 'row', borderRadius: 12, padding: 4, marginBottom: 16, backgroundColor: 'rgba(0,0,0,0.05)' },
    addressBtn: { flex: 1, paddingVertical: 12, borderRadius: 8, alignItems: 'center' },
    input: { height: 50, borderRadius: 12, paddingHorizontal: 16, fontSize: 16, marginBottom: 16, shadowColor: '#000', shadowOpacity: 0.05, shadowRadius: 5, elevation: 1 },
    uploadButton: { height: 50, borderRadius: 12, borderWidth: 2, borderStyle: 'dashed', justifyContent: 'center', alignItems: 'center', backgroundColor: 'transparent' },
    tipBtn: { flex: 1, paddingVertical: 10, borderRadius: 8, backgroundColor: 'rgba(0,0,0,0.05)', alignItems: 'center' },
    checkoutBtn: { position: 'absolute', bottom: 30, left: 20, right: 20, padding: 20, borderRadius: 30, alignItems: 'center', shadowColor: '#000', shadowOpacity: 0.3, shadowRadius: 10, elevation: 5 },
    checkoutBtnText: { color: '#fff', fontSize: 18, fontWeight: '900', letterSpacing: 0.5 },
});
