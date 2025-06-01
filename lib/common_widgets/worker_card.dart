import 'package:flutter/material.dart';
import 'package:handy_home2/models/workers.dart';
import 'package:handy_home2/pages/clients_pages/services_workers/worker_details_page.dart';

class WorkerCard extends StatelessWidget {
  final Worker worker;
  final double totalPrice;
  final int estimatedTime;
  final String selectedSpecialization;

  const WorkerCard({
    super.key,
    required this.worker,
    required this.totalPrice,
    required this.estimatedTime,
    required this.selectedSpecialization,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkerDetailPage(
        worker: worker,
        totalPrice: totalPrice,
        EstimatedTime: estimatedTime,
        selectedSpecialization: selectedSpecialization,
      ),
    ),
  );
},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(worker.imagepath),
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(worker.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(worker.serviceCategory,
                          style: TextStyle(
                              color: theme.colorScheme.primary, fontSize: 14)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 16),
                          Text('${worker.rating}',
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 10),
                          Text('${worker.experienceYears} yrs experience',
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
