import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final List<Map<String, dynamic>> messages = [
    {"isUser": false, "text": "initial_bot_message".tr}
  ];

  final TextEditingController _chatController = TextEditingController();

  String? _clientName;
  String? _userMessage;
  String? _phoneNumber;
  bool _submitted = false;

  void _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _submitted) return;

    setState(() {
      messages.add({"isUser": true, "text": text});
    });

    _chatController.clear();

    if (_clientName == null) {
      _clientName = text;
      _addBotMessage("thanks_name".trParams({'name': _clientName!}));
    } else if (_userMessage == null) {
      _userMessage = text;
      _addBotMessage("enter_phone".tr);
    } else if (_phoneNumber == null) {
      if (!_isValidPhoneNumber(text)) {
        _addBotMessage("invalid_phone".tr);
        return;
      }
      _phoneNumber = text;

      try {
        await Supabase.instance.client.from('support_requests').insert({
          'client_name': _clientName,
          'message': _userMessage,
          'phone': _phoneNumber,
          'created_at': DateTime.now().toIso8601String(),
        });

        _addBotMessage("message_received".trParams({'name': _clientName!}));
        _submitted = true;
      } catch (e) {
        _addBotMessage("error_sending".tr);
      }
    } else {
      _addBotMessage("already_processing".tr);
    }
  }

  void _addBotMessage(String text) {
    setState(() {
      messages.add({"isUser": false, "text": text});
    });
  }

  bool _isValidPhoneNumber(String input) {
    final phoneRegExp = RegExp(r'^\+?\d{9,15}$');
    return phoneRegExp.hasMatch(input);
  }

  void _launchPhoneCall() async {
    const phoneNumber = 'tel:+201063723426'; // Replace with real support number
    final Uri url = Uri.parse(phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("could_not_launch_phone".tr)),
      );
    }
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
       appBar: AppBar(
    iconTheme: const IconThemeData(color: Colors.white),
    title: Text(
      'contact_us'.tr,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    backgroundColor: Theme.of(context).colorScheme.primary,
  ),     
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: theme.colorScheme.primary.withOpacity(0.1),
            child: Text(
              "live_chat_support".tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(
                  messages[index]["text"],
                  messages[index]["isUser"],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: "type_message_hint".tr,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                )
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text("prefer_to_talk".tr),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _launchPhoneCall,
                  icon: const Icon(Icons.phone),
                  label: Text("call_us_now".tr),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
