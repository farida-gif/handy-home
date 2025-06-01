// worker_signup_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:handy_home2/common_widgets/round_button.dart';
import 'package:handy_home2/common_widgets/round_textfield.dart';
import 'package:handy_home2/pages/clients_pages/login_pages/client_login_page.dart';
import 'package:handy_home2/pages/clients_pages/services_page.dart';
import 'package:handy_home2/repo/client_repo.dart';

class ClientSignupPage extends StatefulWidget {
  const ClientSignupPage({super.key});

  @override
  State<ClientSignupPage> createState() => _ClientSignupPageState();
}

class _ClientSignupPageState extends State<ClientSignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController txtFirstName = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtMobile = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController confirmtxtPassword = TextEditingController();
  final TextEditingController txtRegion = TextEditingController();
  final TextEditingController address = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? region;
   Locale selectedLocale = Get.locale ?? const Locale('en', 'US');
  bool isDropdownOpen = false;

  final List<String> regionOptions = [
    "New Cairo".tr,
    "Maadii".tr,
    "Zamalek".tr,
    "Zayed".tr,
    "Nasr City".tr,
    "Heliopolis".tr,
    "October City".tr,
  ];
  
final supportedLocales = const [
    Locale('en', 'US'),
    Locale('fr', 'FR'),
    Locale('ar', 'DZ'),
  ];

  bool isPasswordValid(String password) {
    return password.length >= 6 &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("unexpected_error".tr),
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

  void validateAndSubmit() async {
    final String password = txtPassword.text.trim();
    final String confirmPassword = confirmtxtPassword.text.trim();
    final String fullName = txtFirstName.text.trim();
    final String email = txtEmail.text.trim();
    final String phone = txtMobile.text.trim();
    final String addressText = address.text.trim();
    final String? region = this.region;



    if ([fullName, email, phone].any((e) => e.isEmpty)) {
      showErrorDialog("all_fields_required".tr);
      return;
    }
    if (region == null || region.isEmpty) {
      showErrorDialog("select_region_error".tr);
      return;
    }
    if (!isPasswordValid(password)) {
      showErrorDialog(
          "password_validation".tr);
      return;
    }
    if (password != confirmPassword) {
      showErrorDialog("password_mismatch_error".tr);
      return;
    }

    try {
      await ClientsRepo.instance.clientSignUp(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phone,
        region: region,
        address: addressText,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ServicesPage()),
      );
    } catch (e) {
      showErrorDialog("signup_failed ${e.toString()}".tr);
    }
  }

  final blackBorder = const UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.black),
  );
  final blackFocusedBorder = const UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 2),
  );

  @override
  Widget build(BuildContext context) {
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

            Image.asset('assets/img/logo2.png', width: 450, height: 350),
             Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),

              child: Text(
                'please_fill_in_english'.tr,
                style: TextStyle(color: Colors.blue[800], fontSize: 14, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            RoundTextField(controller: txtFirstName, hintText: "full_name".tr, keyboardType: TextInputType.name),
            const SizedBox(height: 15),
            RoundTextField(controller: txtEmail, hintText: "email".tr, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 15),
            RoundTextField(controller: txtMobile, hintText: "phone_number".tr, keyboardType: TextInputType.phone),
            const SizedBox(height: 15),
            RoundTextField(
              controller: txtPassword,
              hintText: "password".tr,
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            const SizedBox(height: 15),
            RoundTextField(
              controller: confirmtxtPassword,
              hintText: "confirm_password".tr,
              obscureText: !_isConfirmPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              ),
            ),
            const SizedBox(height: 15),
            RoundTextField(
              controller: address,
              hintText: "address".tr,
            ),
            const SizedBox(height: 20),
            
           DropdownButtonFormField<String>(
              value: region,
              decoration: InputDecoration(
                labelText: 'select_region'.tr,
                border: blackBorder,
                enabledBorder: blackBorder,
                focusedBorder: blackFocusedBorder,
              ),
              items: regionOptions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => region = v),
            ),
            const SizedBox(height: 20),
          
                      RoundButton(title: "sign_up".tr, onPressed: validateAndSubmit),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("already_have_account".tr, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ClientLoginPage())),
                  child: Text("login".tr, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ));
  }
}
