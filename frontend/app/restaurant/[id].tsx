import React, { useState } from 'react';
import { View, Text, StyleSheet, Image, TouchableOpacity, TextInput, KeyboardAvoidingView, Platform } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/use-color-scheme';
import FoodCard from '@/components/FoodCard';
import CartIcon from '@/components/CartIcon';
import ParallaxScrollView from '@/components/parallax-scroll-view';
import { useCartStore } from '@/store/useCartStore';
import { RESTAURANTS } from '@/constants/Data';
import * as Haptics from 'expo-haptics';
import Toast from 'react-native-root-toast';
import { useAuthStore } from '@/store/useAuthStore';

export default function RestaurantDetail() {
    const { id } = useLocalSearchParams();
    const router = useRouter();
    const theme = useColorScheme() ?? 'light';
    const colors = Colors[theme];
    const cartStore = useCartStore();
    const { user } = useAuthStore();
    const [searchQuery, setSearchQuery] = useState('');
    const [isSearchFocused, setIsSearchFocused] = useState(false);

    const restaurant = RESTAURANTS.find(r => r.id.toString() === id);

    if (!restaurant) return <Text style={{ marginTop: 50, textAlign: 'center', color: colors.text }}>Restaurant not found</Text>;

    const filteredCategories = restaurant.categories.map(cat => ({
        ...cat,
        items: cat.items.filter(item => item.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            (item.description && item.description.toLowerCase().includes(searchQuery.toLowerCase())))
    })).filter(cat => cat.items.length > 0);

    const handleAddToCart = (item: any) => {
        Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
        cartStore.addItem({ ...item, quantity: 1, restaurantName: restaurant.name });

        Toast.show(`Added ${item.name} to cart 🛒`, {
            duration: Toast.durations.SHORT,
            position: Toast.positions.TOP,
            shadow: true,
            animation: true,
            hideOnPress: true,
            backgroundColor: colors.success,
            textColor: '#fff',
            containerStyle: { marginTop: 45, borderRadius: 20, paddingHorizontal: 20 },
        });
    };

    return (
        <KeyboardAvoidingView style={{ flex: 1, backgroundColor: colors.background }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
            <CartIcon />

            {/* Sticky Header with Search Bar to Prevent Keyboard Blockage */}
            <View style={{ paddingTop: 50, paddingHorizontal: 20, paddingBottom: 15, flexDirection: 'row', alignItems: 'center', backgroundColor: colors.background, zIndex: 10, shadowColor: '#000', shadowOpacity: 0.05, shadowRadius: 5, elevation: 2 }}>
                <TouchableOpacity style={styles.backButtonInline} onPress={() => router.back()}>
                    <Text style={{ color: colors.text, fontSize: 24, fontWeight: 'bold' }}>←</Text>
                </TouchableOpacity>
                <View style={[styles.stickySearchBar, { backgroundColor: theme === 'dark' ? '#2A2D34' : '#F3F4F6', borderWidth: 0 }]}>
                    <Text style={{ fontSize: 20, marginRight: 12 }}>🔍</Text>
                    <TextInput
                        style={[{ flex: 1, color: colors.text, fontSize: 16, height: '100%' }, Platform.select({ web: { outline: 'none' } as any, default: {} })]}
                        placeholder={`Craving something from ${restaurant.name}?`}
                        placeholderTextColor={theme === 'dark' ? '#9CA3AF' : '#6B7280'}
                        value={searchQuery}
                        onChangeText={setSearchQuery}
                        onFocus={() => setIsSearchFocused(true)}
                        onBlur={() => setIsSearchFocused(false)}
                    />
                </View>
            </View>

            <ParallaxScrollView
                isHeaderHidden={isSearchFocused}
                headerBackgroundColor={{ light: colors.card, dark: colors.card }}
                headerImage={
                    <Image source={{ uri: restaurant.image }} style={styles.heroImage} />
                }>

                {(!isSearchFocused && !searchQuery) && (
                    <View style={[styles.infoSection, { backgroundColor: colors.background, shadowColor: '#000', shadowOffset: { width: 0, height: -10 }, shadowOpacity: 0.1, shadowRadius: 20, elevation: 10 }]}>
                        <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 }}>
                            <Text style={[styles.title, { color: colors.text, flex: 1 }]} numberOfLines={2}>{restaurant.name}</Text>
                            <View style={{ backgroundColor: colors.primary, paddingHorizontal: 12, paddingVertical: 6, borderRadius: 20 }}>
                                <Text style={{ color: '#fff', fontWeight: 'bold', fontSize: 14 }}>★ {restaurant.rating}</Text>
                            </View>
                        </View>

                        <Text style={[styles.subtitle, { color: colors.icon }]}>📍 {restaurant.location} • {restaurant.reviews} reviews</Text>

                        <View style={{ flexDirection: 'row', alignItems: 'center', marginVertical: 12 }}>
                            <View style={{ backgroundColor: 'rgba(255, 122, 0, 0.1)', paddingHorizontal: 12, paddingVertical: 6, borderRadius: 8, marginRight: 8 }}>
                                <Text style={[styles.deliveryInfo, { color: colors.primary }]}>⏱ {restaurant.time}</Text>
                            </View>
                            <View style={{ backgroundColor: 'rgba(0, 0, 0, 0.05)', paddingHorizontal: 12, paddingVertical: 6, borderRadius: 8 }}>
                                <Text style={[{ color: colors.text, fontWeight: '600' }]}>🛵 ${restaurant.deliveryFee} Delivery</Text>
                            </View>
                        </View>

                        {/* New Details */}
                        {restaurant.offer && (
                            <View style={{ backgroundColor: '#FEF3C7', padding: 12, borderRadius: 12, marginTop: 10, borderWidth: 1, borderColor: '#FDE68A' }}>
                                <Text style={{ color: '#D97706', fontWeight: '800', letterSpacing: 0.5 }}>🔥 EXCLUSIVE OFFER</Text>
                                <Text style={{ color: '#92400E', marginTop: 4 }}>{restaurant.offer}</Text>
                            </View>
                        )}

                        {user?.availableDiscounts && user.availableDiscounts.includes(restaurant.id) && (
                            <View style={{ backgroundColor: '#D1FAE5', padding: 12, borderRadius: 12, marginTop: 10, borderWidth: 1, borderColor: '#A7F3D0' }}>
                                <Text style={{ color: '#059669', fontWeight: 'bold' }}>✅ First-Time Rating Discount Available!</Text>
                            </View>
                        )}

                        <View style={{ marginVertical: 20 }}>
                            <Text style={{ fontSize: 18, fontWeight: '800', color: colors.text, marginBottom: 8 }}>About Us</Text>
                            <Text style={{ fontSize: 15, color: colors.text, lineHeight: 24, opacity: 0.8 }}>
                                {restaurant.description}
                            </Text>
                        </View>

                        {restaurant.specialFeature && (
                            <View style={{ backgroundColor: colors.card, padding: 16, borderRadius: 12, marginBottom: 20, borderLeftWidth: 4, borderLeftColor: colors.primary }}>
                                <Text style={{ fontSize: 14, color: colors.icon, fontStyle: 'italic', fontWeight: '500' }}>
                                    ✨ {restaurant.specialFeature}
                                </Text>
                            </View>
                        )}

                        <TouchableOpacity style={{ marginTop: 5, padding: 14, borderColor: colors.primary, borderWidth: 1.5, borderRadius: 12, alignItems: 'center', backgroundColor: 'transparent' }}>
                            <Text style={{ color: colors.primary, fontWeight: 'bold', fontSize: 16, letterSpacing: 0.5 }}>⭐ RATE YOUR PREVIOUS ORDER</Text>
                        </TouchableOpacity>
                    </View>
                )}

                {filteredCategories.length === 0 ? (
                    <Text style={{ color: colors.icon, marginTop: 20, textAlign: 'center' }}>No items found.</Text>
                ) : (
                    filteredCategories.map((category, idx) => (
                        <View key={idx} style={styles.categorySection}>
                            <Text style={[styles.categoryTitle, { color: colors.text }]}>{category.name}</Text>
                            {category.items.map((item) => (
                                <FoodCard
                                    key={item.id}
                                    food={item}
                                    onAdd={() => handleAddToCart(item)}
                                />
                            ))}
                        </View>
                    ))
                )}
            </ParallaxScrollView>

            {cartStore.items.length > 0 && (
                <TouchableOpacity style={styles.floatingCart} onPress={() => router.push('/cart')}>
                    <View style={[styles.cartInner, { backgroundColor: colors.primary }]}>
                        <View style={styles.badge}><Text style={styles.badgeText}>{cartStore.items.length}</Text></View>
                        <Text style={styles.cartText}>View Cart</Text>
                        <Text style={styles.cartPrice}>${cartStore.getTotal().toFixed(2)}</Text>
                    </View>
                </TouchableOpacity>
            )}
        </KeyboardAvoidingView>
    );
}

