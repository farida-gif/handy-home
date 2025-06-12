import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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
  String? selectedAvatarPath; // For asset avatars
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

  // Predefined avatar options from assets
  final List<String> avatarAssets = [
    'assets/img/av5.jpg',
    'assets/img/av12.jpg',
    'assets/img/pw1.png',
    'assets/img/pw2.png',
    'assets/img/pw3.png',
    'assets/img/pw4.png',
    'assets/img/pw5.png',
    'assets/img/hk1.png',
    'assets/img/hk2.png',
    'assets/img/hk3.png',
    'assets/img/hk4.png',
    'assets/img/hk5.png',
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

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    nationalIdCtrl.dispose();
    descriptionCtrl.dispose();
    experienceCtrl.dispose();
    super.dispose();
  }

  TimeOfDay? _parseTime(String? str) {
    if (str == null || !str.contains(':')) return null;
    final parts = str.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
        selectedAvatarPath = null; // Clear avatar selection when custom image is chosen
      });
    }
  }

  Future<void> _pickNationalIdImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() => nationalIdImage = File(picked.path));
    }
  }

  void _selectAvatar(String avatarPath) {
    setState(() {
      selectedAvatarPath = avatarPath;
      profileImage = null; // Clear custom image when avatar is selected
    });
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'choose_profile_picture'.tr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Avatar selection grid
                Text(
                  'choose_avatar'.tr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: avatarAssets.length,
                    itemBuilder: (context, index) {
                      final avatarPath = avatarAssets[index];
                      final isSelected = selectedAvatarPath == avatarPath;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            _selectAvatar(avatarPath);
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                avatarPath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    child: Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey.shade600,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                const Divider(height: 32),
                
                // Custom image options
                Text(
                  'or_upload_custom'.tr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: Text('camera'.tr),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        leading: const Icon(Icons.photo),
                        title: Text('gallery'.tr),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('cancel'.tr),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNationalIdImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text('camera'.tr),
                onTap: () {
                  Navigator.pop(context);
                  _pickNationalIdImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: Text('gallery'.tr),
                onTap: () {
                  Navigator.pop(context);
                  _pickNationalIdImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text('cancel'.tr),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        cvFile = File(result.files.single.path!);
      });
    }
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
        selectedAvatarPath: selectedAvatarPath, // Pass the selected avatar path
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
            avatarPath: selectedAvatarPath,
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
            file != null ? '$label ${'uploaded'.tr}' : '$label ${'not_uploaded'.tr}',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Icon(
          file != null ? Icons.check_circle : Icons.warning_amber,
          color: file != null ? Colors.green : Colors.orange,
        ),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    if (profileImage != null) {
      return ClipOval(
        child: Image.file(
          profileImage!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    } else if (selectedAvatarPath != null) {
      return ClipOval(
        child: Image.asset(
          selectedAvatarPath!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, size: 50, color: Colors.white),
            );
          },
        ),
      );
    } else {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.person, size: 50, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('edit_profile'.tr, style: const TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Avatar Section
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _buildProfileAvatar(),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      onPressed: _showImageSourceActionSheet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Main Form Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section
                      _sectionTitle('basic_info'.tr),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: InputDecoration(labelText: 'full_name'.tr),
                        validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: InputDecoration(labelText: 'email'.tr),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: InputDecoration(labelText: 'phone_number'.tr),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.isEmpty ? 'phone_number'.tr : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nationalIdCtrl,
                        decoration: InputDecoration(labelText: 'national_id'.tr),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: experienceCtrl,
                        decoration: InputDecoration(labelText: 'experience_years'.tr),
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || int.tryParse(v) == null) ? 'Enter valid number' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionCtrl,
                        decoration: InputDecoration(labelText: 'description'.tr),
                        maxLines: 2,
                      ),
                      
                      const Divider(height: 32),
                      
                      // Region and Jobs Section
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
                      
                      // Availability Section
                      _sectionTitle('availability'.tr),
                      MultiSelectDropdown(
                        label: 'available_days'.tr,
                        hintText: 'choose_days'.tr,
                        options: daysOfWeek,
                        selectedValues: selectedDays,
                        onChanged: (v) => setState(() => selectedDays = v),
                      ),
                      const SizedBox(height: 12),
                      
                      // Time Selection
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
                              child: Text(startTime != null 
                                ? '${'start_time'.tr}: ${_formatTime(startTime!)}'
                                : 'start_time'.tr),
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
                              child: Text(endTime != null 
                                ? '${'end_time'.tr}: ${_formatTime(endTime!)}'
                                : 'end_time'.tr),
                            ),
                          ),
                        ],
                      ),
                      
                      const Divider(height: 32),
                      
                      // File Upload Section
                      _sectionTitle('documents'.tr),
                      
                      // CV Upload
                      _fileStatus('CV', cvFile),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.upload_file),
                        label: Text('upload_cv'.tr),
                        onPressed: _pickPDF,
                      ),
                      const SizedBox(height: 16),
                      
                      // National ID Image Upload
                      _fileStatus('National ID Image', nationalIdImage),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: Text('upload_national_id_image'.tr),
                        onPressed: _showNationalIdImageSourceActionSheet,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Save Button
                      Center(
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          ),
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