import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_home2/pages/clients_pages/login_pages/client_login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogoutPage extends StatefulWidget {
  const LogoutPage({super.key});

  @override
  State<LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  String email = '';
  String username = 'loading'.tr;


  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      setState(() {
        email = user.email ?? 'no_email'.tr;
      });

      try {
        final response = await Supabase.instance.client
            .from('clients')
            .select('name')
            .eq('id', user.id)
            .single();

        setState(() {
          username = response['name'] ?? 'Client Name';
        });
      } catch (e) {
        print('Failed to fetch name: $e');
        setState(() {
          username = 'Client Name';
        });
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("logout".tr),
          content: Text("logout_confirmation".tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("cancel".tr),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await Supabase.instance.client.auth.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const ClientLoginPage()),
                  (route) => false,
                );
              },
              child: Text("logout".tr, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Logout")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Image.asset(
              "assets/img/logo2.png",
              width: 350,
              height: 250,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),

            // Username
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.person),
              ),
              controller: TextEditingController(text: username),
            ),
            const SizedBox(height: 15),

            // Email
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.email),
              ),
              controller: TextEditingController(text: email),
            ),
            const SizedBox(height: 30),

            // Logout Button
            ElevatedButton(
              onPressed: () => _showLogoutDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
