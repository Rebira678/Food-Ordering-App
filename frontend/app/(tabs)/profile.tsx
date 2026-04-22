import React, { useState } from 'react';
import { View, Text, StyleSheet, SafeAreaView, TouchableOpacity, Image, TextInput, Appearance, ScrollView, LayoutAnimation, Platform, UIManager } from 'react-native';

if (Platform.OS === 'android' && UIManager.setLayoutAnimationEnabledExperimental) {
    UIManager.setLayoutAnimationEnabledExperimental(true);
}
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/use-color-scheme';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'expo-router';
import Toast from 'react-native-root-toast';

export default function ProfileScreen() {
    const theme = useColorScheme() ?? 'light';
    const colors = Colors[theme];
    const { user, updateUser, logout } = useAuthStore();
    const router = useRouter();
    const [activeSection, setActiveSection] = useState('');

    const [name, setName] = useState(user?.name || '');
    const [email, setEmail] = useState(user?.email || '');
    const [address, setAddress] = useState(user?.address || '');
    const [avatar, setAvatar] = useState('https://ui-avatars.com/api/?name=' + (user?.name || 'User') + '&background=random&size=128');
    const [isNotificationsEnabled, setIsNotificationsEnabled] = useState(user?.pushEnabled ?? true);
    const [emailPromos, setEmailPromos] = useState(user?.emailEnabled ?? false);
    const [showAvatarPicker, setShowAvatarPicker] = useState(false);
    const [paymentMethods, setPaymentMethods] = useState([
        { id: '1', type: 'Mastercard', last4: '4022' }
    ]);

    const avatars = [
        'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix',
        'https://api.dicebear.com/7.x/avataaars/svg?seed=Aneka',
        'https://api.dicebear.com/7.x/avataaars/svg?seed=Bibi',
        'https://api.dicebear.com/7.x/avataaars/svg?seed=Caleb',
        'https://api.dicebear.com/7.x/avataaars/svg?seed=Dave',
        'https://api.dicebear.com/7.x/avataaars/svg?seed=Ezra'
    ];

    const saveProfile = async () => {
        await updateUser({ name, email, address });
        Toast.show('✅ Profile Updated Successfully!', { duration: Toast.durations.SHORT, position: Toast.positions.BOTTOM });
        setActiveSection('');
    };

    const addPayment = () => {
        const newCard = { id: Date.now().toString(), type: 'Visa', last4: '9981' };
        setPaymentMethods([...paymentMethods, newCard]);
        Toast.show('💳 Card Added!', { duration: Toast.durations.SHORT });
    };

    const deletePayment = (id: string) => {
        setPaymentMethods(prev => prev.filter(p => p.id !== id));
        Toast.show('🗑️ Card Removed', { duration: Toast.durations.SHORT });
    };

    const toggleNotifications = async () => {
        const newValue = !isNotificationsEnabled;
        setIsNotificationsEnabled(newValue);
        await updateUser({ pushEnabled: newValue });
        Toast.show(`🔔 Notifications ${newValue ? 'Enabled' : 'Disabled'}`, {
            duration: Toast.durations.SHORT,
            backgroundColor: newValue ? '#10B981' : '#6B7280'
        });
    };

    const togglePromos = async () => {
        const newValue = !emailPromos;
        setEmailPromos(newValue);
        await updateUser({ emailEnabled: newValue });
        Toast.show(`📧 Email Promos ${newValue ? 'Enabled' : 'Disabled'}`, { duration: Toast.durations.SHORT });
    };

    const CustomSwitch = ({ value, onValueChange }: { value: boolean, onValueChange: () => void }) => (
        <TouchableOpacity
            activeOpacity={0.8}
            onPress={onValueChange}
            style={{
                width: 50,
                height: 28,
                borderRadius: 14,
                backgroundColor: value ? '#10B981' : '#E5E7EB',
                padding: 2,
                justifyContent: 'center'
            }}
        >
            <View style={{
                width: 24,
                height: 24,
                borderRadius: 12,
                backgroundColor: '#fff',
                alignSelf: value ? 'flex-end' : 'flex-start',
                shadowColor: '#000',
                shadowOpacity: 0.1,
                shadowRadius: 2,
                elevation: 2
            }} />
        </TouchableOpacity>
    );

    const selectAvatar = (url: string) => {
        setAvatar(url);
        setShowAvatarPicker(false);
        Toast.show('📸 Photo Updated!', { duration: Toast.durations.SHORT });
    };

    const toggleSection = (item: string) => {
        LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut);
        setActiveSection(prev => (prev === item ? '' : item));
    };

    const toggleTheme = () => {
        const newTheme = theme === 'dark' ? 'light' : 'dark';
        Appearance.setColorScheme(newTheme);
        Toast.show(`Switched to ${newTheme.toUpperCase()} mode`, {
            duration: Toast.durations.SHORT,
            position: Toast.positions.BOTTOM,
            backgroundColor: newTheme === 'dark' ? '#333' : '#fff',
            textColor: newTheme === 'dark' ? '#fff' : '#000'
        });
    };

    const handleLogout = () => {
        logout();
        router.replace('/auth');
    };

    return (
        <SafeAreaView style={[styles.safe, { backgroundColor: colors.background }]}>
            <ScrollView contentContainerStyle={styles.container} showsVerticalScrollIndicator={false}>
                <View style={styles.header}>
                    {/* Attractive Active/Dark Mode Glow */}
                    {theme === 'dark' && (
                        <View style={[StyleSheet.absoluteFill, { backgroundColor: colors.primary, opacity: 0.05, borderRadius: 100, transform: [{ scale: 1.2 }] }]} />
                    )}
                    <TouchableOpacity
                        onPress={() => setShowAvatarPicker(true)}
                    >
                        <Image
                            source={{ uri: avatar }}
                            style={styles.avatar}
                        />
                        <View style={[styles.editBadge, { backgroundColor: colors.primary }]}>
                            <Text style={{ color: '#fff', fontSize: 10 }}>✎</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={[styles.name, { color: colors.text }]}>{user?.name || 'Guest User'}</Text>
                    <Text style={[styles.email, { color: colors.icon }]}>{user?.email || 'guest@example.com'}</Text>
                    {user?.address && (
                        <Text style={{ color: colors.primary, marginTop: 6, fontWeight: '600' }}>📍 {user.address}</Text>
                    )}

                    <View style={{ flexDirection: 'row', alignItems: 'center', backgroundColor: 'rgba(225, 29, 72, 0.1)', paddingHorizontal: 16, paddingVertical: 8, borderRadius: 20, marginTop: 16 }}>
                        <Text style={{ fontSize: 18, marginRight: 6 }}>💎</Text>
                        <Text style={{ color: colors.primary, fontWeight: '800' }}>VIP Elite Tier • 2,450 pts</Text>
                    </View>
                </View>

                {user?.referralCode && (
                    <View style={[styles.referralBox, { backgroundColor: colors.card, borderColor: colors.primary, borderWidth: 1 }]}>
                        <Text style={[styles.referralTitle, { color: colors.text }]}>Your Referral Code</Text>
                        <Text style={[styles.referralCode, { color: colors.primary }]}>{user.referralCode}</Text>
                        <Text style={[styles.referralSub, { color: colors.icon }]}>Share this code and you both get discounts!</Text>

                        {user.availableDiscounts && user.availableDiscounts.length > 0 && (
                            <Text style={[styles.discountText, { color: '#10B981', marginTop: 10 }]}>
                                🎉 You have discounts available at {user.availableDiscounts.length} restaurant(s)!
                            </Text>
                        )}
                    </View>
                )}

                {showAvatarPicker && (
                    <View style={[styles.avatarPicker, { backgroundColor: colors.card }]}>
                        <Text style={[styles.pickerTitle, { color: colors.text }]}>Choose Your Avatar</Text>
                        <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                            {avatars.map((url, idx) => (
                                <TouchableOpacity key={idx} onPress={() => selectAvatar(url)}>
                                    <Image source={{ uri: url }} style={styles.pickerImage} />
                                </TouchableOpacity>
                            ))}
                        </ScrollView>
                        <TouchableOpacity style={{ marginTop: 15 }} onPress={() => setShowAvatarPicker(false)}>
                            <Text style={{ color: colors.primary, fontWeight: 'bold' }}>Close</Text>
                        </TouchableOpacity>
                    </View>
                )}

                <View style={styles.accordionContainer}>
                    {/* Profile */}
                    <TouchableOpacity style={[styles.accordionHeader, { backgroundColor: colors.card, borderBottomColor: activeSection === 'Profile' ? 'transparent' : 'rgba(0,0,0,0.05)' }]} onPress={() => toggleSection('Profile')}>
                        <Text style={[styles.rowText, { color: colors.text }]}>👤 Manage Information</Text>
                        <Text style={{ color: colors.primary, fontSize: 24, fontWeight: 'bold', transform: [{ rotate: activeSection === 'Profile' ? '90deg' : '0deg' }] }}>›</Text>
                    </TouchableOpacity>
                    {activeSection === 'Profile' && (
                        <View style={[styles.accordionBody, { backgroundColor: colors.card }]}>
                            <TextInput style={[styles.input, { color: colors.text, backgroundColor: 'rgba(0,0,0,0.02)' }]} value={name} onChangeText={setName} placeholder="Full Name" placeholderTextColor={colors.icon} />
                            <TextInput style={[styles.input, { color: colors.text, backgroundColor: 'rgba(0,0,0,0.02)' }]} value={email} onChangeText={setEmail} placeholder="Email" placeholderTextColor={colors.icon} />
                            <TouchableOpacity style={[styles.saveBtn, { backgroundColor: colors.primary }]} onPress={saveProfile}><Text style={styles.saveBtnText}>Save Profile Data</Text></TouchableOpacity>
                        </View>
                    )}

                    {/* Payment */}
                    <TouchableOpacity style={[styles.accordionHeader, { backgroundColor: colors.card, borderBottomColor: activeSection === 'Payment' ? 'transparent' : 'rgba(0,0,0,0.05)' }]} onPress={() => toggleSection('Payment')}>
                        <Text style={[styles.rowText, { color: colors.text }]}>💳 Payment Methods</Text>
                        <Text style={{ color: colors.primary, fontSize: 24, fontWeight: 'bold', transform: [{ rotate: activeSection === 'Payment' ? '90deg' : '0deg' }] }}>›</Text>
                    </TouchableOpacity>
                    {activeSection === 'Payment' && (
                        <View style={[styles.accordionBody, { backgroundColor: colors.card }]}>
                            {paymentMethods.map(p => (
                                <View key={p.id} style={[styles.cardRow, { borderBottomColor: 'rgba(0,0,0,0.05)' }]}>
                                    <View>
                                        <Text style={{ color: colors.text, fontWeight: '700' }}>{p.type} •••• {p.last4}</Text>
                                    </View>
                                    <TouchableOpacity onPress={() => deletePayment(p.id)}>
                                        <Text style={{ color: '#EF4444', fontWeight: 'bold', fontSize: 12 }}>Remove</Text>
                                    </TouchableOpacity>
                                </View>
                            ))}
                            <TouchableOpacity style={{ marginTop: 15, padding: 15, borderRadius: 12, backgroundColor: 'rgba(255, 90, 95, 0.1)', alignItems: 'center' }} onPress={addPayment}>
                                <Text style={{ color: colors.primary, fontWeight: 'bold' }}>+ Add New Card</Text>
                            </TouchableOpacity>
                        </View>
                    )}

                    {/* Addresses */}
                    <TouchableOpacity style={[styles.accordionHeader, { backgroundColor: colors.card, borderBottomColor: activeSection === 'Addresses' ? 'transparent' : 'rgba(0,0,0,0.05)' }]} onPress={() => toggleSection('Addresses')}>
                        <Text style={[styles.rowText, { color: colors.text }]}>📍 Delivery Locations</Text>
                        <Text style={{ color: colors.primary, fontSize: 24, fontWeight: 'bold', transform: [{ rotate: activeSection === 'Addresses' ? '90deg' : '0deg' }] }}>›</Text>
                    </TouchableOpacity>
                    {activeSection === 'Addresses' && (
                        <View style={[styles.accordionBody, { backgroundColor: colors.card }]}>
                            <TextInput style={[styles.input, { color: colors.text, backgroundColor: 'rgba(0,0,0,0.02)' }]} value={address} onChangeText={setAddress} placeholder="Street Address..." placeholderTextColor={colors.icon} />
                            <TouchableOpacity style={[styles.saveBtn, { backgroundColor: colors.primary }]} onPress={saveProfile}><Text style={styles.saveBtnText}>Update Address</Text></TouchableOpacity>
                        </View>
                    )}

                    {/* Alerts */}
                    <TouchableOpacity style={[styles.accordionHeader, { backgroundColor: colors.card, borderBottomColor: activeSection === 'Alerts' ? 'transparent' : 'rgba(0,0,0,0.05)' }]} onPress={() => toggleSection('Alerts')}>
                        <Text style={[styles.rowText, { color: colors.text }]}>🔔 App Notifications</Text>
                        <Text style={{ color: colors.primary, fontSize: 24, fontWeight: 'bold', transform: [{ rotate: activeSection === 'Alerts' ? '90deg' : '0deg' }] }}>›</Text>
                    </TouchableOpacity>
                    {activeSection === 'Alerts' && (
                        <View style={[styles.accordionBody, { backgroundColor: colors.card }]}>
                            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 12, borderBottomWidth: 1, borderColor: 'rgba(0,0,0,0.05)' }}>
                                <View>
                                    <Text style={{ color: colors.text, fontSize: 16, fontWeight: '700' }}>Push Notifications</Text>
                                    <Text style={{ color: colors.icon, fontSize: 12 }}>Stay updated on your orders</Text>
                                </View>
                                <CustomSwitch value={isNotificationsEnabled} onValueChange={toggleNotifications} />
                            </View>
                            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 12 }}>
                                <View>
                                    <Text style={{ color: colors.text, fontSize: 16, fontWeight: '700' }}>Email Promos</Text>
                                    <Text style={{ color: colors.icon, fontSize: 12 }}>Get exclusive deals</Text>
                                </View>
                                <CustomSwitch value={emailPromos} onValueChange={togglePromos} />
                            </View>
                        </View>
                    )}
                </View>

                {/* Settings Block */}
                <Text style={{ marginLeft: 20, marginBottom: 10, color: colors.icon, fontWeight: 'bold', fontSize: 13, textTransform: 'uppercase' }}>App Settings</Text>

                <TouchableOpacity style={[styles.settingsRow, { backgroundColor: colors.card, shadowColor: '#000', shadowOffset: { width: 0, height: 4 }, shadowOpacity: 0.05, shadowRadius: 10 }]} onPress={toggleTheme}>
                    <Text style={[styles.rowText, { color: colors.text, fontWeight: 'bold' }]}>
                        {theme === 'dark' ? '☀️ Switch to Light Mode' : '🌙 Switch to Dark Mode'}
                    </Text>
                </TouchableOpacity>

                <TouchableOpacity
                    style={[styles.logoutBtn, { backgroundColor: '#FEE2E2', borderColor: '#FCA5A5' }]}
                    onPress={handleLogout}
                >
                    <Text style={[styles.logoutText, { color: '#DC2626' }]}>Sign Out from Account</Text>
                </TouchableOpacity>
            </ScrollView>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    safe: { flex: 1 },
    container: { paddingBottom: 50 },
    header: { alignItems: 'center', marginBottom: 20, marginTop: 20, position: 'relative' },
    avatarGlow: { shadowColor: '#FF5A5F', shadowOffset: { width: 0, height: 0 }, shadowOpacity: 0.5, shadowRadius: 20, elevation: 15 },
    avatar: { width: 100, height: 100, borderRadius: 50, marginBottom: 16, borderWidth: 2, borderColor: 'rgba(255,255,255,0.1)' },
    name: { fontSize: 26, fontWeight: '900', marginBottom: 4, letterSpacing: -0.5 },
    email: { fontSize: 16 },
    accordionContainer: { paddingHorizontal: 20, marginBottom: 30 },
    accordionHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 20, paddingHorizontal: 20, borderBottomWidth: 1, borderTopLeftRadius: 16, borderTopRightRadius: 16 },
    accordionBody: { paddingHorizontal: 20, paddingBottom: 20, borderBottomLeftRadius: 16, borderBottomRightRadius: 16, shadowColor: '#000', shadowOpacity: 0.05, shadowRadius: 10, elevation: 2, marginBottom: 15 },
    saveBtn: { padding: 16, borderRadius: 12, alignItems: 'center', marginTop: 10 },
    saveBtnText: { color: '#fff', fontWeight: '800', fontSize: 16 },
    cardTag: { padding: 18, borderRadius: 12, borderWidth: 1, borderColor: 'rgba(0,0,0,0.1)' },
    rowText: { fontSize: 16, fontWeight: '600' },
    settingsRow: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', paddingVertical: 18, paddingHorizontal: 20, borderRadius: 16, marginBottom: 15, marginHorizontal: 20 },
    logoutBtn: { padding: 18, borderRadius: 16, borderWidth: 1, alignItems: 'center', marginTop: 10, marginHorizontal: 20, marginBottom: 20 },
    logoutText: { fontSize: 16, fontWeight: '800' },
    referralBox: { padding: 20, borderRadius: 20, marginBottom: 25, alignItems: 'center', shadowColor: '#FF5A5F', shadowOpacity: 0.1, shadowRadius: 10, marginHorizontal: 20 },
    referralTitle: { fontSize: 14, fontWeight: '700', textTransform: 'uppercase', letterSpacing: 1 },
    referralCode: { fontSize: 32, fontWeight: '900', letterSpacing: 4, marginVertical: 10 },
    referralSub: { fontSize: 14, fontWeight: '500' },
    discountText: { fontSize: 14, fontWeight: 'bold', textAlign: 'center', marginTop: 15 },
    input: { width: '100%', padding: 15, borderRadius: 12, marginBottom: 15, fontSize: 16, borderWidth: 1, borderColor: 'rgba(0,0,0,0.05)' },
    editBadge: { position: 'absolute', right: 0, bottom: 15, width: 24, height: 24, borderRadius: 12, justifyContent: 'center', alignItems: 'center', borderWidth: 2, borderColor: '#fff' },
    avatarPicker: { marginHorizontal: 20, marginBottom: 20, padding: 20, borderRadius: 20, alignItems: 'center', shadowColor: '#000', shadowOpacity: 0.1, shadowRadius: 10, elevation: 5 },
    pickerTitle: { fontSize: 16, fontWeight: 'bold', marginBottom: 15 },
    pickerImage: { width: 60, height: 60, borderRadius: 30, marginHorizontal: 10, borderWidth: 2, borderColor: 'rgba(0,0,0,0.05)' },
    cardRow: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingVertical: 15, borderBottomWidth: 1 }
});
