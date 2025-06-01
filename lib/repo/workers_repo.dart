import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:handy_home2/models/workers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkersRepo extends GetxController {
  final SupabaseClient _client = Supabase.instance.client;

  static final WorkersRepo instance = WorkersRepo._internal();
  WorkersRepo._internal();

  /// Worker Sign-Up
  Future<void> workerSignUp({
  required String email,
  required String password,
  required String fullName,
  required String phoneNumber,
  required String nationalId,
  required List<String> region,
  required int experienceYears,
  required List<String> selectedJobs,
  required String description,
  required List<String> availableDays,
  required String startTime,
  required String endTime,
}) async {
  try {
    // Sign up the user
    final AuthResponse response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Sign-up failed: User creation unsuccessful.');
    }

    // Insert additional profile info into workers table
    final insertResponse = await _client.from('workers').insert({
      'id': user.id,
      'name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'national_id': nationalId,
      'is_approved': false,
      'region': region, // Should be 'text[]' or 'jsonb' in Supabase
      'selected_jobs': selectedJobs, // Should be 'text[]' or 'jsonb'
      'experience_years': experienceYears,
      'details': description,
      'available_days': availableDays, // Should be 'text[]' or 'jsonb'
      'start_time': startTime,
      'end_time': endTime,
    }).select();

     if (insertResponse.isEmpty) {
      throw Exception("Worker data insertion failed.");
    }
  } on AuthException catch (e) {
    throw Exception("Authentication failed: ${e.message}");
  } catch (e) {
    throw Exception('Worker sign-up failed: $e');
  }
}

  /// Worker Log-In
  Future<void> workerLogIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Save or update worker profile
  Future<void> saveWorkerProfile({
    required String name,
    required String phone,
    required String email,
    required List<String> selectedJobs,
    required String nationalIdNumber,
    required List<String> region,
    required String description,
    required List<String> availableDays,
    required String startTime,
    required String endTime,
    required int experienceYears,
    Uint8List? profileImageBytes,
    Uint8List? nationalIdImageBytes,
    File? cvFile,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      String? profileImageUrl;
      String? nidImageUrl;
      String? cvUrl;

      // Upload profile image
      if (profileImageBytes != null) {
        await _client.storage.from('images').uploadBinary(
          'profile_images/$userId.jpg',
          profileImageBytes,
          fileOptions: const FileOptions(upsert: true),
        );
        profileImageUrl = _client.storage
            .from('images')
            .getPublicUrl('profile_images/$userId.jpg');
      }

      // Upload national ID image
      if (nationalIdImageBytes != null) {
        await _client.storage.from('national.ids').uploadBinary(
          'nid_images/$userId.jpg',
          nationalIdImageBytes,
          fileOptions: const FileOptions(upsert: true),
        );
        nidImageUrl = _client.storage
            .from('national.ids')
            .getPublicUrl('nid_images/$userId.jpg');
      }

      // Upload CV
      if (cvFile != null) {
        await _client.storage.from('workers.cv').upload(
          'cv_files/$userId.pdf',
          cvFile,
          fileOptions: const FileOptions(upsert: true),
        );
        cvUrl = _client.storage
            .from('workers.cv')
            .getPublicUrl('cv_files/$userId.pdf');
      }

      // Update worker data
      await _client.from('workers').update({
        'name': name,
        'phone_number': phone,
        'email': email,
        'selected_jobs': selectedJobs,
        'national_id': nationalIdNumber,
        'region': region,
        'details': description,
        'available_days': availableDays,
        'start_time': startTime,
        'end_time': endTime,
        'experience_years': experienceYears,
        if (profileImageUrl != null) 'profile_img_url': profileImageUrl,
        if (nidImageUrl != null) 'national_id_img_url': nidImageUrl,
        if (cvUrl != null) ...{
          'cv_url': cvUrl,
          'is_cv_uploaded': true,
        },
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to save worker profile: $e');
    }
  }

  /// Update profile extras from EditWorkerProfilePage
  static Future<void> updateWorkerExtras({
    required String workerId,
    required String description,
    required List<String> availableDays,
    required String startTime,
    required String endTime,
    required int experienceYears,
  }) async {
    final updates = {
      'details': description,
      'available_days': availableDays,
      'start_time': startTime,
      'end_time': endTime,
      'experience_years': experienceYears,
    };

    await Supabase.instance.client
        .from('workers')
        .update(updates)
        .eq('id', workerId);
  }

  /// Get current worker profile
  Future<WorkerProfile?> getWorkerProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final res = await _client.from('workers').select().eq('id', userId).single();
      return WorkerProfile.fromJson(res);
    } catch (e) {
      print('Failed to load profile: $e');
      return null;
    }
  }

  /// Fetch approved workers by service
   Future<List<Map<String, dynamic>>> fetchWorkersForService(String serviceCategory) async {
    try {
      final response = await _client
          .from('workers')
          .select()
          .eq('service_category', serviceCategory)
          .eq('is_approved', true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch workers for service "$serviceCategory": $e');
    }
  } 

  /// Uploads
  Future<void> uploadProfileImage(String workerId, File file) async {
    final path = 'profile_images/$workerId.jpg';
    await _client.storage.from('images').upload(
      path,
      file,
      fileOptions: const FileOptions(upsert: true),
    );
  }

  Future<void> uploadCv(String workerId, File file) async {
    final path = 'cv_files/$workerId.pdf';
    await _client.storage.from('workers.cv').upload(
      path,
      file,
      fileOptions: const FileOptions(upsert: true),
    );
  }

  Future<void> uploadNationalId(String workerId, File file) async {
    final path = 'nid_images/$workerId.jpg';
    await _client.storage.from('national.ids').upload(
      path,
      file,
      fileOptions: const FileOptions(upsert: true),
    );
  }
}