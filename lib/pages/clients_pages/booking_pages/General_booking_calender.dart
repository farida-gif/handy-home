 import 'package:flutter/material.dart';
import 'package:handy_home2/pages/clients_pages/payments/cr.card_general_calender.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:handy_home2/repo/client_repo.dart';
import 'package:handy_home2/models/client_model.dart';

class GeneralBookingCalendarPage extends StatefulWidget {
  final String serviceCategory;
  final double totalPrice;
  final int estimatedTime;
  final String selectedSpecialization;

  const GeneralBookingCalendarPage({
    super.key,
    required this.serviceCategory,
    required this.totalPrice,
    required this.estimatedTime,
    required this.selectedSpecialization,
  });

  @override
  State<GeneralBookingCalendarPage> createState() =>
      _GeneralBookingCalendarPageState();
}

class _GeneralBookingCalendarPageState extends State<GeneralBookingCalendarPage> {
  final SupabaseClient _client = Supabase.instance.client;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isLoading = false;
  ClientProfile? clientProfile;

  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final regionController = TextEditingController();

  double adjustedPrice = 0;
  bool isWeekend = false;

  @override
  void initState() {
    super.initState();
    adjustedPrice = widget.totalPrice;
    _loadClientData();
  }

  Future<void> _loadClientData() async {
    final profile = await ClientsRepo.instance.getClientProfile();
    if (mounted) {
      setState(() {
        clientProfile = profile;
        addressController.text = profile?.address ?? '';
        phoneController.text = profile?.phone ?? '';
        emailController.text = profile?.email ?? '';
        regionController.text = profile?.region ?? '';
      });
    }
  }

