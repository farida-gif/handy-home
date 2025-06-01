import 'package:flutter/material.dart';
import 'package:handy_home2/models/workers.dart';
import 'package:handy_home2/models/client_model.dart';
import 'package:handy_home2/pages/clients_pages/booking_pages/worker_booking_calender.dart';
import 'package:handy_home2/repo/client_repo.dart';

class WorkerDetailPage extends StatefulWidget {
  final Worker worker;
  final double totalPrice;
  final int EstimatedTime;
  final String selectedSpecialization;

  const WorkerDetailPage({
    super.key,
    required this.worker,
    required this.totalPrice,
    required this.EstimatedTime,
    required this.selectedSpecialization,
  });

  @override
  State<WorkerDetailPage> createState() => _WorkerDetailPageState();
}

class _WorkerDetailPageState extends State<WorkerDetailPage> {
  ClientProfile? clientProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClientInfo();
  }

  Future<void> _loadClientInfo() async {
    final profile = await ClientsRepo.instance.getClientProfile();
    setState(() {
      clientProfile = profile;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.worker.name),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 90,
                backgroundImage: AssetImage(widget.worker.imagepath),
                backgroundColor: theme.colorScheme.surface,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.worker.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.worker.serviceCategory,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text('${widget.worker.rating} rating'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
                        const SizedBox(width: 6),
                        Text(widget.worker.region,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Experience: ${widget.worker.experienceYears} years'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 18, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(widget.worker.phoneNumber),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (widget.worker.description.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Description:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(widget.worker.description),
                          const SizedBox(height: 10),
                        ],
                      ),

                    if (widget.worker.availableDays.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Available Days:",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(widget.worker.availableDays.join(', ')),
                          const SizedBox(height: 10),
                        ],
                      ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Available Hours:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${widget.worker.startTime} - ${widget.worker.endTime}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkerBookingCalender(
                        workerId: widget.worker.id,
                        workerName: widget.worker.name,
                        serviceCategory: widget.worker.serviceCategory,
                        totalPrice: widget.totalPrice,
                        EstimatedTime: widget.EstimatedTime,
                        specialization: widget.selectedSpecialization,
                        //availableDays: widget.worker.availableDays,
                        //startTime: widget.worker.startTime,
                        //endTime: widget.worker.endTime,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text("Book This Worker"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
