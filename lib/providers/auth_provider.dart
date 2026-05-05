import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  AppUser? _user;
  bool _isLoading = false;
  String? _lastErrorMessage;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get lastErrorMessage => _lastErrorMessage;
  bool get isLoggedIn => _supabase.auth.currentSession != null && _user != null;

  AuthProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        await _fetchProfile(session.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      // Inject email from Auth User
      data['email'] = _supabase.auth.currentUser?.email ?? '';
      
      _user = AppUser.fromJson(data);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ ERROR FETCHING PROFILE: $e');
    }
  }

  String _humanizeError(dynamic error) {
    final errStr = error.toString().toLowerCase();
    if (errStr.contains('already registered') || errStr.contains('email already in use')) {
      return 'You are already registered! Please sign in instead.';
    }
    if (errStr.contains('invalid login credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (errStr.contains('user not found')) {
      return 'No account found with this email. Please sign up first.';
    }
    if (errStr.contains('network') || errStr.contains('socket')) {
      return 'Network error. Please check your internet connection.';
    }
    if (errStr.contains('confirmation') || errStr.contains('email not confirmed')) {
      return 'Please confirm your email address first (or disable email confirmation in Supabase).';
    }
    return 'Error: $error'; // Show the actual error for debugging
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _lastErrorMessage = null;
    notifyListeners();
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return true;
    } catch (e) {
      _lastErrorMessage = _humanizeError(e);
      debugPrint('❌ SIGN IN ERROR: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    String? address,
  }) async {
    _isLoading = true;
    _lastErrorMessage = null;
    notifyListeners();
    try {
      // Step 1: Create auth user
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final userId = res.user?.id;
      if (userId == null) {
        _lastErrorMessage = 'Sign up failed. Please try again.';
        return false;
      }

      // Step 2: Determine role from email (no trigger needed)
      String finalRole = role;
      if (email.toLowerCase() == 'admin@saffroneats.com') {
        finalRole = 'superadmin';
      } else if (email.toLowerCase().endsWith('@saffroneats.com')) {
        finalRole = 'owner';
      }

      // Step 3: Create profile manually
      await _supabase.from('profiles').upsert({
        'id': userId,
        'full_name': name.isNotEmpty ? name : email.split('@').first,
        'role': finalRole,
        'address': address ?? '',
        'push_enabled': true,
        'email_enabled': false,
      });

      // Step 4: Link owner to restaurant by email
      if (finalRole == 'owner') {
        await _supabase
            .from('restaurants')
            .update({'owner_id': userId})
            .eq('owner_email', email.toLowerCase());
      }

      // Step 5: Fetch the profile so the app knows the role
      await _fetchProfile(userId);
      return true;
    } catch (e, stack) {
      _lastErrorMessage = _humanizeError(e);
      debugPrint('❌ SIGN UP ERROR: $e');
      debugPrint('Stack trace: $stack');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<void> updateUser(AppUser updatedUser) async {
    _user = updatedUser;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase.from('profiles').update({
          'full_name': updatedUser.name,
          'address': updatedUser.address,
          'avatar_url': updatedUser.avatarUrl,
          'push_enabled': updatedUser.pushEnabled,
          'email_enabled': updatedUser.emailEnabled,
        }).eq('id', userId);
      }
    } catch (e) {
      debugPrint('Error updating profile in DB: $e');
    }
  }

  // Backwards compatibility for the current UI logic
  Future<void> mockLogin({
    required String email,
    required String role,
    String? address,
    bool isSignUp = false,
  }) async {
    // This now just attempts a quick dev-mode login if you want to keep the UI same
    // But ideally the UI should call signIn/signUp
  }
}