  void _updatePriceBasedOnDate(DateTime pickedDate) {
    final weekday = pickedDate.weekday;
    final weekend = weekday == DateTime.friday || weekday == DateTime.saturday;

    setState(() {
      selectedDate = pickedDate;
      isWeekend = weekend;
      adjustedPrice = widget.totalPrice + (weekend ? 100 : 0);
    });
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) _updatePriceBasedOnDate(picked);
  }


  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }



 Future<void> _submitBooking() async {
  if (selectedDate == null || selectedTime == null || clientProfile == null) {
    _showDialog("Incomplete", "Please select date, time, and complete your profile.");
    return;
  }

  //final now = DateTime.now();

  // Combine selected date and time into one DateTime
  final selectedDateTime = DateTime(
    selectedDate!.year,
    selectedDate!.month,
    selectedDate!.day,
    selectedTime!.hour,
    selectedTime!.minute,
  );

  // ✅ Validate time between 6 AM and 11 PM
  if (selectedTime!.hour < 6 || selectedTime!.hour >= 23) {
    _showDialog("Invalid Time", "Please select a time between 6:00 AM and 11:00 PM.");
    return;
  }

  

  final endDateTime = selectedDateTime.add(Duration(hours: widget.estimatedTime));
  final deposit = (adjustedPrice * 0.2).toStringAsFixed(2);
  final remaining = adjustedPrice - double.parse(deposit);

  try {
    setState(() => isLoading = true);

    await _client.from('general_booking').insert({
      'client_id': _client.auth.currentUser!.id,
      'client_name': clientProfile!.name,
      'client_email': emailController.text.trim(),
      'client_address': addressController.text.trim(),
      'client_region': regionController.text.trim(),
      'client_phone': phoneController.text.trim(),
      'service_category': widget.serviceCategory,
      'specialization': widget.selectedSpecialization,
      'date': selectedDate!.toIso8601String().substring(0, 10),
      'time': selectedTime!.format(context),
      'start_time': selectedDateTime.toIso8601String(),
      'end_time': endDateTime.toIso8601String(),
      'price': adjustedPrice,
      'deposit': double.parse(deposit),
      'created_at': DateTime.now().toIso8601String(),
      'status': 'pending',
    });

_showPaymentPrompt(
        depositAmount: double.parse(deposit),
        remainingAmount: remaining,
        startDateTime: selectedDateTime,
        endDateTime: endDateTime,
      );
    } catch (e) {
      _showDialog("Error", "Something went wrong. Please try again.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showPaymentPrompt({
  required double depositAmount,
  required double remainingAmount,
  required DateTime startDateTime,
  required DateTime endDateTime,
}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
          SizedBox(width: 8),
          Text("Booking Confirmed"),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Text("Your booking has been placed successfully."),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.attach_money, color: Colors.orange),
              const SizedBox(width: 8),
              Text("Deposit: \$${depositAmount.toStringAsFixed(2)}"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.money_off, color: Colors.red),
              const SizedBox(width: 8),
              Text("Remaining (Cash): \$${remainingAmount.toStringAsFixed(2)}"),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Do you want to proceed with the deposit payment now?"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Later"),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.payment),
          label: const Text("Pay Now"),
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GeneralCalenderCreditCardPage(
                  depositAmount: depositAmount,
                  serviceCategory: widget.serviceCategory,
                  clientName: clientProfile!.name,
                  date: selectedDate!,
                  time: selectedTime!,
                  estimatedTime: widget.estimatedTime,
                  endDateTime: endDateTime,
                  clientPhone: phoneController.text.trim(),
                  clientEmail: emailController.text.trim(),
                  clientAddress: addressController.text.trim(),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
  Future<void> _showDialog(String title, String message) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(child: const Text("OK"), onPressed: () => Navigator.pop(context))],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deposit = (adjustedPrice * 0.2);
    final remaining = adjustedPrice - deposit;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Book a Service"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: clientProfile == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Service Category",
                        style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.category, color: Colors.blue),
                        title: Text(widget.serviceCategory),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Text("Pick Date & Time",
                        style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(selectedDate == null
                                ? "Select Date"
                                : DateFormat.yMMMMd().format(selectedDate!)),
                            onPressed: _selectDate,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time),
                            label: Text(selectedTime == null
                                ? "Select Time"
                                : selectedTime!.format(context)),
                            onPressed: _selectTime,
                          ),
                        ),
                      ],
                    ),
                    if (isWeekend)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          "Note: A weekend surcharge of \$100 has been added.",
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),

                    const SizedBox(height: 30),

                    Text("Booking Summary",
                        style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Card(
                      color: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.calendar_month, color: Colors.blue),
                              const SizedBox(width: 10),
                              Text(selectedDate == null
                                  ? "No date selected"
                                  : DateFormat.yMMMMEEEEd().format(selectedDate!)),
                            ]),
                            const SizedBox(height: 10),
                            Row(children: [
                              const Icon(Icons.access_time, color: Colors.blue),
                              const SizedBox(width: 10),
                              Text(selectedTime == null
                                  ? "No time selected"
                                  : selectedTime!.format(context)),
                            ]),
                            const SizedBox(height: 10),
        if (selectedDate != null && selectedTime != null)
          Row(children: [
            const Icon(Icons.timelapse, color: Colors.purple),
            const SizedBox(width: 10),
            Text(
              "Ends by: ${DateFormat.jm().format(
                DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                ).add(Duration(hours: widget.estimatedTime)),
              )}",
            ),
          ]),
                                      const SizedBox(height: 10),

                            Row(children: [
                              const Icon(Icons.attach_money, color: Colors.green),
                              const SizedBox(width: 10),
                              Text("Total Price: \$${adjustedPrice.toStringAsFixed(2)}"),
                            ]),
                            const SizedBox(height: 10),
                            Row(children: [
                              const Icon(Icons.payment, color: Colors.orange),
                              const SizedBox(width: 10),
                              Text("Deposit: \$${deposit.toStringAsFixed(2)}"),
                            ]),
                            const SizedBox(height: 10),
                            Row(children: [
                              const Icon(Icons.money, color: Colors.redAccent),
                              const SizedBox(width: 10),
                              Text("Remaining: \$${remaining.toStringAsFixed(2)}"),
                            ]),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text("Your Contact Info",
                        style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
                    const SizedBox(height: 10),
                    TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
                    const SizedBox(height: 10),
                    TextField(controller: addressController, decoration: const InputDecoration(labelText: "Address")),
                    const SizedBox(height: 10),
                    TextField(controller: regionController, decoration: const InputDecoration(labelText: "Region")),

                    const SizedBox(height: 30),

                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _submitBooking,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text("Confirm Booking",
                          style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}