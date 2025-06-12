import 'package:supabase_flutter/supabase_flutter.dart';

class ServiceRepo {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch specializations for a service type
  Future<List<String>> fetchServiceSpecializations(String serviceName) async {
    try {
      final Map<String, dynamic>? response = await _client
          .from('services')
          .select('specializations')
          .eq('name', serviceName)
          .maybeSingle();

      if (response != null && response['specializations'] != null) {
        return List<String>.from(response['specializations']);
      } else {
        throw Exception('No specializations found for $serviceName');
      }
    } catch (e) {
      throw Exception('Failed to fetch $serviceName specializations: $e');
    }
  }

  // Fetch description for a service type
  Future<String> fetchServiceDescription(String serviceName) async {
    try {
      final Map<String, dynamic>? response = await _client
          .from('services')
          .select('description')
          .eq('name', serviceName)
          .maybeSingle();

      if (response != null && response['description'] != null) {
        return response['description'] as String;
      } else {
        return 'No description available.';
      }
    } catch (e) {
      throw Exception('Failed to fetch $serviceName description: $e');
    }
  }

  // Fetch price for a service type
  Future<double> fetchServicePrice(String serviceName) async {
    try {
      final Map<String, dynamic>? response = await _client
          .from('services')
          .select('price')
          .eq('name', serviceName)
          .maybeSingle();

      if (response != null && response['price'] != null) {
        final rawPrice = response['price'];
        if (rawPrice is num) {
          return rawPrice.toDouble();
        } else {
          throw Exception('Price is not a numeric type');
        }
      } else {
        throw Exception('No price found for $serviceName');
      }
    } catch (e) {
      throw Exception('Failed to fetch $serviceName price: $e');
    }
  }

  // Insert service order
  Future<void> createServiceOrder({
    required String serviceName,
    required String specialization,
    required double price,
    required int estimatedTime,
    required String userId,
  }) async {
    try {
      await _client.from('service_orders').insert({
        'service_category': serviceName,
        'specialization': specialization,
        'price': price,
        'estimated_time': estimatedTime,
        'user_id': userId,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to create service order: $e');
    }
  }
}
