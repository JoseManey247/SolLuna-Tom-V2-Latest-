import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://ppzdlawsjphuoewicyqq.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_LMmFjWRJSsAIt-u5e2fWmg_P56t7rme';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}