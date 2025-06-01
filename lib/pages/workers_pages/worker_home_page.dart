import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_home2/common_widgets/round_button.dart';
import 'package:handy_home2/pages/workers_pages/drawer/workers_drawer.dart';
import 'package:handy_home2/pages/workers_pages/edit_worker_profile.dart';
import 'package:handy_home2/repo/workers_repo.dart';
import 'package:handy_home2/models/workers.dart';

class WorkerHomePage extends StatefulWidget {
  const WorkerHomePage({super.key});

  @override
  State<WorkerHomePage> createState() => _WorkerHomePageState();
}

class _WorkerHomePageState extends State<WorkerHomePage> {
  WorkerProfile? _workerProfile;
  bool _loading = true;

  String selectedLanguage = Get.locale?.languageCode ?? 'en';

  void changeLanguage(String code) {
    Locale locale = Locale(code);
    Get.updateLocale(locale);
    setState(() => selectedLanguage = code);
  }

  @override
  void initState() {
    super.initState();
    _loadWorkerProfile();
  }

  Future<void> _loadWorkerProfile() async {
    final profile = await WorkersRepo.instance.getWorkerProfile();
    setState(() {
      _workerProfile = profile;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text("worker_home_title".tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: _workerProfile != null ? WorkersDrawer(worker: _workerProfile!) : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
    //BG image
                Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    "assets/img/bg3.jpg",
                    width: media.width,
                    height: media.height,
                    fit: BoxFit.cover,
                  ),
                ),
    //logo image
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/img/logo2.png",
                          width: media.width * 0.6,
                          height: media.width * 0.6,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 25),

                        // Approval status
                        _buildApprovalStatus(_workerProfile!.isApproved),
                        const SizedBox(height: 32),

                        // If not approved - encouragement message
                        if (!_workerProfile!.isApproved) ...[
                          Text(
                            "next_step_career".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "apply_cv_message".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

  // If approved - urgent orders message
                        if (_workerProfile!.isApproved) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              border: Border.all(color: Colors.red, width: 2),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                                    const SizedBox(width: 8),
                                    Text(
                                      'urgent_notice'.tr,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "urgent_orders_message".tr,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '${'current_rating'.trParams({'rating': _workerProfile!.rating?.toStringAsFixed(1) ?? 'N/A'.tr})} ⭐',

                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

  // button
                        RoundButton(
                          title: _workerProfile!.isApproved ? "edit_profile".tr : "apply_now".tr,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditWorkerProfilePage(worker: _workerProfile!),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildApprovalStatus(bool isApproved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isApproved ? Colors.green[50] : Colors.orange[50],
        border: Border.all(color: isApproved ? Colors.green : Colors.orange),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isApproved ? Icons.check_circle : Icons.pending_actions,
            color: isApproved ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            isApproved ? "approval_approved".tr : "approval_pending".tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isApproved ? Colors.green : Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }
}
