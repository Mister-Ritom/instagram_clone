import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class Database {
  // Static late variable to hold the client
  static late SupabaseClient _client;

  // Static variable to get the client safely
  static final client = () {
    try {
      return _client;
    } catch (e, st) {
      log("Couldn't get Supabase client", error: e, stackTrace: st);
      throw Exception(
        "Supabase client not initialized. Call initialize() first.",
      );
    }
  }();

  // Initialize the Supabase client only once
  static Future<void> initialize() async {
    String url = "https://lrccpjjnbbnccwtahtqp.supabase.co";
    String anonKey = "Should not be used";

    final supabase = await Supabase.initialize(url: url, anonKey: anonKey);
    _client = supabase.client;
  }
}
