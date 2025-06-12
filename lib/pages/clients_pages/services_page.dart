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

  final List<Map<String, dynamic>> topPicksArr = [
    {
      "name": "Cleaning",
      "img": "assets/img/c2.png",
      "page": const CleaningScreen(),
    },
    {
      "name": "Baby Sitting",
      "img": "assets/img/baby2.jpeg",
      "page": const BabySittingScreen(),
    },
    {
      "name": "Apartment Finishing",
      "img": "assets/img/recommend.jpeg",
      "page": const HomeFinishing(),
    },
  ];

  final List<Map<String, dynamic>> services = [
    {'name': 'Plumbing', 'icon': Icons.plumbing, 'page': const PlumbingScreen()},
    {'name': 'Electrical', 'icon': Icons.electrical_services, 'page': const ElectricalScreen()},
    {'name': 'Cleaning', 'icon': Icons.cleaning_services, 'page': const CleaningScreen()},
    {'name': 'Carpentry', 'icon': Icons.construction, 'page': const CarpentryScreen()},
    {'name': 'Painting', 'icon': Icons.brush, 'page': const PaintingScreen()},
    {'name': 'Babysitting', 'icon': Icons.baby_changing_station, 'page': const BabySittingScreen()},
   // {'name': 'Home Finishing', 'icon': Icons.home, 'page': const HomeFinishing()},
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
                          Expanded(
                            child: Text(
                              "Recommended Services",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
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
                    // "Book a Service" Header
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 18, bottom: 10),
                      child: Text(
                        "Book a Service",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    // Updated Book Service Section as Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: services.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 3 / 2,
                        ),
                        itemBuilder: (context, index) {
                          final service = services[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => service['page']),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      service['icon'],
                                      size: 35,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      service['name'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                   const SizedBox(height: 10)

                                  ],
                                ),
                              ),
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
