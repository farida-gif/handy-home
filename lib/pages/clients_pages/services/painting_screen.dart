import 'package:flutter/material.dart';
import 'package:handy_home2/pages/clients_pages/booking_pages/General_booking_calender.dart';
import 'package:handy_home2/pages/clients_pages/services_workers/painting_workers_page.dart';
import 'package:handy_home2/repo/service_repo.dart';

class PaintingScreen extends StatefulWidget {
  const PaintingScreen({super.key});

  @override
  State<PaintingScreen> createState() => _PaintingScreenState();
}

class _PaintingScreenState extends State<PaintingScreen> {
  List<String> specializations = [];
  String selectedSpecialization = '';
  String serviceDescription = '';
  double? basePricePerRoom; // Base price per room
  final String serviceCategory = 'Painting';
  int roomCount = 1; // Default room count

  @override
  void initState() {
    super.initState();
    _fetchServiceData();
  }

  void _fetchServiceData() async {
    try {
      List<String> fetchedSpecializations =
          await ServiceRepo().fetchServiceSpecializations(serviceCategory);
      String description =
          await ServiceRepo().fetchServiceDescription(serviceCategory);
      double fetchedPrice =
          await ServiceRepo().fetchServicePrice(serviceCategory); // Price per room

      setState(() {
        specializations = fetchedSpecializations;
        selectedSpecialization =
            specializations.isNotEmpty ? specializations[0] : 'Other';
        serviceDescription = description;
        basePricePerRoom = fetchedPrice;
      });
    } catch (e) {
      print('Error fetching painting service data: $e');
    }
  }

  /// Calculate estimated time in hours based on total price
  int _estimateTime(double totalPrice) {
    if (totalPrice <= 300) return 2;
    if (totalPrice <= 600) return 4;
    return 5;
  }

  /// Dialog for choosing worker or not
  void showMainDialog({
    required double totalPrice,
    required int estimatedTime,
    required String selectedSpecialization,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Choose Worker"),
        content: const Text("Do you want to choose the worker yourself?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaintingWorkersPage(
                    totalPrice: totalPrice,
                    estimatedTime: estimatedTime,
                    selectedSpecialization: selectedSpecialization,
                  ),
                ),
              );
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GeneralBookingCalendarPage(
                    serviceCategory: serviceCategory,
                    totalPrice: totalPrice,
                    estimatedTime: estimatedTime,
                    selectedSpecialization: selectedSpecialization,
                  ),
                ),
              );
            },
            child: const Text("No"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double totalPrice = (basePricePerRoom ?? 0) * roomCount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          "Painting Service",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        ),
      ),
      body: basePricePerRoom == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.4,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/img/paint.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "About the Painting Service",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            serviceDescription,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '🛏️ Select Number of Rooms:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (roomCount > 1) {
                                    setState(() {
                                      roomCount--;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(
                                '$roomCount',
                                style: const TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    roomCount++;
                                  });
                                },
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '💰 Total Price: ${totalPrice.toStringAsFixed(0)} LE',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '🕒 Estimated Duration: ${_estimateTime(totalPrice)} hours',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '🎨 Select Specialization:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: selectedSpecialization,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedSpecialization = value;
                                });
                              }
                            },
                            items: specializations.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                          ),
                          const SizedBox(height: 40.0),

                          // Book Now Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                int estimatedTime = _estimateTime(totalPrice);
                                showMainDialog(
                                  totalPrice: totalPrice,
                                  estimatedTime: estimatedTime,
                                  selectedSpecialization: selectedSpecialization,
                                );
                              },
                              child: const Text("Proceed to Booking"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
