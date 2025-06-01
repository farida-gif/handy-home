import 'package:flutter/material.dart';
import 'package:handy_home2/pages/clients_pages/booking_pages/General_booking_calender.dart';
import 'package:handy_home2/pages/clients_pages/services_workers/appartment_finishing_page.dart';
import 'package:handy_home2/repo/service_repo.dart';

class HomeFinishing extends StatefulWidget {
  const HomeFinishing({super.key});

  @override
  State<HomeFinishing> createState() => _HomeFinishingState();
}

class _HomeFinishingState extends State<HomeFinishing> {
  List<String> specializations = [];
  String selectedSpecialization = '';
  String serviceDescription = '';
  double? price = 15000.0; // Default price for Apartment Finishing
  final String serviceCategory = 'Apartment Finishing';

  @override
  void initState() {
    super.initState();
    _fetchServiceData();
  }

  Future<void> _fetchServiceData() async {
    try {
      List<String> fetchedSpecializations =
          await ServiceRepo().fetchServiceSpecializations('Apartment Finishing');
      String description =
          await ServiceRepo().fetchServiceDescription('Apartment Finishing');
      double fetchedPrice =
          await ServiceRepo().fetchServicePrice('Apartment Finishing');

      setState(() {
        specializations = fetchedSpecializations;
        selectedSpecialization =
            specializations.isNotEmpty ? specializations[0] : 'Other';
        serviceDescription = description;
        price = fetchedPrice;
      });
    } catch (e) {
      print('Error fetching apartment finishing data: $e');
    }
  }

  // Estimated time in days based on price
  int _estimateTime(double price) {
    if (price <= 20000) return 3;
    if (price <= 40000) return 5;
    return 7;
  }

  // Dialog for choosing worker or not
  void showMainDialog({
    required double price,
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
                  builder: (_) => AppartmentFinishingWorkers(
                    totalPrice: price,
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
                    totalPrice: price,
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          "Apartment Finishing",
          style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        ),
      ),
      body: price == null
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
                        'assets/img/app.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "About the Apartment Finishing Service",
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
                            '🏠 Price: Starts from ${price!.toStringAsFixed(0)} LE\nDeposit Payment: 20% ',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '🕒 Duration: Around ${_estimateTime(price!)} days (varies by scope)',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '🔧 Select Specialization:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
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
                          const SizedBox(height: 30),

                          // Book Now Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                showMainDialog(
                                  price: price!,
                                  estimatedTime: _estimateTime(price!),
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
