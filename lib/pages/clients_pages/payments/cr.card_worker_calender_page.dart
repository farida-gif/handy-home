import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:handy_home2/pages/clients_pages/payments/worker_calender_invoice.dart';

class WorkerCalenderCreditCardPage extends StatefulWidget {
  final double depositAmount;
  final String serviceCategory;
  final String clientName;
  final DateTime date;
  final TimeOfDay time;
  final DateTime endDateTime;
  final int estimatedTime;
  final String clientPhone;
  final String clientEmail;
  final String clientAddress;
  final String workerName;

  const WorkerCalenderCreditCardPage({
    super.key,
    required this.depositAmount,
    required this.serviceCategory,
    required this.clientName,
    required this.date,
    required this.time,
    required this.endDateTime,
    required this.estimatedTime,
    required this.clientPhone,
    required this.clientEmail,
    required this.clientAddress,
    required this.workerName,
  });

  @override
  State<WorkerCalenderCreditCardPage> createState() =>
      _WorkerCalenderCreditCardPageState();
}

class _WorkerCalenderCreditCardPageState
    extends State<WorkerCalenderCreditCardPage> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      appBar: AppBar(title: const Text('Pay Deposit')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  CreditCardWidget(
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    showBackView: isCvvFocused,
                    onCreditCardWidgetChange: (_) {},
                    isHolderNameVisible: true,
                    obscureCardNumber: true,
                    obscureCardCvv: true,
                    isSwipeGestureEnabled: true,
                    cardBgColor: Colors.blue,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: CreditCardForm(
                        formKey: formKey,
                        cardNumber: cardNumber,
                        expiryDate: expiryDate,
                        cardHolderName: cardHolderName,
                        cvvCode: cvvCode,
                        isHolderNameVisible: true,
                        isCardNumberVisible: true,
                        isExpiryDateVisible: true,
                        obscureCvv: true,
                        obscureNumber: true,
                        inputConfiguration: const InputConfiguration(
                          cardNumberDecoration: InputDecoration(
                            labelText: 'Number',
                            hintText: 'XXXX XXXX XXXX XXXX',
                          ),
                          expiryDateDecoration: InputDecoration(
                            labelText: 'Expiry Date',
                            hintText: 'MM/YY',
                          ),
                          cvvCodeDecoration: InputDecoration(
                            labelText: 'CVV',
                            hintText: 'XXX',
                          ),
                          cardHolderDecoration: InputDecoration(
                            labelText: 'Card Holder',
                          ),
                        ),
                        onCreditCardModelChange: onCreditCardModelChange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _onValidateAndPay,
                    child: const Text("Pay & View Invoice"),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Future<void> _onValidateAndPay() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() => isLoading = true);

      try {
        final supabase = Supabase.instance.client;

        final totalAmount = widget.depositAmount / 0.2;

        final response = await supabase.from('payments').insert({
          'client_name': widget.clientName,
          'client_phone': widget.clientPhone,
          'client_email': widget.clientEmail,
          'client_address': widget.clientAddress,
          'service_category': widget.serviceCategory,
          'deposit_amount': widget.depositAmount,
          'total_amount': totalAmount,
          'card_holder_name': cardHolderName,
          'card_number_last4': cardNumber.replaceAll(' ', '').substring(cardNumber.length - 4),
          'expiry_date': expiryDate,
          'payment_date': DateTime.now().toIso8601String(),
          'status': 'paid',
          'worker_name': widget.workerName,
        }).select();

        // ignore: unnecessary_null_comparison
        if (response != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WorkerCalenderInvoice(
                workerName: widget.workerName,
                serviceCategory: widget.serviceCategory,
                clientName: widget.clientName,
                clientPhone: widget.clientPhone,
                clientEmail: widget.clientEmail,
                clientAddress: widget.clientAddress,
                date: widget.date,
                time: widget.time,
                estimatedTime: Duration(hours: widget.estimatedTime),
                totalPrice: totalAmount,
                deposit: widget.depositAmount,
              ),
            ),
          );
        } else {
          _showError('Payment failed. Please try again.');
        }
      } catch (e) {
        _showError('Error: $e');
      } finally {
        setState(() => isLoading = false);
      }
    } else {
      _showError("Please fill in all fields correctly.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void onCreditCardModelChange(CreditCardModel model) {
    setState(() {
      cardNumber = model.cardNumber;
      expiryDate = model.expiryDate;
      cardHolderName = model.cardHolderName;
      cvvCode = model.cvvCode;
      isCvvFocused = model.isCvvFocused;
    });
  }
}
