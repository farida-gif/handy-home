import 'package:flutter/material.dart';
import 'package:handy_home2/pages/clients_pages/services_page.dart';
import 'package:intl/intl.dart';

class WorkerCalenderInvoice extends StatelessWidget {
  final String workerName;
  final String serviceCategory;
  final String clientName;
  final String clientPhone;
  final String clientEmail;
  final String clientAddress;
  final DateTime date;
  final TimeOfDay time;
  final Duration estimatedTime;
  final double totalPrice;
  final double deposit;

  const WorkerCalenderInvoice({
    super.key,
    required this.workerName,
    required this.serviceCategory,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.clientAddress,
    required this.date,
    required this.time,
    required this.estimatedTime,
    required this.totalPrice,
    required this.deposit,
  });

  @override
  Widget build(BuildContext context) {
    final endTime = DateTime(date.year, date.month, date.day, time.hour, time.minute).add(estimatedTime);

    final remaining = totalPrice - deposit;

    return Scaffold(
      appBar: AppBar(title: const Text('📋 Invoice')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [

  //service summary
                Text("Service Summary", 
                style: Theme.of(context).textTheme.titleLarge ?.copyWith(fontWeight: FontWeight.bold)),
                const Divider(),
                _infoRow("Worker", workerName),
                _infoRow("Category", serviceCategory),
                const SizedBox(height: 20),

  //client info
                 Text(
                  "Client Info",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),                
                const Divider(),
                _infoRow("Name", clientName),
                _infoRow("Phone", clientPhone),
                _infoRow("Email", clientEmail),
                _infoRow("Address", clientAddress),
                const SizedBox(height: 20),

  //booking details
                Text(
                  "Booking Details",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _infoRow("Date", DateFormat.yMMMMEEEEd().format(date)),
                _infoRow("Time", time.format(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  const Text("Ends By"),
                  Text(DateFormat.jm().format(endTime)),
                 ],
                 ),
                const SizedBox(height: 20),

  //payment details
                Text(
                  "Payment",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _infoRow("Total Price", "\$${totalPrice.toStringAsFixed(2)}"),
                _infoRow("Deposit Paid", "\$${deposit.toStringAsFixed(2)}"),
                _infoRow("Remaining (on cash)", "\$${remaining.toStringAsFixed(2)}"),
               const SizedBox(height: 45),

  // Done button
                Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Done"),
                  onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ServicesPage()), // replace with your page
  );
},
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value)],
      ),
    );
  }
}
