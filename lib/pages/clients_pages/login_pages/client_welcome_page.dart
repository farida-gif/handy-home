
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_home2/common_widgets/round_button.dart';
import 'package:handy_home2/pages/clients_pages/login_pages/client_login_page.dart';
import 'package:handy_home2/pages/clients_pages/login_pages/client_signup_page.dart';

class ClientWelcomePage extends StatefulWidget {
  const ClientWelcomePage({super.key});

  @override
  State<ClientWelcomePage> createState() => _ClientWelcomePageState();
}

class _ClientWelcomePageState extends State<ClientWelcomePage> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(

//The Stack widget allows you to place multiple widgets on top of each other.
//It takes the full width and height of the screen (media.width and media.height).
//The fit: BoxFit.cover ensures the image scales properly to cover the screen.

      body: Stack(
        children: [
          Opacity(
            opacity: 0.17,
          child: Image.asset(
          "assets/img/bg.jpeg",
          width: media.width,
          height: media.height,
          fit: BoxFit.cover,
        ),),
//SafeArea widget and Container are placed as the second child of the Stack,
// ensuring that content (like the text) appears above the background image.

        SafeArea(
            child: Container(
          width: media.width,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              SizedBox(
                height: media.width * 0.25,
              ),
              Text(
                "tagline".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 35,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: media.width * 0.28,
              ),
//sign up
               RoundButton(
                title: "sign_up".tr,
                onPressed: () {
                   Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  const ClientSignupPage())); 
  
                },
              ),
              const SizedBox(
                height: 20,
              ),
    //login
              RoundButton(
                title: "login".tr,
                onPressed: () {

                   Navigator.push(context, MaterialPageRoute(builder: (context) => const ClientLoginPage() ));

                },
              ),
            ], 
    ),),)
    ]),
        );
  }
}

