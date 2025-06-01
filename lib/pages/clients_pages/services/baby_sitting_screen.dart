import 'package:flutter/material.dart';
import 'package:handy_home2/pages/clients_pages/booking_pages/General_booking_calender.dart';
//import 'package:handy_home2/pages/clients_pages/booking_pages/worker_booking_calender.dart';
import 'package:handy_home2/pages/clients_pages/services_workers/babysitter_workers_page.dart';
import 'package:handy_home2/repo/service_repo.dart';

class BabySittingScreen extends StatefulWidget {
  const BabySittingScreen({super.key});

  @override
  State<BabySittingScreen> createState() => _BabySittingScreenState();
}

class _BabySittingScreenState extends State<BabySittingScreen> {
  List<String> specializations = [];
  String selectedSpecialization = '';
  String serviceDescription = '';
  double? price;
  int numberOfKids = 1;
  int numberOfHours = 1;
  String ageGroup = '0-2 years';
  List<String> kidAges = [];
  late final String serviceCategory = 'Babysitting';

  final List<String> ageGroups = ['0-2 years', '3-5 years', '6-12 years'];

  @override
  void initState() {
    super.initState();
    _fetchServiceData();
    _updateKidAges();
  }

void _fetchServiceData() async {
    try {
      List<String> fetchedSpecializations =
          await ServiceRepo().fetchServiceSpecializations('Babysitting');
      String description =
          await ServiceRepo().fetchServiceDescription('Babysitting');
      double fetchedPrice = 
          await ServiceRepo().fetchServicePrice('Babysitting');

      setState(() {
        specializations = fetchedSpecializations;
        selectedSpecialization =
            specializations.isNotEmpty ? specializations[0] : 'Other';
        serviceDescription = description;
        price = fetchedPrice;
      });
    } catch (e) {
      print('Error fetching Babysitting service data: $e');
    }
  }
  
  void _updateKidAges() {
    setState(() {
      if (kidAges.length < numberOfKids) {
        kidAges.addAll(List.generate(numberOfKids - kidAges.length, (_) => '0-2 years'));
      } else if (kidAges.length > numberOfKids) {
        kidAges = kidAges.sublist(0, numberOfKids);
      }
    });
  }

  double getPrice() {
  double totalPrice = 0.0;

  for (String age in kidAges) {
    double ratePerHour;

    switch (age) {
      case '0-2 years':
        ratePerHour = 200;
        break;
      case '3-5 years':
        ratePerHour = 180;
        break;
      case '6-12 years':
        ratePerHour = 150;
        break;
      default:
        ratePerHour = 100;
    }

    totalPrice += ratePerHour * numberOfHours;
  }

  return totalPrice;
}
 

  void showMainDialog({
    required String title,
    required double price,
    required int EstimatedTime,
    required String selectedSpecialization,
    required String service_category,
  }) {
    showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Choose Worker"),
      content: const Text(
        "Do you want to choose the babysitter yourself?",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BabysitterWorkersPage(
                  totalPrice: price,
                  EstimatedTime: numberOfHours,
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
                  serviceCategory: service_category,
                  totalPrice: price,
                  estimatedTime: numberOfHours, 
                  selectedSpecialization:selectedSpecialization,
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Baby Sitter Page"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight * 0.35,
                width: double.infinity,
                child: Image.asset(
                  'assets/img/b1.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "About the Service",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                            serviceDescription,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),

              // Age Group Dropdown
              const Text(
                "Select Age Group:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              DropdownButton<String>(
                value: ageGroup,
                onChanged: (value) {
                  setState(() {
                    ageGroup = value!;
                  });
                },
                items: ageGroups.map((group) {
                  return DropdownMenuItem(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Number of Kids
              const Text(
                "Number of Kids:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (numberOfKids > 1) {
                        setState(() {
                          numberOfKids--;
                          _updateKidAges();
                        });
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    numberOfKids.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () {
                      if (numberOfKids < 10) {
                        setState(() {
                          numberOfKids++;
                          _updateKidAges();
                        });
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kid-specific Age Selection
              if (numberOfKids > 1)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(numberOfKids, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Select age for Kid ${index + 1}:"),
                          DropdownButton<String>(
                            value: kidAges[index],
                            onChanged: (value) {
                              setState(() {
                                kidAges[index] = value!;
                              });
                            },
                            items: ageGroups.map((group) {
                              return DropdownMenuItem(
                                value: group,
                                child: Text(group),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              const SizedBox(height: 16),

              // Number of Hours
              const Text(
                "Number of Hours:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (numberOfHours > 1) {
                        setState(() {
                          numberOfHours--;
                        });
                      }
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    numberOfHours.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () {
                      if (numberOfHours < 12) {
                        setState(() {
                          numberOfHours++;
                        });
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Price Display
              Text(
                "💰 Estimated Total: ${getPrice().toStringAsFixed(0)} EGP",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

  // Book Now Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showMainDialog(
                      title: "Babysitting Booking",
                      price: getPrice(),
                      EstimatedTime: numberOfHours,
                      selectedSpecialization: selectedSpecialization,
                      service_category: serviceCategory
                    );
                  },
                  child: const Text("Proceed to Booking"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
