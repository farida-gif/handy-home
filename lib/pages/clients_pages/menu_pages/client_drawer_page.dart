// lib/common_widgets/client_drawer.dart
import 'package:flutter/material.dart';
import 'package:handy_home2/pages/clients_pages/menu_pages/client_edit_profile_page.dart';
import 'package:handy_home2/pages/clients_pages/menu_pages/client_logout_page.dart';
import 'package:handy_home2/pages/clients_pages/menu_pages/client_orders_page.dart';
import 'package:handy_home2/pages/clients_pages/menu_pages/client_settings.dart';
import 'package:handy_home2/pages/clients_pages/menu_pages/contact_us.dart';
import 'package:handy_home2/pages/clients_pages/menu_pages/feedback_page.dart';
import 'package:handy_home2/pages/clients_pages/services_page.dart'; // Make sure this is correct
import 'package:get/get.dart';

class ClientDrawer extends StatelessWidget {
  const ClientDrawer({super.key});

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.pop(context); // Close drawer first
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: Text(
              'menu'.tr,
              style: TextStyle(color: Theme.of(context).colorScheme.surface, fontSize: 40),
            ),
          ),
          ListTile(
            leading: Icon(Icons.construction),
            title: Text('services_page'.tr),
            onTap: () => navigateToPage(context, const ServicesPage()),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('settings'.tr),
            onTap: () => navigateToPage(context, const SettingsPage()),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('profile'.tr),
            onTap: () => navigateToPage(
              context,
              EditClientProfilePage(
               
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.cases),
            title: Text('orders'.tr),
            onTap: () => navigateToPage(context, ClientOrdersPage()),
          ),
          ListTile(
          leading: Icon(Icons.feedback),
          title: Text('feedback'.tr),
          onTap: () => navigateToPage(context, const FeedbackPage()),
          ),
          ListTile(
          leading: Icon(Icons.support_agent),
          title: Text('contact_us'.tr),
          onTap: () => navigateToPage(context, const ContactUsPage()),
         ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('logout'.tr),
            onTap: () => navigateToPage(context, const LogoutPage()),
          ),
        ],
      ),
    );
  }
}
