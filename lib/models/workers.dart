class Worker {
  final String id;
  final String name;
  final String details;
  final int experienceYears;
  final String phoneNumber;
  final double rating;
  final String region;
  final String serviceCategory;
  final String imagepath;
  final String description;
  final List<String> availableDays;
  final String startTime;
  final String endTime;


  Worker({
    required this.id,
    required this.name,
    required this.details,
    required this.experienceYears,
    required this.phoneNumber,
    required this.rating,
    required this.region,
    required this.serviceCategory,
    required this.imagepath,
    required this.description,
    required this.availableDays,
    required this.startTime,
    required this.endTime,
  });
}

class WorkerProfile {
  final String? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? nationalIdNumber;
  final List<String>? region;
  final List<String>? jobs;
  final bool isApproved;
  final double? rating;
  final String? description;
  final List<String>? availableDays;
  final String? startTime;
  final String? endTime;
  final int? experienceYears;

  WorkerProfile({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.nationalIdNumber,
    this.region,
    this.jobs,
    required this.isApproved,
    this.rating,
    this.description,
    this.availableDays,
    this.startTime,
    this.endTime,
    this.experienceYears,
  });

  factory WorkerProfile.fromJson(Map<String, dynamic> json) {
    return WorkerProfile(
      id: json['id'],
      name: json['name'],
      phone: json['phone_number'],
      email: json['email'],
      nationalIdNumber: json['national_id'],
      region: List<String>.from(json['region'] ?? []),
      jobs: List<String>.from(json['selected_jobs'] ?? []),
      isApproved: json['is_approved'] ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
      description: json['details'],
      availableDays: List<String>.from(json['available_days'] ?? []),
      startTime: json['start_time'],
      endTime: json['end_time'],
      experienceYears: json['experience_years'],
    );}
  }
