import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_home2/common_widgets/round_button.dart';
import 'package:handy_home2/common_widgets/round_textfield.dart';
import 'package:handy_home2/pages/clients_pages/login_pages/client_forgot_password.dart';
import 'package:handy_home2/pages/clients_pages/login_pages/client_signup_page.dart';
import 'package:handy_home2/pages/clients_pages/services_page.dart';
import 'package:handy_home2/repo/client_repo.dart';

class ClientLoginPage extends StatefulWidget {
  const ClientLoginPage({super.key});

  @override
  State<ClientLoginPage> createState() => _ClientLoginPageState();
}

class _ClientLoginPageState extends State<ClientLoginPage> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  bool _isPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();

  final supportedLocales = const [
    Locale('en', 'US'),
    Locale('fr', 'FR'),
    Locale('ar', 'DZ'),
  ];

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("login_failed".tr),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ok".tr),
          ),
        ],
      ),
    );
  }

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    try {
      await ClientsRepo.instance.clientLogIn(
        email: email,
        password: password,
      );

      // Navigate only if login is successful
      Get.offAll(() => const ServicesPage());
    } catch (e) {
      showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    Locale? selectedLocale = supportedLocales.firstWhereOrNull(
      (loc) => loc.languageCode == Get.locale?.languageCode && loc.countryCode == Get.locale?.countryCode,
    );

    selectedLocale ??= supportedLocales.first;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              const SizedBox(height: 40),

  // Language Dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownButton<Locale>(
                    value: selectedLocale,
                    icon: const Icon(Icons.language),
                    onChanged: (Locale? locale) {
                      if (locale != null) Get.updateLocale(locale);
                    },
                    items: supportedLocales.map((locale) {
                      final label = switch (locale.languageCode) {
                        'en' => 'English',
                        'fr' => 'Français',
                        'ar' => 'العربية',
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

              const SizedBox(height: 20),
              Image.asset("assets/img/logo2.png", width: 450, height: 300),
              const SizedBox(height: 20),
              RoundTextField(
                controller: emailCtrl,
                hintText: "email".tr,
                keyboardType: TextInputType.emailAddress, 
                
              ),
              const SizedBox(height: 15),

              RoundTextField(
                controller: passwordCtrl,
                hintText: "password".tr,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                
              ),
              const SizedBox(height: 25),

              RoundButton(title: "login".tr, onPressed: handleLogin),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                children: [
                  Text("forgot_password_question".tr),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Get.to(() =>  ClientForgotPassword()),
                    child: Text(
                      "reset_password".tr,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("no_account".tr),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Get.to(() =>  ClientSignupPage()),
                    child: Text(
                      "sign_up".tr,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
