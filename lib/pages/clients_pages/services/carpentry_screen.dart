import 'package:flutter/material.dart';
import 'package:handy_home2/pages/clients_pages/booking_pages/General_booking_calender.dart';
import 'package:handy_home2/pages/clients_pages/services_workers/carpentry_workers_page.dart';
import 'package:handy_home2/repo/service_repo.dart';

class CarpentryScreen extends StatefulWidget {
  const CarpentryScreen({super.key});

  @override
  State<CarpentryScreen> createState() => _CarpentryScreenState();
}

class _CarpentryScreenState extends State<CarpentryScreen> {
  List<String> specializations = [];
  String selectedSpecialization = '';
  String serviceDescription = '';
  double? basePrice;
  int roomCount = 1; // default 1 room
  late final String serviceCategory = 'Carpentry';

  @override
  void initState() {
    super.initState();
    _fetchServiceData();
  }

  void _fetchServiceData() async {
    try {
      List<String> fetchedSpecializations =
          await ServiceRepo().fetchServiceSpecializations('Carpentry');
      String description =
          await ServiceRepo().fetchServiceDescription('Carpentry');
      double fetchedPrice = await ServiceRepo().fetchServicePrice('Carpentry');

      setState(() {
        specializations = fetchedSpecializations;
        selectedSpecialization =
            specializations.isNotEmpty ? specializations[0] : 'Other';
        serviceDescription = description;
        basePrice = fetchedPrice;
      });
    } catch (e) {
      print('Error fetching Carpentry service data: $e');
    }
  }

  double _calculateTotalPrice() {
    return (basePrice ?? 0) * roomCount;
  }

  int _estimateDurationHours(double totalPrice) {
    if (totalPrice <= 300) return 2;
    if (totalPrice <= 600) return 4;
    return 5;
  }

  void showMainDialog({
    required String title,
    required double price,
    required int estimatedHours,
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
                  builder: (_) => CarpentryWorkersPage(
                    totalPrice: price,
                    EstimatedTime: estimatedHours,
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
                    totalPrice: price,
                    estimatedTime: estimatedHours,
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          "Carpentry Service",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        ),
      ),
      body: basePrice == null
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
                        'assets/img/carp.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "About the Carpentry Service",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            serviceDescription,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),

                          // Room Count Input
                          Text(
                            '🏠 Number of Items:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
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
                                icon: const Icon(Icons.remove_circle),
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
                                icon: const Icon(Icons.add_circle),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Total Price
                          Text(
                            '💰 Total Price: ${_calculateTotalPrice().toStringAsFixed(0)} LE',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),

                          const SizedBox(height: 16),
                          Text(
                            '🕒 Estimated Duration: Up to ${_estimateDurationHours(_calculateTotalPrice())} hours',
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
                          const SizedBox(height: 50.0),

                          // Book Now Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                double totalPrice = _calculateTotalPrice();
                                int estimatedHours =
                                    _estimateDurationHours(totalPrice);
                                showMainDialog(
                                  title: "Carpentry Booking",
                                  price: totalPrice,
                                  estimatedHours: estimatedHours,
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
