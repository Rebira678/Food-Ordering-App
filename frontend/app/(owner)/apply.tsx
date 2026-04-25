import React, { useState } from 'react';
import { View, Text, StyleSheet, TextInput, TouchableOpacity, ScrollView, SafeAreaView } from 'react-native';
import { useRouter } from 'expo-router';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/use-color-scheme';
import Toast from 'react-native-root-toast';

export default function ApplyScreen() {
    const router = useRouter();
    const theme = useColorScheme() ?? 'light';
    const colors = Colors[theme];

    const [name, setName] = useState('');
    const [restaurantName, setRestaurantName] = useState('');
    const [phone, setPhone] = useState('');

    const submitApplication = () => {
        if (!name || !restaurantName || !phone) {
            Toast.show('Please fill out all fields.', { backgroundColor: colors.icon });
            return;
        }
        Toast.show('Application Submitted! We will call you soon.', {
            duration: Toast.durations.LONG,
            position: Toast.positions.CENTER,
            backgroundColor: colors.success
        });
        router.back();
    };

    return (
        <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
            <ScrollView contentContainerStyle={styles.container}>
                <TouchableOpacity onPress={() => router.back()} style={styles.backBtn}>
                    <Text style={{ color: colors.text, fontSize: 28 }}>←</Text>
                </TouchableOpacity>

                <Text style={[styles.title, { color: colors.text }]}>Partner With Saffron Eats</Text>
                <Text style={[styles.subtitle, { color: colors.icon }]}>
                    Grow your business by reaching thousands of hungry customers daily. Fill out the form below and our team will get in touch!
                </Text>

                <View style={styles.formCard}>
                    <Text style={[styles.label, { color: colors.text }]}>Owner's Full Name</Text>
                    <TextInput
                        style={[styles.input, { backgroundColor: colors.card, color: colors.text }]}
                        placeholder="e.g., John Doe"
                        placeholderTextColor={colors.icon}
                        value={name}
                        onChangeText={setName}
                    />

                    <Text style={[styles.label, { color: colors.text }]}>Restaurant / Hotel Name</Text>
                    <TextInput
                        style={[styles.input, { backgroundColor: colors.card, color: colors.text }]}
                        placeholder="e.g., Bella Napoli Pizza"
                        placeholderTextColor={colors.icon}
                        value={restaurantName}
                        onChangeText={setRestaurantName}
                    />

                    <Text style={[styles.label, { color: colors.text }]}>Phone Number</Text>
                    <TextInput
                        style={[styles.input, { backgroundColor: colors.card, color: colors.text }]}
                        placeholder="+1 234 567 8900"
                        placeholderTextColor={colors.icon}
                        keyboardType="phone-pad"
                        value={phone}
                        onChangeText={setPhone}
                    />

                    <TouchableOpacity style={[styles.submitBtn, { backgroundColor: colors.primary }]} onPress={submitApplication}>
                        <Text style={styles.submitBtnText}>Submit Application</Text>
                    </TouchableOpacity>
                </View>
            </ScrollView>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: { padding: 24, paddingTop: 40 },
    backBtn: { marginBottom: 20 },
    title: { fontSize: 32, fontWeight: '800', marginBottom: 12 },
    subtitle: { fontSize: 16, lineHeight: 24, marginBottom: 32 },
    formCard: { gap: 16 },
    label: { fontSize: 16, fontWeight: '600', marginLeft: 4 },
    input: { height: 55, borderRadius: 12, paddingHorizontal: 16, fontSize: 16, shadowColor: '#000', shadowOpacity: 0.05, shadowRadius: 5, elevation: 1 },
    submitBtn: { height: 55, borderRadius: 12, justifyContent: 'center', alignItems: 'center', marginTop: 20 },
    submitBtnText: { color: '#fff', fontSize: 18, fontWeight: 'bold' }
});
