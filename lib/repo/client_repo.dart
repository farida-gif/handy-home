import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:handy_home2/models/client_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientsRepo extends GetxController {
  final SupabaseClient _client = Supabase.instance.client;

  static final ClientsRepo instance = ClientsRepo._internal();
  
  ClientsRepo._internal();

  /// Client sign-up
  Future<void> clientSignUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String region,
    required String address,
  }) async {
    try {
      final AuthResponse response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw Exception('Sign-up failed. User not created.');

      await _client.from('clients').insert({
        'id': user.id,
        'name': fullName,
        'phone': phoneNumber,
        'email': email,
        'password': password,
        'client_address': address,
        'client_region': region,
      });
    } catch (e) {
      throw Exception('Client sign-up failed: $e');
    }
  }

  /// Client login
  Future<void> clientLogIn({
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

  /// Save or update client profile
  Future<void> saveClientProfile({
    required String name,
    required String phone,
    required String email,
    required String region,
    required String address,
    Uint8List? profileImageBytes,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      String? profileImageUrl;

      // Upload profile image if provided
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

      // Update client profile
      await _client.from('clients').update({
        'name': name,
        'phone': phone,
        'email': email,
        'client_region': region,
        'client_address': address,
        if (profileImageUrl != null) 'profile_img_url': profileImageUrl,
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to save client profile: $e');
    }
  }

  // Load current client profile
  Future<ClientProfile?> getClientProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final res =
          await _client.from('clients').select().eq('id', userId).single();
      return ClientProfile.fromJson(res);
    } catch (e) {
      print('Failed to load profile: $e');
      return null;
    }
  }
}
