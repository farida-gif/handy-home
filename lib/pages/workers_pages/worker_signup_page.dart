import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_home2/common_widgets/dropdown_list.dart';
import 'package:handy_home2/common_widgets/round_button.dart';
import 'package:handy_home2/common_widgets/round_textfield.dart';
import 'package:handy_home2/pages/workers_pages/worker_home_page.dart';
import 'package:handy_home2/repo/workers_repo.dart';

class WorkerSignupPage extends StatefulWidget {
  const WorkerSignupPage({super.key});

  @override
  State<WorkerSignupPage> createState() => _WorkerSignupPageState();
}

class _WorkerSignupPageState extends State<WorkerSignupPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final nationalIdController = TextEditingController();
  final experienceController = TextEditingController();
  final descriptionController = TextEditingController();

  List<String> selectedRegion = [];
  List<String> selectedJobs = [];
  List<String> availableDays = [];
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
final supportedLocales = const [
    Locale('en', 'US'),
    Locale('fr', 'FR'),
    Locale('ar', 'DZ'),
  ];

  final List<String> regionOptions = [
    'New Cairo'.tr, 'Maadii'.tr, 'Zamalek'.tr, 'Zayed'.tr, 'Nasr City'.tr, 'Heliopolis'.tr, 'October City'.tr,
  ];

  final List<String> allJobs = [
    'Plumber'.tr, 'Electrician'.tr, 'Carpenter'.tr, 
    'Cleaner'.tr, 'Painter'.tr, 'Baby Sitter'.tr, 'Apartment Finishing'.tr,
  ];

  final List<String> daysOfWeek = [
    'Monday'.tr, 'Tuesday'.tr, 'Wednesday'.tr, 'Thursday'.tr,
     'Friday'.tr, 'Saturday'.tr, 'Sunday'.tr,
  ];

 
  void showInlineError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: startTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => startTime = picked);
  }

  void selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: endTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => endTime = picked);
  }

  //String _translateOption(String key) => key.tr;

  void validateAndSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedRegion.isEmpty) return showInlineError('select_region_error'.tr);
    if (selectedJobs.isEmpty) return showInlineError('select_job_error'.tr);
    if (availableDays.isEmpty) return showInlineError('select_day_error'.tr);
    if (startTime == null || endTime == null) return showInlineError('select_time_error'.tr);
    if (descriptionController.text.trim().isEmpty) return showInlineError('enter_description_error'.tr);
    if (passwordController.text != confirmPasswordController.text) return showInlineError('password_mismatch_error'.tr);

    final experienceText = experienceController.text.trim();
    final experienceYears = int.tryParse(experienceText);
    if (experienceYears == null || experienceYears < 0) {
      return showInlineError('invalid_experience_error'.tr);
    }

    try {
      await WorkersRepo.instance.workerSignUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        nationalId: nationalIdController.text.trim(),
        region: selectedRegion,
        selectedJobs: selectedJobs,
        experienceYears: experienceYears,
        description: descriptionController.text.trim(),
        availableDays: availableDays,
        startTime: startTime!.format(context),
        endTime: endTime!.format(context),
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WorkerHomePage()));
    } catch (e) {
      showInlineError("${'signup_failed'.tr}: ${e.toString()}");
    }
  }

 @override
Widget build(BuildContext context) {
   Locale selectedLocale = supportedLocales.first;
    for (final locale in supportedLocales) {
      if (locale.languageCode == Get.locale?.languageCode &&
          locale.countryCode == Get.locale?.countryCode) {
        selectedLocale = locale;
        break;
      }
    }

  return Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Form(
        key: _formKey,
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
  //logo img
            Image.asset("assets/img/logo2.png", width: 400, height: 250),
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
            const SizedBox(height: 16),
           
  //fields
            RoundTextField(controller: fullNameController, hintText: 'full_name'.tr),
            const SizedBox(height: 12),
            RoundTextField(controller: emailController, hintText: 'email'.tr),
            const SizedBox(height: 12),
            RoundTextField(
              controller: passwordController,
              hintText: 'password'.tr,
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            const SizedBox(height: 12),
            RoundTextField(
              controller: confirmPasswordController,
              hintText: 'confirm_password'.tr,
              obscureText: !_isConfirmPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              ),
            ),
            const SizedBox(height: 12),
            RoundTextField(controller: phoneNumberController, hintText: 'phone_number'.tr),
            const SizedBox(height: 12),
            RoundTextField(controller: nationalIdController, hintText: 'national_id'.tr),
            const SizedBox(height: 12),
            RoundTextField(
              controller: experienceController,
              hintText: 'experience_years'.tr,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
  // Region Dropdown
            MultiSelectDropdown(
              label: 'select_region'.tr,
              hintText: 'select_region',
              options: regionOptions,
              selectedValues: selectedRegion,
              onChanged: (values) => setState(() => selectedRegion = values),
            ),
            const SizedBox(height: 16),

  // Jobs Dropdown
            MultiSelectDropdown(
              label: 'select_jobs'.tr,
              hintText: 'select_jobs',
              options: allJobs,
              selectedValues: selectedJobs,
              onChanged: (values) => setState(() => selectedJobs = values),
            ),
            const SizedBox(height: 16),

  // Available Days Dropdown
            MultiSelectDropdown(
              label: 'available_days'.tr,
              hintText: 'available_days',
              options: daysOfWeek,
              selectedValues: availableDays,
              onChanged: (values) => setState(() => availableDays = values),
            ),
            const SizedBox(height: 16),
     //time chosen
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectStartTime,
                    child: Text(startTime == null ? 'start_time'.tr : startTime!.format(context)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectEndTime,
                    child: Text(endTime == null ? 'end_time'.tr : endTime!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
   //description
            RoundTextField(controller: descriptionController, hintText: 'description'.tr),
            const SizedBox(height: 20),
   //signup button
            RoundButton(title: 'sign_up'.tr, onPressed: validateAndSubmit),
            const SizedBox(height: 20),
  //login button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("already_have_account".tr),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Get.back(), // or Get.to(LoginPage()) if you have it
                  child: Text(
                    "login".tr,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );}}