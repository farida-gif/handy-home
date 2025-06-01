class Booking {
  final String id;
  final String workerId; // Connects to Worker model
  final String userId; // Identifies the client/user
  final DateTime startTime;
  final DateTime endTime;
  // Add other fields as needed

  Booking({
    required this.id,
    required this.workerId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    // ...
  });
} 