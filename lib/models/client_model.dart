

class Client {
  final String id;
  final String name;
  final String details;
  final int experienceYears;
  final String phoneNumber;
  final double rating;
  final String region;
  final String serviceCategory;
  final String imagepath; // Local image path from assets

  Client({
    required this.id,
    required this.name,
    required this.details,
    required this.experienceYears,
    required this.phoneNumber,
    required this.rating,
    required this.region,
    required this.serviceCategory,
    required this.imagepath,
  });
}
class ClientProfile {
  final String name;
  final String phone;
  final String email;
  final String address;
  final String region;
  final String? profileImgUrl;

  ClientProfile({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.region,
    this.profileImgUrl,
  });

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      name: json['name'],
      phone: json['phone'],
      email: json['email'] ,
      address: json['client_address'] ,
      region: json['client_region'],
    );
  }

  get id => null;
}
