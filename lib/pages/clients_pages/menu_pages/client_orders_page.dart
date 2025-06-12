import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientOrdersPage extends StatefulWidget {
  const ClientOrdersPage({super.key});

  @override
  State<ClientOrdersPage> createState() => _ClientOrdersPageState();
}

class _ClientOrdersPageState extends State<ClientOrdersPage> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;

  List<dynamic> upcomingBookings = [];
  List<dynamic> pastBookings = [];
  List<dynamic> upcomingGeneral = [];
  List<dynamic> pastGeneral = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final clientId = supabase.auth.currentUser?.id;
    if (clientId == null) return;

    final now = DateTime.now();

    final bookingsResponse = await supabase
        .from('bookings')
        .select()
        .eq('client_id', clientId)
        .order('date', ascending: false)
        .order('time', ascending: false);

    final generalResponse = await supabase
        .from('general_booking')
        .select()
        .eq('client_id', clientId)
        .order('date', ascending: false)
        .order('time', ascending: false);

    // Normalize
    final bookings = bookingsResponse.map((order) => {
          ...order,
          'source': 'bookings',
          'worker_name': order['worker_name'] ?? 'Unknown Worker',
        });

    final general = generalResponse.map((order) => {
          ...order,
          'source': 'general_booking',
          'worker_name': order['assigned_worker_name'] ?? 'Assigned Later',
        });

    setState(() {
  // Time boundaries
  final today = DateTime(now.year, now.month, now.day);

  // Bookings (direct)
  upcomingBookings = bookings.where((order) {
    final d = DateTime.parse(order['date']);
    return !d.isBefore(today); // today or future
  }).toList();

  pastBookings = bookings.where((order) {
    final d = DateTime.parse(order['date']);
    return d.isBefore(today); // strictly before today
  }).toList();

  // General bookings
  upcomingGeneral = general.where((order) {
    final d = DateTime.parse(order['date']);
    return !d.isBefore(today); // today or future
  }).toList();

      pastGeneral = general.where((order) {
        final d = DateTime.parse(order['date']);
        return d.isBefore(DateTime(now.year, now.month, now.day));
      }).toList();

      isLoading = false;
    });
  }

  String formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return DateFormat.yMMMEd().format(d);
    } catch (_) {
      return date;
    }
  }

  Widget buildStatusBadge(String source, dynamic order, bool isUpcoming) {
    String label;
    Color color;

    if (source == 'bookings') {
      label = isUpcoming ? 'Upcoming' : 'Completed';
      color = isUpcoming ? Colors.green : Colors.grey;
    } else {
      final status = order['status'] ?? 'pending';
      label = status[0].toUpperCase() + status.substring(1);
      color = status == 'assigned' ? Colors.green : Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget buildOrderCard(Map<String, dynamic> order, bool isUpcoming) {
    final source = order['source'];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['service_category'] ?? 'Service',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                buildStatusBadge(source, order, isUpcoming),
              ],
            ),
            const SizedBox(height: 8),

            // Worker
            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text(order['worker_name'] ?? 'Unknown')),
              ],
            ),
            const SizedBox(height: 6),

            // Date & Time
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text('${formatDate(order['date'])} at ${order['time']}'),
              ],
            ),
            const SizedBox(height: 6),

            // Price
            Row(
              children: [
                const Icon(Icons.attach_money, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text('Price: ${order['price'] ?? '0'}'),
              ],
            ),
            const SizedBox(height: 6),

            // Address
            Row(
              children: [
                const Icon(Icons.place, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text(order['client_address'] ?? 'Address not provided')),
              ],
            ),

            if (source == 'general_booking') ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('Status: ${order['status'] ?? 'Pending'}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title, IconData icon, List<dynamic> orders, bool isUpcoming) {
    if (orders.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...orders.map((order) => buildOrderCard(order, isUpcoming)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          "My Bookings",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchOrders,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (upcomingBookings.isEmpty &&
                      upcomingGeneral.isEmpty &&
                      pastBookings.isEmpty &&
                      pastGeneral.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(
                        child: Text('You have no bookings yet.',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                    ),

                  buildSection('Upcoming Bookings', Icons.schedule, upcomingBookings, true),
                  buildSection('Upcoming General Orders', Icons.assignment, upcomingGeneral, true),
                  buildSection('Past Bookings', Icons.history, pastBookings, false),
                  buildSection('Past General Orders', Icons.archive, pastGeneral, false),
                ],
              ),
            ),
    );
  }
}
