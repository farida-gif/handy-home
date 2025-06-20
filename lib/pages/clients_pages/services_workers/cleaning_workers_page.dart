import 'package:flutter/material.dart';
import 'package:handy_home2/common_widgets/worker_card.dart';
import 'package:handy_home2/models/workers.dart' as handy;
import 'package:handy_home2/pages/clients_pages/menu_pages/client_drawer_page.dart';
import 'package:handy_home2/repo/available_workers_repo.dart';

class CleaningWorkersPage extends StatefulWidget {
  final double totalPrice;
  final int EstimatedTime;
  final String selectedSpecialization;

  const CleaningWorkersPage({
    super.key,
    required this.totalPrice,
    required this.EstimatedTime,
    required this.selectedSpecialization,
  });

  @override
  State<CleaningWorkersPage> createState() => _CleaningWorkersPageState();
}

class _CleaningWorkersPageState extends State<CleaningWorkersPage> {
  final TextEditingController _searchController = TextEditingController();

  // ✅ Use WorkersRepo singleton directly
final AvailableWorkersRepo _repo = AvailableWorkersRepo.instance;
  List<handy.Worker> allWorkers = [];
  List<handy.Worker> filteredWorkers = [];

  String selectedRegion = 'All';
  bool isLoading = true;
  bool hasError = false;

  final List<String> regions = ['All', 'Zamalek', 'Zayed', 'New Cairo', 'Maadi'];

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  Future<void> _loadWorkers() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final List<Map<String, dynamic>> workerData =
    await _repo.fetchApprovedWorkersByService('Cleaning');

      final imagePaths = [
        'assets/img/f1.jpeg',
        'assets/img/f2.jpeg',
        'assets/img/hk3.png',
        'assets/img/hk4.png',
        'assets/img/hk5.png',
      ];

      allWorkers = workerData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;

        return handy.Worker(
          id: data['id'].toString(),
          name: data['name'] ?? '',
          serviceCategory: 'Cleaning',
          details: data['details'] ?? '',
          experienceYears: data['experience_years'] ?? 0,
          phoneNumber: data['phone_number'] ?? '',
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
          region: (data['region'] as List?)?.join(', ') ?? '',
          imagepath: imagePaths[index % imagePaths.length],
          description: data['details'] ?? 'No description',
          availableDays: List<String>.from(data['available_days'] ?? []),
          startTime: data['start_time'] ?? 'N/A',
          endTime: data['end_time'] ?? 'N/A',
        );
      }).toList();

      _filterWorkers(_searchController.text);
    } catch (e) {
      print('Error loading workers: $e');
      setState(() {
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterWorkers(String query) {
    final search = query.toLowerCase();

    setState(() {
      filteredWorkers = allWorkers.where((worker) {
        final matchesSearch = worker.name.toLowerCase().contains(search);
        final matchesRegion =
            selectedRegion == 'All' || worker.region.contains(selectedRegion);
        return matchesSearch && matchesRegion;
      }).toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));
    });
  }

  void _onRegionChanged(String? region) {
    setState(() {
      selectedRegion = region!;
    });
    _filterWorkers(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        title: const Text(
          "Cleaning Workers",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      drawer: const ClientDrawer(),
      body: Container(
        color: theme.colorScheme.surface,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? const Center(child: Text("Failed to load workers."))
                : Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterWorkers,
                          decoration: const InputDecoration(
                            hintText: 'Search by name...',
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: DropdownButtonFormField<String>(
                          value: selectedRegion,
                          onChanged: _onRegionChanged,
                          items: regions.map((region) {
                            return DropdownMenuItem(
                              value: region,
                              child: Text(region),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            labelText: 'Select Region',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filteredWorkers.isEmpty
                            ? const Center(
                                child: Text(
                                  "No workers found.",
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: filteredWorkers.length,
                                itemBuilder: (context, index) {
                                  final worker = filteredWorkers[index];
                                  return WorkerCard(
                                    worker: worker,
                                    totalPrice: widget.totalPrice,
                                    estimatedTime: widget.EstimatedTime,
                                    selectedSpecialization: widget.selectedSpecialization,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
