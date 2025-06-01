import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkerOrdersPage extends StatefulWidget {
  const WorkerOrdersPage({super.key});

  @override
  State<WorkerOrdersPage> createState() => _WorkerOrdersPageState();
}

class _WorkerOrdersPageState extends State<WorkerOrdersPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> upcomingOrders = [];
  List<dynamic> pastOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final workerId = supabase.auth.currentUser?.id;
    if (workerId == null) return;

    final now = DateTime.now();

    try {
      final bookingsResponse = await supabase
          .from('bookings')
          .select()
          .eq('worker_id', workerId)
          .order('date', ascending: false)
          .order('time', ascending: false);

      final generalResponse = await supabase
          .from('general_booking')
          .select()
          .eq('assigned_worker_id', workerId)
          .eq('is_assigned', true)
          .order('date', ascending: false)
          .order('time', ascending: false);

      final allOrders = [
        ...bookingsResponse.map((e) => {...e, 'source': 'bookings'}),
        ...generalResponse.map((e) => {...e, 'source': 'general'}),
      ];

      setState(() {
        upcomingOrders = allOrders.where((order) {
          final orderDate = DateTime.parse(order['date']);
          return orderDate.isAfter(now) || orderDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
        }).toList();

        pastOrders = allOrders.where((order) {
          final orderDate = DateTime.parse(order['date']);
          return orderDate.isBefore(DateTime(now.year, now.month, now.day));
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() => isLoading = false);
    }
  }

  String formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return DateFormat.yMMMEd().format(d);
    } catch (_) {
      return date;
    }
  }

  String formatTime(String? time) {
    if (time == null) return '';
    try {
      final dt = DateFormat.Hm().parse(time);
      return DateFormat.jm().format(dt);
    } catch (_) {
      return time;
    }
  }

  String formatDateTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp);
      return DateFormat.jm().format(dt);
    } catch (_) {
      return timestamp;
    }
  }

  Widget buildStatusBadge(bool isUpcoming) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isUpcoming ? Colors.green[100] : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isUpcoming ? 'upcoming'.tr : 'completed'.tr,
        style: TextStyle(
          color: isUpcoming ? Colors.green[800] : Colors.grey[700],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget buildOrderCard(Map<String, dynamic> order, bool isUpcoming) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Service & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['service_category'] ?? 'service'.tr,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                buildStatusBadge(isUpcoming),
              ],
            ),
            const SizedBox(height: 8),

            buildInfoRow(Icons.person, order['client_name'] ?? 'Unknown Client'),
            buildInfoRow(Icons.calendar_today, '${formatDate(order['date'])} at ${order['time'] ?? 'Unknown'}'),
            if (order['end_time'] != null) buildInfoRow(Icons.access_time_filled_rounded, 'Ends at: ${formatDateTime(order['end_time'])}'),
            if (order['price'] != null) buildInfoRow(Icons.attach_money, 'price: ${order['price']}'.tr),
            if (order['client_phone'] != null) buildInfoRow(Icons.phone, order['client_phone']),
            if (order['client_address'] != null) buildInfoRow(Icons.place, order['client_address']),
            if (order['client_region'] != null) buildInfoRow(Icons.location_city, order['client_region']),

            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                order['source'] == 'general' ? 'General Booking' : 'Direct Booking',
                style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget buildSection(String title, IconData icon, List<dynamic> orders, bool isUpcoming) {
    if (orders.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
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
    iconTheme: const IconThemeData(color: Colors.white),
    title: Text(
      'orders'.tr,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    backgroundColor: Theme.of(context).colorScheme.primary,
  ),     
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchOrders,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (upcomingOrders.isEmpty && pastOrders.isEmpty)
                     Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Center(
                        child: Text(
                          'no_bookings'.tr,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                  buildSection('upcoming_bookings'.tr, Icons.schedule, upcomingOrders, true),
                  buildSection('past_bookings'.tr, Icons.done_all, pastOrders, false),
                ],
              ),
            ),
    );
  }
}
