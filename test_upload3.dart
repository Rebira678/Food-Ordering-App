import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://aibewfhfwdblzzygxcau.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFpYmV3Zmhmd2RibHp6eWd4Y2F1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc2MDA5NTcsImV4cCI6MjA5MzE3Njk1N30.yVy3U4ecNovWU4zI-FO2_udZZcK0BgOMQ-ENzNfQ6Ws'
  );
  
  final file = File('test.txt');
  await file.writeAsString('hello');
  
  try {
    await supabase.storage.from('payments').upload('test.txt', file);
    print('Upload successful to payments');
  } catch (e) {
    print('Error uploading to payments: $e');
  }
}
