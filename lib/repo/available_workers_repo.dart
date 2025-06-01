// available_workers_repo.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class AvailableWorkersRepo {
  static final AvailableWorkersRepo instance = AvailableWorkersRepo._();

  AvailableWorkersRepo._();

  final _supabase = Supabase.instance.client;

  /// Fetch all approved workers for a specific service category
  Future<List<Map<String, dynamic>>> fetchApprovedWorkersByService(String serviceCategory) async {
    try {
      final response = await _supabase
          .from('workers')
          .select('*')
          .eq('service_category', serviceCategory)
          .eq('is_approved', true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error fetching approved workers: $e');
    }
  }

  /// Optionally, fetch workers by region as well
  Future<List<Map<String, dynamic>>> fetchApprovedWorkersByServiceAndRegion(
    String serviceCategory,
    String region,
  ) async {
    try {
      final response = await _supabase
          .from('workers')
          .select('*')
          .eq('service_category', serviceCategory)
          .eq('is_approved', true)
          .eq('region', region);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error fetching workers by service and region: $e');
    }
  }
}
