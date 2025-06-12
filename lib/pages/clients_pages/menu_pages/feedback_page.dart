import 'package:flutter/material.dart';
import 'package:handy_home2/repo/workers_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final WorkersRepo _workersRepo = WorkersRepo.instance;
  final SupabaseClient _client = Supabase.instance.client;

  final List<String> serviceCategories = ['Plumbing'.tr, 'Electrical'.tr, 'Cleaning'.tr,
   'Carpentry'.tr, 'Painting', 'Babysitting','Apartment Finishing' ];
  String? selectedService;
  Map<String, String> workerNameToId = {};
  String? selectedWorkerName;

  int? selectedEmojiIndex;
  final TextEditingController _reviewController = TextEditingController();
  final List<String> emojis = ['😠', '😕', '🙂', '😃', '🤩'];

  final Map<int, List<String>> feedbackSuggestions = {
    0: ['very_rude'.tr, 'late_arrival'.tr, 'unprofessional'.tr],
    1: ['could_be_better'.tr, 'slow_response'.tr, 'needs_improvement'.tr],
    2: ['average_service'.tr, 'okay_overall'.tr],
    3: ['great_service'.tr, 'on_time'.tr, 'friendly'.tr],
    4: ['excellent_service'.tr, 'very_professional'.tr, 'highly_recommend'.tr]
  };

  List<String> selectedTags = [];

  void toggleTag(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
    });
  }

  Future<void> fetchWorkersForCategory(String category) async {
    try {
      final List<Map<String, dynamic>> workers =
          await _workersRepo.fetchWorkersForService(category);

      setState(() {
        workerNameToId = {
          for (var worker in workers) worker['name']: worker['id'].toString()
        };
        selectedWorkerName = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${'failed_load_workers'.tr} $e")),
      );
    }
  }

  Future<void> submitFeedback() async {
    if (selectedService == null ||
        selectedWorkerName == null ||
        selectedEmojiIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("complete_all_fields".tr)),
      );
      return;
    }

    final workerId = workerNameToId[selectedWorkerName];

    try {
      await _client.from('feedback').insert({
        'worker_id': workerId,
        'service_category': selectedService,
        'rating': selectedEmojiIndex! + 1,
        'tags': selectedTags,
        'review': _reviewController.text,
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("feedback_submitted".tr)),
      );

      setState(() {
        selectedService = null;
        selectedWorkerName = null;
        selectedEmojiIndex = null;
        selectedTags.clear();
        _reviewController.clear();
        workerNameToId.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${'error_submitting_feedback'.tr} $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("leave_feedback".tr),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text("select_service".tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedService,
              hint: Text("choose_service".tr),
              items: serviceCategories
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedService = value;
                });
                fetchWorkersForCategory(value!);
              },
            ),

            const SizedBox(height: 18),
            Text("select_worker".tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedWorkerName,
              hint: Text("choose_worker_feedback".tr),
              items: workerNameToId.keys
                  .map((name) =>
                      DropdownMenuItem<String>(value: name, child: Text(name)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedWorkerName = value;
                });
              },
            ),

            const SizedBox(height: 25),
            Text("how_was_service".tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(emojis.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedEmojiIndex = index;
                      selectedTags.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedEmojiIndex == index
                          ? Colors.blueAccent.withOpacity(0.2)
                          : null,
                    ),
                    child:
                        Text(emojis[index], style: const TextStyle(fontSize: 32)),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),
            if (selectedEmojiIndex != null)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: feedbackSuggestions[selectedEmojiIndex]!
                    .map((tag) => ChoiceChip(
                          label: Text(tag),
                          selected: selectedTags.contains(tag),
                          onSelected: (_) => toggleTag(tag),
                        ))
                    .toList(),
              ),

            const SizedBox(height: 25),
            Text("write_review".tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "type_feedback".tr,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: submitFeedback,
                icon: const Icon(Icons.send),
                label: Text("submit_feedback".tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
