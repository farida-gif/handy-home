import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';

class ClientProfilePage extends StatelessWidget {
  final String name;
  final String phone;
  final String email;
  final String region;
  final String address;
  final String? userImageUrl;

  const ClientProfilePage({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.region,
    required this.address,
    this.userImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    //var media = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile Confirmation",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    "Thank you, $name!",
                    style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

// Display each info field using a reusable method
                  _buildInfoRow("📧 Email:", email),
                  _buildDivider(),
                  _buildInfoRow("📞 Phone:", phone),
                  _buildDivider(),
                  _buildInfoRow("📍 Region:", region),
                  _buildDivider(),
                  _buildInfoRow(
                    "🏠 Address:",
                    address,
                  ),
                  _buildDivider(),
                  const SizedBox(height: 20),

// Message shown after registration
                  const Text(
                    "thanks for updating your profile.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),

// Button to go back and edit the profile
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "done".tr,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
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

// Helper method to build a labeled info row
  Widget _buildInfoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

// Helper method to draw a divider between info sections
  Widget _buildDivider() {
    return const Divider(color: Colors.grey, thickness: 1, height: 25);
  }
}
