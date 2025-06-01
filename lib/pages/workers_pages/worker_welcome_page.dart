
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:handy_home2/common_widgets/round_button.dart';
import 'package:handy_home2/pages/workers_pages/worker_login_page.dart';
import 'package:handy_home2/pages/workers_pages/worker_signup_page.dart';

class WorkerWelcomePage extends StatefulWidget {
  const WorkerWelcomePage({super.key});

  @override
  State<WorkerWelcomePage> createState() => _WorkerWelcomePageState();
}

class _WorkerWelcomePageState extends State<WorkerWelcomePage> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(

//The Stack widget allows you to place multiple widgets on top of each other.
//It takes the full width and height of the screen (media.width and media.height).
//The fit: BoxFit.cover ensures the image scales properly to cover the screen.

      body: Stack(
        children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Opacity(
            opacity:0.17, // Adjust value between 0.0 (fully transparent) to 1.0 (fully opaque)Image.asset(
            child: Image.asset("assets/img/bg.jpeg",
            width: media.width,
            height: media.height,
            fit: BoxFit.cover,
          ),
          ),
        ),
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
                 "start_working".tr, // 🎯 Translated text
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 35,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: media.width * 0.28,
              ),
               RoundButton(
                title: "sign_up".tr,
                onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  WorkerSignupPage())); 
  
                },
              ),
              const SizedBox(
                height: 20,
              ),
              RoundButton(
               title: "login".tr,
                onPressed: () {

                   Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkerLoginPage() ));

                },
              ),
            ], 
    ),),)
    ]),
        );
  }
}


