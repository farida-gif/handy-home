import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_home2/pages/workers_pages/worker_home_page.dart';

class WorkerInfoPage extends StatelessWidget {
  final String name;
  final String phone;
  final String email;
  final List<String> selectedJobs;
  final List<String> region;
  final String nationalIdNumber;
  final bool isCVUploaded;
  final List<String> availableDays;
  final String startTime;
  final String endTime;
  final String? userImageUrl; // For uploaded image from gallery/camera
  final String? avatarPath;   // For asset avatar image

  const WorkerInfoPage({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.selectedJobs,
    required this.region,
    required this.nationalIdNumber,
    required this.isCVUploaded,
    required this.availableDays,
    required this.startTime,
    required this.endTime,
    this.userImageUrl,
    this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Avatar and Name Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: userImageUrl != null
                      ? FileImage(File(userImageUrl!))
                      : avatarPath != null
                          ? AssetImage(avatarPath!) as ImageProvider
                          : null,
                  child: userImageUrl == null && avatarPath == null
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Fields List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildInfoCard(context, Icons.phone, 'phone_number'.tr, phone),
                _buildInfoCard(
                    context, Icons.credit_card, 'national_id'.tr, nationalIdNumber),
                _buildInfoCard(
                    context,
                    Icons.location_on,
                    'region'.tr,
                    region.isNotEmpty ? region.join(', ') : 'no_region_selected'.tr),
                _buildInfoCard(
                    context,
                    Icons.work,
                    'jobs'.tr,
                    selectedJobs.isNotEmpty ? selectedJobs.join(', ') : 'no_jobs_selected'.tr),
                _buildInfoCard(
                    context,
                    Icons.today,
                    'available_days'.tr,
                    availableDays.isNotEmpty ? availableDays.join(', ') : 'no_days_selected'.tr),
                _buildInfoCard(context, Icons.schedule, 'working_hours'.tr, '$startTime - $endTime'),
                _buildInfoCard(context, Icons.file_present, 'cv_uploaded'.tr,
                    isCVUploaded ? 'yes'.tr : 'no'.tr),

                const SizedBox(height: 30),

                // Done Button
                ElevatedButton.icon(
                  onPressed: () {
                    try {
                      Get.offAll(() => const WorkerHomePage());
                    } catch (_) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const WorkerHomePage()),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text('done'.tr),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Info Card Widget
  Widget _buildInfoCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
