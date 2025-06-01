import 'package:flutter/material.dart';
import 'package:handy_home2/common_widgets/round_button.dart';
import 'package:handy_home2/common_widgets/round_textfield.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';  // Add this import for translation

class ClientForgotPassword extends StatefulWidget {
  const ClientForgotPassword({super.key});

  @override
  State<ClientForgotPassword> createState() => _ClientForgotPasswordState();
}

class _ClientForgotPasswordState extends State<ClientForgotPassword> {
  final TextEditingController txtEmail = TextEditingController();
  bool _isLoading = false;
  bool _resetEmailSent = false;
  String? _errorMessage;

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _sendResetEmail() async {
    final email = txtEmail.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = "enter_email".tr;
      });
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _errorMessage = "valid_email".tr;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'YOUR_APP_SCHEME://reset-password', // Replace with your app's deep link
      );

      setState(() {
        _resetEmailSent = true;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("reset_email_sent".tr),
          backgroundColor: Colors.green,
        ),
      );
    } on AuthException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } catch (error) {
      setState(() {
        _errorMessage = "unexpected_error".tr;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        title: Text(
          "forgot_password".tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.surface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.17,
            child: Image.asset(
              "assets/img/bg.jpeg",
              width: media.width,
              height: media.height,
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    _resetEmailSent
                        ? "check_email_reset".tr
                        : "enter_email".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 30),

                  if (!_resetEmailSent) ...[
                    RoundTextField(
                      controller: txtEmail,
                      hintText: "email".tr,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(height: 25),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : RoundButton(
                            title: "submit".tr,
                            onPressed: _sendResetEmail,
                          ),
                  ] else ...[
                    const SizedBox(height: 20),
                    RoundLineButton(
                      title: "back_to_login".tr,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
