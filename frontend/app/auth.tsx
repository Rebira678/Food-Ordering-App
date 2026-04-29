import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, TextInput, KeyboardAvoidingView, Platform, SafeAreaView, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { useAuthStore } from '@/store/useAuthStore';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/use-color-scheme';

export default function AuthScreen() {
    const router = useRouter();
    const setAuth = useAuthStore((state) => state.setAuth);
    const theme = useColorScheme() ?? 'light';
    const colors = Colors[theme];

    const [role, setRole] = useState<'customer' | 'restaurant'>('customer');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [address, setAddress] = useState('');
    const [referralCode, setReferralCode] = useState('');
    const [isSignUp, setIsSignUp] = useState(false);

    const handleLogin = async () => {
        if (!email.trim() || !password.trim()) return;
        if (role === 'customer' && isSignUp && !address.trim()) {
            alert("Please provide a home address for delivery.");
            return;
        }

        if (email.toLowerCase() === 'admin@saffroneats.com') {
            await setAuth('mock-jwt-token', {
                id: 0, name: 'Platform Administrator', email: email, role: 'superadmin'
            });
            router.replace('/(superadmin)/dashboard' as any);
            return;
        }

        let newReferralCode = "";
        let initialDiscounts: number[] = [];

        if (isSignUp) {
            newReferralCode = Math.random().toString(36).substring(2, 8).toUpperCase();
            initialDiscounts = referralCode.trim() ? [1, 2, 3, 4] : [];
        }

        await setAuth('mock-jwt-token', {
            id: Math.floor(Math.random() * 1000),
            name: email.split('@')[0],
            email: email,
            role: role,
            address: role === 'customer' ? address : undefined,
            referralCode: newReferralCode,
            availableDiscounts: initialDiscounts
        });

        if (role === 'customer') {
            router.replace('/(tabs)' as any);
        } else {
            router.replace('/(owner)/dashboard' as any);
        }
    };

    return (
        <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
            <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={{ flex: 1 }}>
                <ScrollView contentContainerStyle={styles.container}>
                    <View style={styles.header}>
                        <Text style={[styles.title, { color: colors.primary }]}>Saffron<Text style={{ color: colors.text }}>Eats</Text></Text>
                        <Text style={[styles.subtitle, { color: colors.icon }]}>The premium food experience.</Text>
                    </View>

                    <View style={[styles.roleToggle, { backgroundColor: colors.card }]}>
                        <TouchableOpacity
                            style={[styles.roleBtn, role === 'customer' && { backgroundColor: colors.primary }]}
                            onPress={() => setRole('customer')}
                        >
                            <Text style={[styles.roleText, role === 'customer' ? { color: '#fff' } : { color: colors.text }]}>Order Food</Text>
                        </TouchableOpacity>
                        <TouchableOpacity
                            style={[styles.roleBtn, role === 'restaurant' && { backgroundColor: colors.text }]}
                            onPress={() => setRole('restaurant')}
                        >
                            <Text style={[styles.roleText, role === 'restaurant' ? { color: colors.background } : { color: colors.text }]}>Partner Hub</Text>
                        </TouchableOpacity>
                    </View>

                    <View style={styles.form}>
                        <Text style={[styles.formTitle, { color: colors.text }]}>
                            {role === 'customer' ? (isSignUp ? 'Create an account' : 'Sign in to order') : 'Restaurant Portal Login'}
                        </Text>
                        <TextInput
                            style={[styles.input, { backgroundColor: colors.card, color: colors.text }]}
                            placeholder="Email Address"
                            placeholderTextColor={colors.icon}
                            autoCapitalize="none"
                            value={email}
                            onChangeText={setEmail}
                        />
                        <TextInput
                            style={[styles.input, { backgroundColor: colors.card, color: colors.text }]}
                            placeholder="Password"
                            placeholderTextColor={colors.icon}
                            secureTextEntry
                            value={password}
                            onChangeText={setPassword}
                        />

                        {role === 'customer' && isSignUp && (
                            <>
                                <TextInput
                                    style={[styles.input, { backgroundColor: colors.card, color: colors.text }]}
                                    placeholder="Registration Home / Delivery Address"
                                    placeholderTextColor={colors.icon}
                                    value={address}
                                    onChangeText={setAddress}
                                />
                                <TextInput
                                    style={[styles.input, { backgroundColor: colors.card, color: colors.text }]}
                                    placeholder="Referral Number (Optional)"
                                    placeholderTextColor={colors.icon}
                                    value={referralCode}
                                    onChangeText={setReferralCode}
                                />
                            </>
                        )}

                        <TouchableOpacity style={[styles.submitBtn, { backgroundColor: colors.primary }]} onPress={handleLogin}>
                            <Text style={styles.submitBtnText}>{isSignUp ? 'Sign Up' : 'Sign In'}</Text>
                        </TouchableOpacity>

                        {role === 'customer' && (
                            <TouchableOpacity style={{ marginTop: 20 }} onPress={() => setIsSignUp(!isSignUp)}>
                                <Text style={{ textAlign: 'center', color: colors.primary, fontWeight: 'bold' }}>
                                    {isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Sign Up"}
                                </Text>
                            </TouchableOpacity>
                        )}
                    </View>

                    {role === 'restaurant' && (
                        <TouchableOpacity style={styles.footerLink} onPress={() => router.push('/(owner)/apply' as any)}>
                            <Text style={{ color: colors.icon, textAlign: 'center' }}>
                                Want to list your hotel/restaurant with us? <Text style={{ color: colors.primary, fontWeight: 'bold' }}>Apply here.</Text>
                            </Text>
                        </TouchableOpacity>
                    )}
                </ScrollView>
            </KeyboardAvoidingView>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: { flexGrow: 1, padding: 24, justifyContent: 'center' },
    header: { alignItems: 'center', marginBottom: 40 },
    title: { fontSize: 40, fontWeight: '900' },
    subtitle: { fontSize: 16, marginTop: 8 },
    roleToggle: { flexDirection: 'row', borderRadius: 12, padding: 4, marginBottom: 32 },
    roleBtn: { flex: 1, paddingVertical: 12, borderRadius: 8, alignItems: 'center' },
    roleText: { fontWeight: 'bold', fontSize: 16 },
    form: { marginBottom: 20 },
    formTitle: { fontSize: 24, fontWeight: '800', marginBottom: 24 },
    input: { height: 55, borderRadius: 12, paddingHorizontal: 16, fontSize: 16, marginBottom: 16, shadowColor: '#000', shadowOpacity: 0.05, shadowRadius: 5, elevation: 1 },
    submitBtn: { height: 55, borderRadius: 12, justifyContent: 'center', alignItems: 'center', marginTop: 8 },
    submitBtnText: { color: '#fff', fontSize: 18, fontWeight: 'bold' },
    footerLink: { marginTop: 24 },
});
