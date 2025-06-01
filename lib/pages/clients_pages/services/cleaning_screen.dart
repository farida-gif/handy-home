import 'package:flutter/material.dart';
import 'package:handy_home2/pages/clients_pages/booking_pages/General_booking_calender.dart';
import 'package:handy_home2/pages/clients_pages/services_workers/cleaning_workers_page.dart';
import 'package:handy_home2/repo/service_repo.dart';

class CleaningScreen extends StatefulWidget {
  const CleaningScreen({super.key});

  @override
  State<CleaningScreen> createState() => _CleaningScreenState();
}

class _CleaningScreenState extends State<CleaningScreen> {
  List<String> specializations = [];
  String selectedSpecialization = '';
  String serviceDescription = '';
  double? price;
  int numberOfRooms = 1;
  final String serviceCategory = 'Cleaning';

  double get totalPrice => (price ?? 0) * numberOfRooms;

  @override
  void initState() {
    super.initState();
    _fetchServiceData();
  }

  void _fetchServiceData() async {
    try {
      List<String> fetchedSpecializations =
          await ServiceRepo().fetchServiceSpecializations('Cleaning');
      String description =
          await ServiceRepo().fetchServiceDescription('Cleaning');
      double fetchedPrice = await ServiceRepo().fetchServicePrice('Cleaning');

      setState(() {
        specializations = fetchedSpecializations;
        selectedSpecialization =
            specializations.isNotEmpty ? specializations[0] : 'Other';
        serviceDescription = description;
        price = fetchedPrice;
      });
    } catch (e) {
      print('Error fetching Cleaning service data: $e');
    }
  }

  int _estimateTime(double price) {
    if (price <= 300) return 2;
    if (price <= 600) return 4;
    if (price <= 800) return 5;
    if (price <= 1000) return 6;
    return 8;
  }

  void showMainDialog({
    required String title,
    required double price,
    required int EstimatedTime,
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
                  builder: (_) => CleaningWorkersPage(
                    totalPrice: price,
                    EstimatedTime: EstimatedTime,
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
                    estimatedTime: EstimatedTime,
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
          "Cleaning Service",
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
                            "About the Cleaning Service",
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
                            '🛏️ Number of Rooms:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: numberOfRooms > 1
                                    ? () => setState(() => numberOfRooms--)
                                    : null,
                              ),
                              Text(
                                numberOfRooms.toString(),
                                style: const TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () =>
                                    setState(() => numberOfRooms++),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '💰 Price per room: ${price!.toStringAsFixed(0)} LE',
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
                            '🕒 Estimated Time: Up to ${_estimateTime(totalPrice)} hours',
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
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                showMainDialog(
                                  title: "Cleaning Booking",
                                  price: totalPrice, // Use totalPrice
                                  EstimatedTime: _estimateTime(totalPrice), // Use totalPrice for EstimatedTime
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
