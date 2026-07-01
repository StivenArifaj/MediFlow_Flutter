import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://vehkddgphgpjpojralyt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZlaGtkZGdwaGdwanBvanJhbHl0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI4NDA1ODQsImV4cCI6MjA5ODQxNjU4NH0.tG4ZTOQy5s62BAUFLko4s1ADXitShevnv5JIxpWCRr0',
  );
}

SupabaseClient get supabase => Supabase.instance.client;