const styles = StyleSheet.create({
    heroImage: { width: '100%', height: '100%', position: 'absolute', bottom: 0 },
    backButtonInline: { width: 40, height: 40, justifyContent: 'center' },
    stickySearchBar: { flex: 1, height: 60, borderRadius: 30, paddingHorizontal: 24, flexDirection: 'row', alignItems: 'center', shadowColor: '#000', shadowOpacity: 0.05, shadowRadius: 10, elevation: 1, borderWidth: 0 },
    searchInput: { flex: 1, fontSize: 16, height: '100%', ...Platform.select({ web: { outline: 'none' } } as any) },
    infoSection: { paddingTop: 24, paddingHorizontal: 20, borderTopLeftRadius: 30, borderTopRightRadius: 30, marginTop: -30, paddingBottom: 20 },
    title: { fontSize: 28, fontWeight: '900', letterSpacing: -0.5 },
    subtitle: { fontSize: 16, marginBottom: 4, fontWeight: '500' },
    deliveryInfo: { fontSize: 14, fontWeight: '700' },
    categorySection: { marginTop: 15, paddingBottom: 15, paddingHorizontal: 20 },
    categoryTitle: { fontSize: 22, fontWeight: '800', paddingBottom: 15, paddingTop: 10, letterSpacing: -0.5 },
    floatingCart: { position: 'absolute', bottom: 30, left: 20, right: 20, shadowColor: '#FF7A00', shadowOpacity: 0.3, shadowRadius: 10, elevation: 5 },
    cartInner: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', padding: 16, borderRadius: 30 },
    badge: { backgroundColor: '#fff', width: 28, height: 28, borderRadius: 14, justifyContent: 'center', alignItems: 'center' },
    badgeText: { color: '#FF7A00', fontWeight: 'bold' },
    cartText: { color: '#fff', fontSize: 18, fontWeight: '700' },
    cartPrice: { color: '#fff', fontSize: 18, fontWeight: 'bold' },
});
