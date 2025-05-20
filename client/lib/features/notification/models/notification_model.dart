class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  final String? payload;
  final bool ongoing; // Added for persistent notifications
  final String? imageUrl; // Added for notification image
  final String? sound; // Added for notification sound

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.payload,
    this.ongoing = false, // Default to non-persistent
    this.imageUrl, // Add this line
    this.sound, // Add this line
  });
  
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: json['type'] ?? 'general',
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      payload: json['payload'],
      ongoing: json['ongoing'] == true,
      imageUrl: json['imageUrl'], // Add this line
      sound: json['sound'], // Add this line
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'payload': payload,
      'ongoing': ongoing,
      'imageUrl': imageUrl, // Add this line
      'sound': sound, // Add this line
    };
  }
}
