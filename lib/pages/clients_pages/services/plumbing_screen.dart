import 'package:flutter/material.dart';
import 'package:handy_home2/pages/clients_pages/booking_pages/General_booking_calender.dart';
import 'package:handy_home2/pages/clients_pages/services_workers/plumbing_workers_page.dart';
import 'package:handy_home2/repo/service_repo.dart';

class PlumbingScreen extends StatefulWidget {
  const PlumbingScreen({super.key});

  @override
  State<PlumbingScreen> createState() => _PlumbingScreenState();
}

class _PlumbingScreenState extends State<PlumbingScreen> {
  List<String> specializations = [];
  String selectedSpecialization = '';
  String serviceDescription = '';
  double? basePrice;
  int itemCount = 1;

  final String serviceCategory = 'Plumbing';

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
          await ServiceRepo().fetchServicePrice(serviceCategory);

      setState(() {
        specializations = fetchedSpecializations;
        selectedSpecialization =
            specializations.isNotEmpty ? specializations[0] : 'Other';
        serviceDescription = description;
        basePrice = fetchedPrice;
      });
    } catch (e) {
      print('Error fetching Plumbing service data: $e');
    }
  }

  double get totalPrice => (basePrice ?? 0) * itemCount;

  int get estimatedTime => (itemCount * 1).clamp(1, 5); // 1 item = 1 hour, max 5 hours

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
                  builder: (_) => PlumbingWorkersPage(
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
          "Plumbing Service",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        ),
      ),
      body: basePrice == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight * 0.4,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/img/plumb.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "About the Plumbing Service",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          serviceDescription,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          '🔢 Number of Items:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (itemCount > 1) {
                                  setState(() {
                                    itemCount--;
                                  });
                                }
                              },
                              icon: const Icon(Icons.remove_circle),
                            ),
                            Text(
                              '$itemCount',
                              style: const TextStyle(fontSize: 18),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  itemCount++;
                                });
                              },
                              icon: const Icon(Icons.add_circle),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Text(
                          '💰 Price: ${totalPrice.toStringAsFixed(0)} LE',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          '🕒 Estimated Duration: $estimatedTime hour(s)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          '🔧 Select Specialization:',
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),

                        const SizedBox(height: 40.0),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              showMainDialog(
                                price: totalPrice,
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
    );
  }
}
