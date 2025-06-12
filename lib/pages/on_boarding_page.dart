import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_home2/pages/welcome_page.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  int page = 0;
  late final PageController controller;

  final List<Map<String, String>> pageArr = [
    {
      "title": "Exceptional Service \nExceptional Care ",
      "sub_title": "",
      "img": "assets/img/onboard22.png"
    },
    {
      "title": "Book in Seconds\n Get Help in Minutes",
      "sub_title": "",
      "img": "assets/img/baby3.png"
    },
    {
      "title": "Excellence Delivered \n At Your Doorstep",
      "sub_title": " ",
      "img": "assets/img/p1.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: controller,
              itemCount: pageArr.length,
              onPageChanged: (index) {
                setState(() {
                  page = index;
                });
              },
              itemBuilder: (context, index) {
                var pObj = pageArr[index];
                return SingleChildScrollView(
                  child: Container(
                    width: media.width,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          pObj["title"] ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Text(
                          pObj["sub_title"] ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: media.width / 12),
                        Image.asset(
                          pObj["img"] ?? '',
                          fit: BoxFit.fitWidth,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Language button
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.language, size: 28),
                onPressed: () {
                  _showLanguageSelector(context);
                },
              ),
            ),

            // Bottom Controls
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip Button
                      TextButton(
                        onPressed: () {
                          Get.offAll(() => const WelcomePage());
                        },
                        child: Text(
                          "skip".tr,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      // Page Dots
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(pageArr.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: page == index
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(7.5),
                            ),
                          );
                        }),
                      ),

                      // Next Button
                      TextButton(
                        onPressed: () {
                          if (page < pageArr.length - 1) {
                            controller.animateToPage(
                              page + 1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            Get.offAll(() => const WelcomePage());
                          }
                        },
                        child: Text(
                          page == pageArr.length - 1 ? "done".tr : "next".tr,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: media.width * 0.15),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Language selector modal
  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'select_language'.tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('English'),
                onTap: () {
                  Get.updateLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Français'),
                onTap: () {
                  Get.updateLocale(const Locale('fr'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('العربية'),
                onTap: () {
                  Get.updateLocale(const Locale('ar'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
