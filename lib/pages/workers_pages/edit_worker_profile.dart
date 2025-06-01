import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:handy_home2/common_widgets/dropdown_list.dart';
import 'package:handy_home2/models/workers.dart';
import 'package:handy_home2/repo/workers_repo.dart';
import 'worker_info_page.dart';

class EditWorkerProfilePage extends StatefulWidget {
  final WorkerProfile worker;

  const EditWorkerProfilePage({super.key, required this.worker});

  @override
  State<EditWorkerProfilePage> createState() => _EditWorkerProfilePageState();
}

class _EditWorkerProfilePageState extends State<EditWorkerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController nationalIdCtrl;
  late TextEditingController descriptionCtrl;
  late TextEditingController experienceCtrl;

  List<String> selectedRegions = [];
  List<String> selectedJobs = [];
  List<String> selectedDays = [];

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  File? profileImage;
  File? nationalIdImage;
  File? cvFile;

  final List<String> daysOfWeek = [
    'Monday'.tr, 'Tuesday'.tr, 'Wednesday'.tr, 'Thursday'.tr,
    'Friday'.tr, 'Saturday'.tr, 'Sunday'.tr,
  ];

  final List<String> regionOptions = [
    'New Cairo'.tr, 'Maadii'.tr, 'Zamalek'.tr, 'Zayed'.tr,
    'Nasr City'.tr, 'Heliopolis'.tr, 'October City'.tr,
  ];

  final List<String> allJobs = [
    'Plumber'.tr, 'Electrician'.tr, 'Carpenter'.tr,
    'Cleaner'.tr, 'Painter'.tr, 'Baby Sitter'.tr, 'Apartment Finishing'.tr,
  ];

  @override
  void initState() {
    super.initState();
    final w = widget.worker;

    nameCtrl = TextEditingController(text: w.name ?? '');
    emailCtrl = TextEditingController(text: w.email ?? '');
    phoneCtrl = TextEditingController(text: w.phone ?? '');
    nationalIdCtrl = TextEditingController(text: w.nationalIdNumber ?? '');
    descriptionCtrl = TextEditingController(text: w.description ?? '');
    experienceCtrl = TextEditingController(text: w.experienceYears?.toString() ?? '');

    selectedRegions = List<String>.from(w.region ?? []);
    selectedJobs = List<String>.from(w.jobs ?? []);
    selectedDays = List<String>.from(w.availableDays ?? []);
    startTime = _parseTime(w.startTime);
    endTime = _parseTime(w.endTime);
  }

  TimeOfDay? _parseTime(String? str) {
    if (str == null || !str.contains(':')) return null;
    final parts = str.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickImage(Function(File) onPicked) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) onPicked(File(picked.path));
  }


  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final experience = int.tryParse(experienceCtrl.text.trim());
    if (experience == null) {
      _showError('experience_years'.tr);
      return;
    }

    if (startTime == null || endTime == null) {
      _showError('select_time_error'.tr);
      return;
    }

    try {
      await WorkersRepo.instance.saveWorkerProfile(
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        nationalIdNumber: nationalIdCtrl.text.trim(),
        region: selectedRegions,
        selectedJobs: selectedJobs,
        description: descriptionCtrl.text.trim(),
        availableDays: selectedDays,
        startTime: _formatTime(startTime!),
        endTime: _formatTime(endTime!),
        experienceYears: experience,
        profileImageBytes: profileImage != null ? await profileImage!.readAsBytes() : null,
        nationalIdImageBytes: nationalIdImage != null ? await nationalIdImage!.readAsBytes() : null,
        cvFile: cvFile,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkerInfoPage(
            name: nameCtrl.text.trim(),
            phone: phoneCtrl.text.trim(),
            email: emailCtrl.text.trim(),
            selectedJobs: selectedJobs,
            region: selectedRegions,
            nationalIdNumber: nationalIdCtrl.text.trim(),
            isCVUploaded: cvFile != null,
            availableDays: selectedDays,
            startTime: _formatTime(startTime!),
            endTime: _formatTime(endTime!),
            userImageUrl: profileImage?.path,
          ),
        ),
      );
    } catch (e) {
      _showError("Update failed: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _fileStatus(String label, File? file) {
    return Row(
      children: [
        Expanded(
  child: Text(
    file != null
        ? '${label} ${'uploaded'.tr}'  // label + translated "uploaded"
        : '${label} ${'not_uploaded'.tr}',  // label + translated "not_uploaded"
    style: const TextStyle(fontSize: 14),
  ),
),
        if (file != null)
          const Icon(Icons.check_circle, color: Colors.green)
        else
          const Icon(Icons.warning_amber, color: Colors.orange),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'edit_profile'.tr,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        profileImage != null ? FileImage(profileImage!) : null,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: profileImage == null
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => _pickImage((f) => setState(() => profileImage = f)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Basic Info
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('basic_info'.tr),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: InputDecoration(labelText: 'full_name'.tr),
                        validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                      ),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: InputDecoration(labelText: 'email'.tr),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null,
                      ),
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: InputDecoration(labelText: 'phone_number'.tr),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.isEmpty ? 'phone_number'.tr : null,
                      ),
                      TextFormField(
                        controller: nationalIdCtrl,
                        decoration: InputDecoration(labelText: 'national_id'.tr),
                      ),
                      TextFormField(
                        controller: experienceCtrl,
                        decoration: InputDecoration(labelText: 'experience_years'.tr),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || int.tryParse(v) == null)
                            ? 'Enter valid number'
                            : null,
                      ),
                      TextFormField(
                        controller: descriptionCtrl,
                        decoration: InputDecoration(labelText: 'description'.tr),
                        maxLines: 2,
                      ),
                      const Divider(height: 8),

                      // Region & Job Selection
                      _sectionTitle('region_jobs'.tr),
                      MultiSelectDropdown(
                        label: 'select_region'.tr,
                        hintText: 'choose_regions'.tr,
                        options: regionOptions,
                        selectedValues: selectedRegions,
                        onChanged: (v) => setState(() => selectedRegions = v),
                      ),
                      const SizedBox(height: 12),
                      MultiSelectDropdown(
                        label: 'select_jobs'.tr,
                        hintText: 'choose_jobs'.tr,
                        options: allJobs,
                        selectedValues: selectedJobs,
                        onChanged: (v) => setState(() => selectedJobs = v),
                      ),
                      const Divider(height: 32),

                      // Availability
                      _sectionTitle('availability'.tr),
                      MultiSelectDropdown(
                        label: 'available_days'.tr,
                        hintText: 'choose_days'.tr,
                        options: daysOfWeek,
                        selectedValues: selectedDays,
                        onChanged: (v) => setState(() => selectedDays = v),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: startTime ?? TimeOfDay.now(),
                                );
                                if (picked != null) setState(() => startTime = picked);
                              },
                              child: Text('start_time'.tr),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: endTime ?? TimeOfDay.now(),
                                );
                                if (picked != null) setState(() => endTime = picked);
                              },
                              child: Text('end_time'.tr),
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 32),

                      // File Upload Status
                      _sectionTitle('attachments'.tr),
                      _fileStatus('cv'.tr, cvFile),
                      const SizedBox(height: 6),
                      _fileStatus('nationalIdImage'.tr, nationalIdImage),

                      const SizedBox(height: 24),

                      Center(
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: Text('save_changes'.tr),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
