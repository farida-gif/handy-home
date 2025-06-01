import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:handy_home2/pages/on_boarding_page.dart';
import 'package:handy_home2/repo/binding_file.dart';
import 'package:handy_home2/themes/theme_provider.dart';
import 'package:handy_home2/translation/translations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🔄 Initializing Supabase...');
    await Supabase.initialize(
      url: 'https://rqamidswvatdfcypalgo.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJxYW1pZHN3dmF0ZGZjeXBhbGdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU4NDUxMjksImV4cCI6MjA2MTQyMTEyOX0.6wlbbn44QX8I9PH60kCxu5BhpFjqyP2RoE2s-4eUBDE',
    );
    print('✅ Supabase initialized successfully.');
  } catch (e, st) {
    print('❌ Supabase initialization failed: $e');
    print('🧵 Stacktrace:\n$st');
  }

  try {
    await initializeDateFormatting();
    print('✅ Date formatting initialized.');
  } catch (e, st) {
    print('❌ Date formatting initialization failed: $e');
    print('🧵 Stacktrace:\n$st');
  }

  runApp(const MyAppWrapper());
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);

    return GetMaterialApp(
      title: 'Handy Home',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      translations: AppTranslation(),
      locale: const Locale('en'),
      fallbackLocale: const Locale('en'),
      initialBinding: InitialBinding(), // ✅ Inject initial bindings here
      home: const OnBoardingPage(), // Can be replaced with DebugPage() during dev
    );
  }
}
