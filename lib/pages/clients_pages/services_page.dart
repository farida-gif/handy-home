import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:handy_home2/common_widgets/recommended_services.dart';
import 'package:handy_home2/pages/clients_pages/menu_pages/client_drawer_page.dart';
import 'package:handy_home2/pages/clients_pages/services/baby_sitting_screen.dart';
import 'package:handy_home2/pages/clients_pages/services/electrical_screen.dart';
import 'package:handy_home2/pages/clients_pages/services/home_finishing.dart';
import 'package:handy_home2/pages/clients_pages/services/painting_screen.dart';
import 'package:handy_home2/pages/clients_pages/services/plumbing_screen.dart';
import 'package:handy_home2/pages/clients_pages/services/carpentry_screen.dart';
import 'package:handy_home2/pages/clients_pages/services/cleaning_screen.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredServices = [];

  // Dummy data for top picks
  final List<Map<String, dynamic>> topPicksArr = [
    {
      "name": "Cleaning",
      "img": "assets/img/c2.png",
      "page": const CleaningScreen(),
    },
    {
      "name": "Baby Sitting",
      "img": "assets/img/baby.jpg",
      "page": const BabySittingScreen(),
    },
    {
      "name": "Apartment Finishing",
      "img": "assets/img/s3.jpg",
      "page": const HomeFinishing(),
    },
  ];

  // Dummy data for all services
  final List<Map<String, dynamic>> services = [
    {'name': 'Plumbing', 'icon': Icons.plumbing, 'page': const PlumbingScreen()},
    {'name': 'Electrical', 'icon': Icons.electrical_services, 'page': const ElectricalScreen()},
    {'name': 'Cleaning', 'icon': Icons.cleaning_services, 'page': const CleaningScreen()},
    {'name': 'Carpentry', 'icon': Icons.construction, 'page': const CarpentryScreen()},
    {'name': 'Painting', 'icon': Icons.brush, 'page': const PaintingScreen()},
    {'name': 'Babysitting', 'icon': Icons.baby_changing_station, 'page': const BabySittingScreen()},
    {'name': 'Apartment Finishing', 'icon': Icons.home, 'page': const HomeFinishing()},
  ];

  @override
  void initState() {
    super.initState();
    filteredServices = [];
  }

  void _filterServices(String query) {
    setState(() {
      filteredServices = query.isEmpty
          ? []
          : services.where((service) => service['name'].toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: const ClientDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Align(
                  child: Transform.scale(
                    scale: 1.5,
                    origin: Offset(0, media.width * 0.8),
                    child: Container(
                      width: media.width,
                      height: media.width,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(media.width * 0.5),
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    SizedBox(height: media.width * 0.1),

                    // Top bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          Builder(
                            builder: (context) => IconButton(
                              icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.surface, size: 30),
                              onPressed: () => Scaffold.of(context).openDrawer(),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Center(
                              child: Text(
                                "Recommended Services",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.surface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for a service...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        ),
                        onChanged: _filterServices,
                      ),
                    ),

                    // Search Results
                    if (filteredServices.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredServices.length,
                          itemBuilder: (context, index) {
                            final service = filteredServices[index];
                            return Card(
                              child: ListTile(
                                title: Text(service['name']),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => service['page']),
                                  );
                                  _searchController.clear();
                                  _filterServices('');
                                },
                              ),
                            );
                          },
                        ),
                      ),

                    // Carousel
                    SizedBox(
                      width: media.width,
                      height: media.width * 0.8,
                      child: CarouselSlider.builder(
                        itemCount: topPicksArr.length,
                        itemBuilder: (context, index, _) {
                          final iObj = topPicksArr[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => iObj['page']),
                              );
                            },
                            child: RecommendedServices(iObj: iObj),
                          );
                        },
                        options: CarouselOptions(
                          autoPlay: true,
                          aspectRatio: 1,
                          enlargeCenterPage: true,
                          viewportFraction: 0.55,
                          enlargeFactor: 0.5,
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.only(left: 16.0, top: 8),
                      child: Text(
                        "Book a Service",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: Icon(
                                service['icon'],
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(
                                service['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => service['page']),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
