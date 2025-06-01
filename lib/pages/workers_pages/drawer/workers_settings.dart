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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("settings".tr,style: TextStyle(fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.surface,
        )),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
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
                  value: Get.locale,
                  icon: const Icon(Icons.arrow_drop_down),
                  underline: Container(height: 0),
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      Get.updateLocale(newLocale);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: Locale('en'),
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: Locale('ar'),
                      child: Text('العربية'),
                    ),
                    DropdownMenuItem(
                      value: Locale('fr'),
                      child: Text('Français'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
