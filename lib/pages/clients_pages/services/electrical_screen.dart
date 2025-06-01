import 'package:flutter/material.dart';
import 'package:handy_home2/pages/clients_pages/booking_pages/General_booking_calender.dart';
import 'package:handy_home2/pages/clients_pages/services_workers/electrical_workers_page.dart';
import 'package:handy_home2/repo/service_repo.dart';

class ElectricalScreen extends StatefulWidget {
  const ElectricalScreen({super.key});

  @override
  State<ElectricalScreen> createState() => _ElectricalScreenState();
}

class _ElectricalScreenState extends State<ElectricalScreen> {
  List<String> specializations = [];
  String selectedSpecialization = '';
  String serviceDescription = '';
  double? pricePerUnit;
  final String serviceCategory = 'Electrical';

  int numberOfItems = 1;

  double get totalPrice => (pricePerUnit ?? 0) * numberOfItems;

  @override
  void initState() {
    super.initState();
    _fetchServiceData();
  }

  void _fetchServiceData() async {
    try {
      List<String> fetchedSpecializations =
          await ServiceRepo().fetchServiceSpecializations('Electrical');
      String description =
          await ServiceRepo().fetchServiceDescription('Electrical');
      double fetchedPrice = await ServiceRepo().fetchServicePrice('Electrical');

      setState(() {
        specializations = fetchedSpecializations;
        selectedSpecialization =
            specializations.isNotEmpty ? specializations[0] : 'Other';
        serviceDescription = description;
        pricePerUnit = fetchedPrice;
      });
    } catch (e) {
      print('Error fetching Electrical service data: $e');
    }
  }

  int _calculateEstimatedTime() {
    double price = totalPrice;
    if (price <= 300) return 2;
    if (price <= 600) return 4;
    return 5;
  }

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
                  builder: (_) => ElectricalWorkersPage(
                    totalPrice: totalPrice,
                    EstimatedTime: estimatedTime,
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          "Electrical Service",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        ),
      ),
      body: pricePerUnit == null
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
                        'assets/img/e.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "About the Electrical Service",
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
                            '🏠 Number of Items:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (numberOfItems > 1) {
                                    setState(() {
                                      numberOfItems--;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.remove_circle),
                              ),
                              Text(
                                '$numberOfItems',
                                style: const TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    numberOfItems++;
                                  });
                                },
                                icon: const Icon(Icons.add_circle),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '💰 Price per item: ${pricePerUnit!.toStringAsFixed(0)} LE',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '💰 Total Price: ${totalPrice.toStringAsFixed(0)} LE',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '🕒 Estimated Time: Up to ${_calculateEstimatedTime()} hours',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '⚡ Select Specialization:',
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
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                int estimatedTime = _calculateEstimatedTime();
                                showMainDialog(
                                  totalPrice: totalPrice,
                                  estimatedTime: estimatedTime,
                                  selectedSpecialization:
                                      selectedSpecialization,
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
