import React, { useState } from 'react';
import { View, Text, ScrollView, StyleSheet, SafeAreaView, TouchableOpacity, TextInput, Alert, RefreshControl } from 'react-native';
import * as Haptics from 'expo-haptics';
import { useRouter } from 'expo-router';
import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/use-color-scheme';
import RestaurantCard from '@/components/RestaurantCard';
import CartIcon from '@/components/CartIcon';
import { useRestaurantStore } from '@/store/useRestaurantStore';

export default function HomeScreen() {
  const router = useRouter();
  const theme = useColorScheme() ?? 'light';
  const colors = Colors[theme];
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilter, setActiveFilter] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  const onRefresh = React.useCallback(() => {
    setRefreshing(true);
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setTimeout(() => {
      setRefreshing(false);
    }, 1000);
  }, []);

  const categories = [
    { id: '1', name: 'Meat', icon: '🥩' },
    { id: '2', name: 'Fast Food', icon: '🍔' },
    { id: '3', name: 'Meals', icon: '🍲' }
  ];

  const { restaurants } = useRestaurantStore();

  const filteredRestaurants = restaurants.filter(r => {
    const matchesSearch = r.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      r.tags.some(tag => tag.toLowerCase().includes(searchQuery.toLowerCase()));

    const matchesFilter = activeFilter ? r.tags.includes(activeFilter) ||
      (activeFilter === 'Pizza' && r.tags.includes('Pizza')) : true;

    return matchesSearch && matchesFilter;
  });

  const handleLocationPress = () => {
    Alert.prompt(
      'Enter Delivery Address',
      'Update your current location for accurate delivery estimates',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Save', onPress: (text?: string) => console.log('Saved Address:', text) }
      ]
    );
  };

  const toggleFilter = (filter: string) => {
    setActiveFilter(activeFilter === filter ? null : filter);
  };

  return (
    <SafeAreaView style={[styles.safe, { backgroundColor: colors.background }]}>
      <CartIcon />
      <ScrollView
        contentContainerStyle={styles.container}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={colors.primary} />}
      >
        <TouchableOpacity style={styles.header} onPress={handleLocationPress}>
          <Text style={[styles.locationLabel, { color: colors.icon }]}>Delivering to</Text>
          <Text style={[styles.location, { color: colors.primary }]}>Home ▼</Text>
        </TouchableOpacity>

        <TextInput
          style={[styles.searchBar, { backgroundColor: colors.card, color: colors.text }]}
          placeholder="Search restaurants or cuisines..."
          placeholderTextColor={colors.icon}
          value={searchQuery}
          onChangeText={setSearchQuery}
        />

        <View style={styles.filtersScroll}>
          <ScrollView horizontal showsHorizontalScrollIndicator={false}>
            {categories.map((category) => {
              const isActive = activeFilter === category.name;
              return (
                <TouchableOpacity
                  key={category.id}
                  style={[styles.filterPill, { backgroundColor: isActive ? colors.primary : colors.card }]}
                  onPress={() => toggleFilter(category.name)}
                >
                  <Text style={{ fontSize: 24, marginBottom: 6 }}>{category.icon}</Text>
                  <Text style={{ color: isActive ? '#fff' : colors.text, fontWeight: '700', fontSize: 13 }}>{category.name}</Text>
                </TouchableOpacity>
              );
            })}
          </ScrollView>
        </View>

        <Text style={[styles.sectionTitle, { color: colors.text }]}>Explore Delicious Options Near You</Text>

        {filteredRestaurants.length === 0 ? (
          <Text style={{ color: colors.icon, marginTop: 20, textAlign: 'center' }}>No restaurants match your search.</Text>
        ) : (
          filteredRestaurants.map((restaurant) => (
            <RestaurantCard
              key={restaurant.id}
              restaurant={restaurant}
              onPress={() => router.push(`/restaurant/${restaurant.id}`)}
            />
          ))
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1 },
  container: { padding: 16 },
  header: { marginBottom: 16, marginTop: 30 },
  locationLabel: { fontSize: 12, fontWeight: '600', textTransform: 'uppercase' },
  location: { fontSize: 20, fontWeight: 'bold' },
  searchBar: { height: 50, borderRadius: 12, paddingHorizontal: 16, fontSize: 16, marginBottom: 20, shadowColor: '#000', shadowOpacity: 0.05, shadowRadius: 5, elevation: 2 },
  filtersScroll: { marginBottom: 24 },
  filterPill: { paddingHorizontal: 16, paddingVertical: 14, borderRadius: 20, marginRight: 12, alignItems: 'center', justifyContent: 'center', minWidth: 80, shadowColor: '#000', shadowOpacity: 0.05, shadowRadius: 5, elevation: 1 },
  sectionTitle: { fontSize: 22, fontWeight: '800', marginBottom: 16 },
});
