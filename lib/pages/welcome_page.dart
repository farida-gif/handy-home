import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_home2/common_widgets/round_button.dart';
import 'package:handy_home2/pages/clients_pages/login_pages/client_welcome_page.dart';
import 'package:handy_home2/pages/workers_pages/worker_welcome_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Opacity(
              opacity: 0.17,
              child: Image.asset(
                "assets/img/bg.jpeg",
                width: media.width,
                height: media.height,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Container(
              width: media.width,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: media.width * 0.05),

  // Logo
                  Center(
                    child: Image.asset(
                      "assets/img/logo.png",
                      width: media.width * 1.7,
                      height: media.width * 1,
                    ),
                  ),
                  SizedBox(height: media.width * 0.03),

  // Client button
                  Center(
                    child: RoundButton(
                      title: "Start_as_client".tr,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ClientWelcomePage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

  // Worker button
                  Center(
                    child: RoundButton(
                      title: "Start_as_worker".tr,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WorkerWelcomePage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

 
}
