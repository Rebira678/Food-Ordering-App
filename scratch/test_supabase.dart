import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

void main() async {
  print('🚀 Testing Supabase Connection and Sign Up...');
  
  try {
    // 1. Load Environment Variables
    final envFile = File('.env');
    if (!envFile.existsSync()) {
      print('❌ ERROR: .env file not found!');
      exit(1);
    }
    
    await dotenv.load(fileName: ".env");
    final url = dotenv.env['SUPABASE_URL'];
    final key = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || key == null) {
      print('❌ ERROR: SUPABASE_URL or SUPABASE_ANON_KEY missing in .env');
      exit(1);
    }

    print('📡 Connecting to: $url');

    // 2. Initialize Supabase
    Supabase.initialize(
      url: url,
      anonKey: key,
    );
    final supabase = Supabase.instance.client;

    // 3. Test Connection (Fetch one restaurant)
    print('🧐 Testing database connectivity...');
    final dbTest = await supabase.from('restaurants').select().limit(1);
    print('✅ Database connection successful! Found ${dbTest.length} restaurants.');

    // 4. Test Sign Up (Dummy User)
    final testEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
    print('👤 Attempting test sign up for: $testEmail');

    try {
      final res = await supabase.auth.signUp(
        email: testEmail,
        password: 'TestPassword123!',
        data: {'full_name': 'Test User', 'role': 'customer'},
      );

      if (res.user != null) {
        print('✅ Sign up successful! User ID: ${res.user!.id}');
        print('⚠️  NOTE: If "Email Confirmation" is ON in Supabase, you won\'t be able to log in until the email is confirmed.');
      } else {
        print('❌ Sign up failed: User object is null.');
      }
    } catch (e) {
      print('❌ SIGN UP FAILED: $e');
      if (e.toString().contains('Email signups are disabled')) {
        print('💡 TIP: Go to Supabase Dashboard > Authentication > Providers > Email and enable "Allow new users to sign up".');
      } else if (e.toString().contains('Email link is invalid')) {
        print('💡 TIP: Check your Site URL and Redirect URLs in Supabase Auth settings.');
      }
    }

    exit(0);
  } catch (e) {
    print('❌ CRITICAL ERROR: $e');
    exit(1);
  }
}
