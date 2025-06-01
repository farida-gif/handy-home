import 'package:flutter/material.dart';
import 'package:handy_home2/pages/clients_pages/payments/cr.card_worker_calender_page.dart';
//import 'package:handy_home2/pages/clients_pages/payments/worker_calender_invoice.dart';
import 'package:handy_home2/repo/client_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:handy_home2/models/client_model.dart';
import 'package:intl/intl.dart';

class WorkerBookingCalender extends StatefulWidget {
  final String workerId;
  final String workerName;
  final String serviceCategory;
  final String specialization;
  final double? totalPrice;
  final int EstimatedTime;

  const WorkerBookingCalender({
    super.key,
    required this.workerId,
    required this.workerName,
    required this.serviceCategory,
    required this.specialization,
    required this.totalPrice,
    required this.EstimatedTime,
  });

  @override
  State<WorkerBookingCalender> createState() => _WorkerBookingCalenderState();
}

class _WorkerBookingCalenderState extends State<WorkerBookingCalender> {
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

  List<String> availableDays = [];
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  void initState() {
    super.initState();
    adjustedPrice = widget.totalPrice ?? 0;
    _loadClientData();
    fetchWorkerAvailability();
  }

  Future<void> fetchWorkerAvailability() async {
  final response = await _client
      .from('workers')
      .select('available_days, start_time, end_time')
      .eq('id', widget.workerId)
      .single();

  if (mounted) {
    setState(() {
      availableDays = List<String>.from(response['available_days'] ?? []);

      final startParts = response['start_time'].split(":");
      final endParts = response['end_time'].split(":");

      startTime = TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      );

      endTime = TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      );
    });
  }
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
      adjustedPrice = (widget.totalPrice ?? 0) + (weekend ? 100 : 0);
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


  bool _isTimeWithinWorkingHours(TimeOfDay time) {
    if (startTime == null || endTime == null) return true;
    final selected = Duration(hours: time.hour, minutes: time.minute);
    final start = Duration(hours: startTime!.hour, minutes: startTime!.minute);
    final end = Duration(hours: endTime!.hour, minutes: endTime!.minute);
    return selected >= start && selected <= end;
  }

  Future<void> _submitBooking() async {
    if (selectedDate == null || selectedTime == null || clientProfile == null) {
      _showDialog("Incomplete", "Please select date, time, and ensure profile is loaded.");
      return;
    }

    // Check day availability
    final selectedWeekday = DateFormat('EEEE').format(selectedDate!); // e.g., "Monday"
if (!availableDays.map((d) => d.toLowerCase()).contains(selectedWeekday.toLowerCase())) {
  _showDialog("Unavailable Day", "This worker is not available on $selectedWeekday.");
  return;
}

    // Check time availability
    if (!_isTimeWithinWorkingHours(selectedTime!)) {
      _showDialog("Unavailable Time", "The selected time is outside the worker's available hours.");
      return;
    }

    final startDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final endDateTime = startDateTime.add(Duration(hours: widget.EstimatedTime));
    final deposit = (adjustedPrice * 0.2).toStringAsFixed(2);
    final remaining = adjustedPrice - double.parse(deposit);

    try {
      setState(() => isLoading = true);

      final bookings = await _client
          .from('bookings')
          .select()
          .eq('worker_id', widget.workerId);

      final conflicts = bookings.where((booking) {
        final existingStart = DateTime.parse(booking['start_time']);
        final existingEndWithBuffer =
            DateTime.parse(booking['end_time']).add(const Duration(hours: 1));
        return startDateTime.isBefore(existingEndWithBuffer) &&
            endDateTime.isAfter(existingStart);
      }).toList();

      if (conflicts.isNotEmpty) {
        await _showDialog("Time Slot Unavailable",
            "This worker has a booking during that time, please select another time or another worker.");
        return;
      }

      final deposit = (adjustedPrice * 0.2).toStringAsFixed(2);

      await _client.from('bookings').insert({
        'worker_id': widget.workerId,
        'worker_name': widget.workerName,
        'client_id': _client.auth.currentUser!.id,
        'client_name': clientProfile!.name,
        'client_email': emailController.text.trim(),
        'client_address': addressController.text.trim(),
        'client_region': regionController.text.trim(),
        'client_phone': phoneController.text.trim(),
        'service_category': widget.serviceCategory,
        'date': selectedDate!.toIso8601String().substring(0, 10),
        'time': selectedTime!.format(context),
        'start_time': startDateTime.toIso8601String(),
        'end_time': endDateTime.toIso8601String(),
        'price': adjustedPrice,
        'deposit': double.parse(deposit),
        'created_at': DateTime.now().toIso8601String(),
      });

       _showPaymentPrompt(
        depositAmount: double.parse(deposit),
        remainingAmount: remaining,
        startDateTime: startDateTime,
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
                builder: (_) => WorkerCalenderCreditCardPage(
                   depositAmount: depositAmount,
                   serviceCategory: widget.serviceCategory,
                   clientName: clientProfile!.name,
                   workerName: widget.workerName, // ✅ pass worker name
                   date: selectedDate!,
                   time: selectedTime!,
                   estimatedTime: widget.EstimatedTime, // ✅ pass estimated time
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
                    Text("Worker Info", style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(widget.workerName),
                        subtitle: Text('${widget.serviceCategory} • ${widget.specialization}'),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text("Pick Date & Time", style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
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
                    Text("Booking Summary", style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Card(
                      color: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_month, color: Colors.blue),
                                const SizedBox(width: 10),
                                Text(selectedDate == null
                                    ? "No date selected"
                                    : DateFormat.yMMMMEEEEd().format(selectedDate!)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.blue),
                                const SizedBox(width: 10),
                                Text(selectedTime == null
                                    ? "No time selected"
                                    : selectedTime!.format(context)),
                              ],
                            ),
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
                ).add(Duration(hours: widget.EstimatedTime)),
              )}",
            ),
          ]),
                                      const SizedBox(height: 10),

                            Row(
                              children: [
                                const Icon(Icons.attach_money, color: Colors.green),
                                const SizedBox(width: 10),
                                Text("Total Price: \$${adjustedPrice.toStringAsFixed(2)}"),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.payment, color: Colors.orange),
                                const SizedBox(width: 10),
                                Text("Deposit: \$${deposit.toStringAsFixed(2)}"),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.money, color: Colors.redAccent),
                                const SizedBox(width: 10),
                                Text("Remaining: \$${remaining.toStringAsFixed(2)}"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text("Your Contact Info", style: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)),
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
                          label: const Text("Confirm Booking"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: theme.colorScheme.surface,
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