import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:handy_home2/pages/clients_pages/menu_pages/client_profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:handy_home2/repo/client_repo.dart';

class EditClientProfilePage extends StatefulWidget {
  const EditClientProfilePage({super.key});

  @override
  State<EditClientProfilePage> createState() => _EditClientProfilePageState();
}

class _EditClientProfilePageState extends State<EditClientProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  Uint8List? _profileImage;

  String? region;
  bool isDropdownOpen = false;

  final regionOptions = [
    "New Cairo",
    "Maadii",
    "Zamalek",
    "Zayed",
    "Nasr City"
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

   Future<void> _loadProfileData() async {
    final profile = await ClientsRepo.instance.getClientProfile();
    if (profile != null) {
      setState(() {
        nameCtrl.text = profile.name;
        phoneCtrl.text = profile.phone ;
        emailCtrl.text = profile.email;
        addressCtrl.text = profile.address;
        region = profile.region;
      });
    }
  }

  Future<void> pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() => _profileImage = bytes);
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ClientsRepo.instance.saveClientProfile(
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      region: region!,
      profileImageBytes: _profileImage,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ClientProfilePage(
          name: nameCtrl.text.trim(),
          phone: phoneCtrl.text.trim(),
          email: emailCtrl.text.trim(),
          address: addressCtrl.text.trim(),
          region: region!,
          userImageUrl: null,
        ),
      ),
    );
  }

  final blackBorder = const UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.black),
  );
  final blackFocusedBorder = const UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 2),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Edit Client Profile', style: TextStyle(color: Colors.white)),
          backgroundColor: Theme.of(context).primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImage != null ? MemoryImage(_profileImage!) : null,
                    child: _profileImage == null ? const Icon(Icons.add_a_photo) : null,
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Profile image is optional', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 20),

                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: blackBorder,
                    enabledBorder: blackBorder,
                    focusedBorder: blackFocusedBorder,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter phone' : null,
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter email' : null,
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter address' : null,
                ),
                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: region,
                  decoration: InputDecoration(
                    labelText: 'Select Region',
                    border: blackBorder,
                    enabledBorder: blackBorder,
                    focusedBorder: blackFocusedBorder,
                  ),
                  items: regionOptions
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setState(() => region = v),
                  validator: (v) => v == null ? 'Pick region' : null,
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: submit,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      );
}
