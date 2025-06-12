import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_home2/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class WorkersSettings extends StatelessWidget {
  const WorkersSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Available locales for consistency
    const supportedLocales = [
      Locale('en', 'US'),
      Locale('ar', 'DZ'),
      Locale('fr', 'FR'),
    ];

    // Get current locale or default to English
    final currentLocale = Get.locale ?? const Locale('en', 'US');
    
    // Find matching locale from supported list
    Locale selectedLocale = supportedLocales.first;
    for (final locale in supportedLocales) {
      if (locale.languageCode == currentLocale.languageCode) {
        selectedLocale = locale;
        break;
      }
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("settings".tr, style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        )),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor:  Theme.of(context).colorScheme.surface,
      ),
   
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Dark Mode Toggle
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.dark_mode),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'dark_mode'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.inversePrimary,
                    ),
                  ),
                ),
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(),
                ),
              ],
            ),
          ),

          // Language Selection Dropdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.language),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'language'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.inversePrimary,
                    ),
                  ),
                ),
                DropdownButton<Locale>(
                  value: selectedLocale,
                  icon: const Icon(Icons.arrow_drop_down),
                  underline: Container(height: 0),
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      Get.updateLocale(newLocale);
                    }
                  },
                  items: supportedLocales.map((locale) {
                    final label = switch (locale.languageCode) {
                      'en' => 'English',
                      'ar' => 'العربية',
                      'fr' => 'Français',
                      _ => locale.languageCode,
                    };
                    return DropdownMenuItem(
                      value: locale,
                      child: Text(label),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
