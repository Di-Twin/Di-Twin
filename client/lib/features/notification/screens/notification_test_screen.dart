// import 'package:client/features/notification/services/firebase_services.dart';
// import 'package:client/features/notification/services/socket_services.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'as riverpod; 
// import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart';
// import '../managers/notification_manager.dart';
// // import '../services/notification/firebase_service.dart';
// // import '../services/notification/socket_service.dart';
// // import '../models/notification_model.dart';
// // import '../services/api/api_service.dart';

// // Providers
// final firebaseServiceProvider = riverpod.Provider<FirebaseService>((ref) => FirebaseService());

// class NotificationTestScreen extends riverpod.ConsumerStatefulWidget {
//   const NotificationTestScreen({super.key});

//   @override
//   riverpod.ConsumerState<NotificationTestScreen> createState() => _NotificationTestScreenState();
// }

// class _NotificationTestScreenState extends riverpod.ConsumerState<NotificationTestScreen> {
//   TimeOfDay _selectedTime = TimeOfDay.now();
//   DateTime _selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
//   final TextEditingController _userIdController = TextEditingController(text: '56061ab2-b44d-4d72-ae17-155889ab62f0');
//   final TextEditingController _accessTokenController = TextEditingController(
//     text: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI1NjA2MWFiMi1iNDRkLTRkNzItYWUxNy0xNTU4ODlhYjYyZjAiLCJtb2JpbGUiOiIrOTE5Mzg1OTc0MTE3IiwiaWF0IjoxNzQ1ODk4Mzk1LCJleHAiOjE3NDU5ODQ3OTV9.ZTdI2SX7YZTMzS6jkM979rfTSajlAZp2bhXcn2brn3w'
//   );

  
  
//   // Meal timing controllers
//   final TextEditingController _breakfastController = TextEditingController();
//   final TextEditingController _lunchController = TextEditingController();
//   final TextEditingController _dinnerController = TextEditingController();
//   final TextEditingController _snackController = TextEditingController();
  
//   // API response
//   String _apiResponse = '';
//   bool _showLogs = false;

//   @override
//   void initState() {
//     super.initState();
    
//     // Set notification tap handler
//     NotificationManager.onNotificationTap = _handleNotificationTap;
    
//     // Initialize Socket.IO with default user ID and access token
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final socketService = Provider.of<SocketService>(context, listen: false);
//       if (!socketService.isConnected && _userIdController.text.isNotEmpty) {
//         socketService.initSocket(
//           _userIdController.text,
//           accessToken: _accessTokenController.text,
//         );
//       }
      
//       // Initialize meal timing controllers with current time + offsets
//       final now = TimeOfDay.now();
//       _breakfastController.text = _formatTimeOfDay(TimeOfDay(
//         hour: (now.hour + 1) % 24,
//         minute: now.minute,
//       ));
//       _lunchController.text = _formatTimeOfDay(TimeOfDay(
//         hour: (now.hour + 2) % 24,
//         minute: now.minute,
//       ));
//       _dinnerController.text = _formatTimeOfDay(TimeOfDay(
//         hour: (now.hour + 3) % 24,
//         minute: now.minute,
//       ));
//       _snackController.text = _formatTimeOfDay(TimeOfDay(
//         hour: (now.hour + 4) % 24,
//         minute: now.minute,
//       ));
//     });
//   }
  
//   @override
//   void dispose() {
//     _userIdController.dispose();
//     _accessTokenController.dispose();
//     _breakfastController.dispose();
//     _lunchController.dispose();
//     _dinnerController.dispose();
//     _snackController.dispose();
//     super.dispose();
//   }
  
//   String _formatTimeOfDay(TimeOfDay time) {
//     return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
//   }
  
//   void _handleNotificationTap(String? payload) {
//     if (payload != null) {
//       _showSuccessSnackbar('Notification tapped: $payload');
//     }
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//     );

//     if (picked != null) {
//       setState(() {
//         _selectedTime = picked;
//       });
//     }
//   }
  
//   Future<void> _selectTimeForController(BuildContext context, TextEditingController controller) async {
//     // Parse current time from controller
//     TimeOfDay initialTime = TimeOfDay.now();
//     try {
//       final parts = controller.text.split(':');
//       if (parts.length == 2) {
//         final hour = int.tryParse(parts[0]);
//         final minute = int.tryParse(parts[1]);
//         if (hour != null && minute != null) {
//           initialTime = TimeOfDay(hour: hour, minute: minute);
//         }
//       }
//     } catch (e) {
//       // Use default time if parsing fails
//     }
    
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: initialTime,
//     );

//     if (picked != null) {
//       controller.text = _formatTimeOfDay(picked);
//     }
//   }

//   Future<void> _selectDateTime(BuildContext context) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: _selectedDateTime,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );

//     if (pickedDate != null) {
//       final TimeOfDay? pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
//       );

//       if (pickedTime != null) {
//         setState(() {
//           _selectedDateTime = DateTime(
//             pickedDate.year,
//             pickedDate.month,
//             pickedDate.day,
//             pickedTime.hour,
//             pickedTime.minute,
//           );
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final socketService = Provider.of<SocketService>(context);
//     final firebaseService = ref.watch(firebaseServiceProvider);
    
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notification Test'),
//         backgroundColor: Colors.blue,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.home),
//             onPressed: () {
//               Navigator.of(context).pushReplacementNamed('/dashboard');
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildConnectionStatus(socketService, firebaseService),
//             const SizedBox(height: 16),
            
//             _buildSocketConnection(socketService),
//             const SizedBox(height: 16),
            
//             _buildApiTesting(socketService),
//             const SizedBox(height: 16),
            
//             _buildMealTimings(socketService),
//             const SizedBox(height: 16),
            
//             _buildConnectionLogs(socketService),
//             const SizedBox(height: 16),
            
//             _buildSectionTitle('Test Notifications'),
//             _buildTestNotifications(socketService),
            
//             const SizedBox(height: 24),
//             _buildSectionTitle('Reduction Notifications'),
//             _buildReductionNotificationTests(),

//             const SizedBox(height: 24),
//             _buildSectionTitle('Food Log Notifications'),
//             _buildFoodLogNotificationTests(),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildConnectionStatus(SocketService socketService, FirebaseService firebaseService) {
//     final Color statusColor = socketService.serverConfirmedConnection
//         ? Colors.green
//         : (socketService.isVerified 
//             ? Colors.green 
//             : (socketService.isConnected ? Colors.orange : Colors.red));
    
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'FCM Token: ${firebaseService.token?.substring(0, 15) ?? 'Not available'}...',
//               style: const TextStyle(fontSize: 14),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Text('Socket.IO: '),
//                 Container(
//                   width: 12,
//                   height: 12,
//                   decoration: BoxDecoration(
//                     color: statusColor,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   socketService.connectionStatus,
//                   style: TextStyle(
//                     color: statusColor,
//                   ),
//                 ),
//                 if (socketService.isConnected) ...[
//                   const SizedBox(width: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       socketService.sendLocalTestNotification();
//                       _showSuccessSnackbar('Local test notification sent');
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange,
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
//                       minimumSize: const Size(0, 32),
//                     ),
//                     child: const Text('Send Test', style: TextStyle(fontSize: 12)),
//                   ),
//                 ],
//               ],
//             ),
//             if (socketService.mealTimings != null) ...[
//               const SizedBox(height: 8),
//               const Text('Meal Timings:'),
//               const SizedBox(height: 4),
//               Wrap(
//                 spacing: 8,
//                 children: socketService.mealTimings!.entries.map((entry) {
//                   return Chip(
//                     label: Text('${entry.key}: ${entry.value}'),
//                     backgroundColor: Colors.green.shade100,
//                   );
//                 }).toList(),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildSocketConnection(SocketService socketService) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: _userIdController,
//               decoration: const InputDecoration(
//                 labelText: 'User ID',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _accessTokenController,
//               decoration: const InputDecoration(
//                 labelText: 'Access Token',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 2,
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: socketService.isConnected 
//                         ? null 
//                         : () {
//                             socketService.initSocket(
//                               _userIdController.text,
//                               accessToken: _accessTokenController.text,
//                             );
//                             _showSuccessSnackbar('Connecting to Socket.IO...');
//                           },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                     ),
//                     child: const Text('Connect'),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: socketService.isConnected 
//                         ? () {
//                             socketService.disconnect();
//                             _showSuccessSnackbar('Disconnected from Socket.IO');
//                           } 
//                         : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                     ),
//                     child: const Text('Disconnect'),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: () {
//                 socketService.reconnect();
//                 _showSuccessSnackbar('Attempting to reconnect...');
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.amber,
//               ),
//               child: const Text('Force Reconnect'),
//             ),
//             const SizedBox(height: 8),
//             const Divider(),
//             const SizedBox(height: 8),
//             const Text(
//               'Connection Debugging',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       socketService.forceVerification();
//                       _showSuccessSnackbar('Connection manually verified');
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.amber,
//                     ),
//                     child: const Text('Force Verify'),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Send a test event to see if we get any response
//                       socketService.emit('echo', {
//                         'message': 'Echo test',
//                         'timestamp': DateTime.now().toIso8601String(),
//                       });
//                       _showSuccessSnackbar('Echo test sent');
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.teal,
//                     ),
//                     child: const Text('Send Echo'),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Messages received: ${socketService.messageCount}',
//               style: const TextStyle(fontSize: 14),
//             ),
//             if (socketService.lastMessageTime != null)
//               Text(
//                 'Last message: ${_formatDateTime(socketService.lastMessageTime!)}',
//                 style: const TextStyle(fontSize: 14),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildApiTesting(SocketService socketService) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text(
//               'API Testing',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       try {
//                         final result = await socketService.sendTestNotificationViaApi();
//                         setState(() {
//                           _apiResponse = 'Test notification result:\n${result.toString()}';
//                         });
//                         if (result['success'] == true) {
//                           _showSuccessSnackbar('Test notification sent successfully');
//                         } else {
//                           _showErrorSnackbar('Failed to send test notification');
//                         }
//                       } catch (e) {
//                         setState(() {
//                           _apiResponse = 'Error: $e';
//                         });
//                         _showErrorSnackbar('Error: $e');
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.purple,
//                     ),
//                     child: const Text('Send Test Notification'),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             if (_apiResponse.isNotEmpty) ...[
//               const Text('API Response:'),
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(4),
//                   border: Border.all(color: Colors.grey.shade300),
//                 ),
//                 child: Text(_apiResponse),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildConnectionLogs(SocketService socketService) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Connection Logs',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: Icon(_showLogs ? Icons.visibility_off : Icons.visibility),
//                       onPressed: () {
//                         setState(() {
//                           _showLogs = !_showLogs;
//                         });
//                       },
//                       tooltip: _showLogs ? 'Hide Logs' : 'Show Logs',
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.delete),
//                       onPressed: () {
//                         socketService.clearLogs();
//                         _showSuccessSnackbar('Logs cleared');
//                       },
//                       tooltip: 'Clear Logs',
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             if (_showLogs && socketService.connectionLogs.isNotEmpty) ...[
//               const SizedBox(height: 8),
//               Container(
//                 height: 200,
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.black,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: SingleChildScrollView(
//                   reverse: true,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: socketService.connectionLogs.map((log) {
//                       return Text(
//                         log,
//                         style: const TextStyle(
//                           color: Colors.green,
//                           fontFamily: 'monospace',
//                           fontSize: 12,
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildMealTimings(SocketService socketService) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const Text(
//               'Test Meal Timings',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _breakfastController,
//                     decoration: const InputDecoration(
//                       labelText: 'Breakfast',
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                     ),
//                     readOnly: true,
//                     onTap: () => _selectTimeForController(context, _breakfastController),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: TextField(
//                     controller: _lunchController,
//                     decoration: const InputDecoration(
//                       labelText: 'Lunch',
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                     ),
//                     readOnly: true,
//                     onTap: () => _selectTimeForController(context, _lunchController),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _dinnerController,
//                     decoration: const InputDecoration(
//                       labelText: 'Dinner',
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                     ),
//                     readOnly: true,
//                     onTap: () => _selectTimeForController(context, _dinnerController),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: TextField(
//                     controller: _snackController,
//                     decoration: const InputDecoration(
//                       labelText: 'Snack',
//                       border: OutlineInputBorder(),
//                       contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                     ),
//                     readOnly: true,
//                     onTap: () => _selectTimeForController(context, _snackController),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: () {
//                 final mealTimings = {
//                   'breakfast': _breakfastController.text,
//                   'lunch': _lunchController.text,
//                   'dinner': _dinnerController.text,
//                   'snack': _snackController.text,
//                 };
                
//                 socketService.setMealTimings(mealTimings);
//                 _showSuccessSnackbar('Meal timings set and notifications scheduled');
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//               ),
//               child: const Text('Set & Schedule Notifications'),
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: socketService.isConnected
//                   ? () {
//                       // Create a meal_timings object to send to the server
//                       final mealTimingsData = {
//                         'meal_timings': {
//                           'breakfast': _breakfastController.text,
//                           'lunch': _lunchController.text,
//                           'dinner': _dinnerController.text,
//                           'snack': _snackController.text,
//                         }
//                       };
                      
//                       // Emit to server
//                       socketService.emit('update_meal_timings', mealTimingsData);
//                       _showSuccessSnackbar('Meal timings sent to server');
//                     }
//                   : null,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//               ),
//               child: const Text('Send to Server'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildTestNotifications(SocketService socketService) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         const SizedBox(height: 16),
//         ElevatedButton(
//           onPressed: () {
//             NotificationManager.showInAppNotification(
//               NotificationModel(
//                 id: const Uuid().v4(),
//                 title: 'In-App Notification',
//                 message: 'This is a test in-app notification',
//                 type: 'test',
//                 timestamp: DateTime.now(),
//               ),
//             );
//             _showSuccessSnackbar('In-app notification shown');
//           },
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
//           child: const Text('Test In-App Notification'),
//         ),
        
//         const SizedBox(height: 12),
//         ElevatedButton(
//           onPressed: () {
//             NotificationManager.showSystemNotification(
//               NotificationModel(
//                 id: const Uuid().v4(),
//                 title: 'System Notification',
//                 message: 'This is a test system notification',
//                 type: 'test',
//                 timestamp: DateTime.now(),
//                 payload: '{"type":"test","action":"open_app"}',
//               ),
//             );
//             _showSuccessSnackbar('System notification shown');
//           },
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
//           child: const Text('Test System Notification'),
//         ),
        
//         // Add this section for custom notification with image and sound
//         const SizedBox(height: 12),
//         ElevatedButton(
//           onPressed: () {
//             // Path to a default image in your app's assets
//             const String defaultImagePath = 'assets/images/notification_image.png';
//             // Name of a sound file in the raw folder (without extension)
//             const String defaultSoundName = 'notification_sound';
            
//             NotificationManager.showSystemNotification(
//               NotificationModel(
//                 id: const Uuid().v4(),
//                 title: 'Custom Notification',
//                 message: 'This notification has a custom image and sound',
//                 type: 'test',
//                 timestamp: DateTime.now(),
//                 payload: '{"type":"test","action":"open_app"}',
//                 imageUrl: defaultImagePath,
//                 sound: defaultSoundName,
//               ),
//             );
//             _showSuccessSnackbar('Custom notification with image and sound shown');
//           },
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//           child: const Text('Test Custom Notification'),
//         ),
        
//         const SizedBox(height: 12),
//         ElevatedButton(
//           onPressed: socketService.isConnected 
//               ? () {
//                   socketService.emit('test', {
//                     'id': 'socket_test_${DateTime.now().millisecondsSinceEpoch}',
//                     'type': 'test',
//                     'title': 'Test Socket.IO Message',
//                     'message': 'This is a test message sent via Socket.IO',
//                     'timestamp': DateTime.now().toIso8601String(),
//                     'imageUrl': 'assets/images/notification_image.png', // Add image path
//                     'sound': 'notification_sound', // Add sound name
//                   });
//                   _showSuccessSnackbar('Socket.IO message sent with image and sound');
//                 } 
//               : null,
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
//           child: const Text('Test Socket.IO Message with Media'),
//         ),
        
//         const SizedBox(height: 12),
//         ElevatedButton(
//           onPressed: socketService.isConnected 
//               ? () {
//                   // Send multiple test notifications
//                   for (int i = 1; i <= 3; i++) {
//                     Future.delayed(Duration(seconds: i), () {
//                       socketService.emit('notification', {
//                         'id': 'batch_test_${i}_${DateTime.now().millisecondsSinceEpoch}',
//                         'type': 'test',
//                         'title': 'Test Notification $i',
//                         'message': 'This is test notification number $i',
//                         'timestamp': DateTime.now().toIso8601String(),
//                         'data': {
//                           'sequence': i,
//                           'total': 3,
//                           'userId': socketService.userId,
//                         },
//                         'imageUrl': i % 2 == 0 ? 'assets/images/notification_image.png' : null,
//                         'sound': i % 2 == 0 ? 'notification_sound' : null,
//                     });
//                   });
//                 }
//                 _showSuccessSnackbar('Multiple test notifications sent');
//               } 
//             : null,
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//           child: const Text('Send Multiple Test Notifications'),
//         ),
//       ],
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
//       ),
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _buildReductionNotificationTests() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         const SizedBox(height: 16),
//         ElevatedButton(
//           onPressed: () {
//             NotificationManager.showSystemNotification(
//               NotificationModel(
//                 id: 'reduction_reminder_${const Uuid().v4()}',
//                 title: 'Time for Your Medication',
//                 message: 'Amoxicillin 500mg. Take with food.',
//                 type: 'reduction_reminder',
//                 timestamp: DateTime.now(),
//                 payload: '{"type":"reduction_reminder","medicationName":"Amoxicillin","dosage":"500mg"}',
//               ),
//             );
//             _showSuccessSnackbar('Reduction reminder notification sent');
//           },
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
//           child: const Text('Test Immediate Reduction Reminder'),
//         ),

//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => _selectTime(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey.shade700,
//                 ),
//                 child: Text('Select Time: ${_selectedTime.format(context)}'),
//               ),
//             ),
//             const SizedBox(width: 8),
//             ElevatedButton(
//               onPressed: () {
//                 NotificationManager.showSystemNotification(
//                   NotificationModel(
//                     id: 'reduction_daily_${const Uuid().v4()}',
//                     title: 'Reduction Reminder',
//                     message: 'Amoxicillin 500mg due at ${_selectedTime.format(context)}',
//                     type: 'reduction_reminder',
//                     timestamp: DateTime.now(),
//                     payload: '{"type":"reduction_reminder","medicationName":"Amoxicillin","dosage":"500mg","reminderTime":"${_selectedTime.format(context)}"}',
//                   ),
//                 );
//                 _showSuccessSnackbar(
//                   'Reduction reminder scheduled for ${_selectedTime.format(context)}',
//                 );
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
//               child: const Text('Schedule Daily'),
//             ),
//           ],
//         ),

//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => _selectDateTime(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey.shade700,
//                 ),
//                 child: Text(
//                   'One-time: ${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             ElevatedButton(
//               onPressed: () {
//                 NotificationManager.showSystemNotification(
//                   NotificationModel(
//                     id: 'reduction_onetime_${const Uuid().v4()}',
//                     title: 'One-time Reduction Reminder',
//                     message: 'Amoxicillin 500mg. Take with food.',
//                     type: 'reduction_reminder',
//                     timestamp: DateTime.now(),
//                     payload: '{"type":"reduction_reminder","medicationName":"Amoxicillin","dosage":"500mg","reminderTime":"${_selectedDateTime.toIso8601String()}"}',
//                   ),
//                 );
//                 _showSuccessSnackbar('One-time reduction reminder scheduled');
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
//               child: const Text('Schedule Once'),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildFoodLogNotificationTests() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         const SizedBox(height: 16),
//         ElevatedButton(
//           onPressed: () {
//             NotificationManager.showSystemNotification(
//               NotificationModel(
//                 id: 'food_log_${const Uuid().v4()}',
//                 title: 'Food Log Reminder',
//                 message: 'Time to log your lunch! Maintaining a food log helps you stay on track.',
//                 type: 'food_log_reminder',
//                 timestamp: DateTime.now(),
//                 payload: '{"type":"food_log_reminder","mealType":"Lunch"}',
//               ),
//             );
//             _showSuccessSnackbar('Food log reminder notification sent');
//           },
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//           child: const Text('Test Immediate Food Log Reminder'),
//         ),

//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => _selectTime(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey.shade700,
//                 ),
//                 child: Text('Select Time: ${_selectedTime.format(context)}'),
//               ),
//             ),
//             const SizedBox(width: 8),
//             ElevatedButton(
//               onPressed: () {
//                 NotificationManager.showSystemNotification(
//                   NotificationModel(
//                     id: 'food_log_scheduled_${const Uuid().v4()}',
//                     title: 'Food Log Reminder',
//                     message: 'Time to log your dinner!',
//                     type: 'food_log_reminder',
//                     timestamp: DateTime.now(),
//                     payload: '{"type":"food_log_reminder","mealType":"Dinner","reminderTime":"${_selectedTime.format(context)}"}',
//                   ),
//                 );
//                 _showSuccessSnackbar(
//                   'Food log reminder scheduled for ${_selectedTime.format(context)}',
//                 );
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//               child: const Text('Schedule'),
//             ),
//           ],
//         ),

//         const SizedBox(height: 12),
//         ElevatedButton(
//           onPressed: () {
//             // Schedule breakfast
//             NotificationManager.showSystemNotification(
//               NotificationModel(
//                 id: 'food_log_breakfast_${const Uuid().v4()}',
//                 title: 'Food Log Reminder',
//                 message: 'Time to log your breakfast!',
//                 type: 'food_log_reminder',
//                 timestamp: DateTime.now(),
//                 payload: '{"type":"food_log_reminder","mealType":"Breakfast","reminderTime":"08:00"}',
//               ),
//             );
            
//             // Schedule lunch
//             NotificationManager.showSystemNotification(
//               NotificationModel(
//                 id: 'food_log_lunch_${const Uuid().v4()}',
//                 title: 'Food Log Reminder',
//                 message: 'Time to log your lunch!',
//                 type: 'food_log_reminder',
//                 timestamp: DateTime.now(),
//                 payload: '{"type":"food_log_reminder","mealType":"Lunch","reminderTime":"12:30"}',
//               ),
//             );
            
//             // Schedule dinner
//             NotificationManager.showSystemNotification(
//               NotificationModel(
//                 id: 'food_log_dinner_${const Uuid().v4()}',
//                 title: 'Food Log Reminder',
//                 message: 'Time to log your dinner!',
//                 type: 'food_log_reminder',
//                 timestamp: DateTime.now(),
//                 payload: '{"type":"food_log_reminder","mealType":"Dinner","reminderTime":"19:00"}',
//               ),
//             );
            
//             _showSuccessSnackbar('All meal reminders scheduled');
//           },
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//           child: const Text('Schedule All Meals'),
//         ),
//       ],
//     );
//   }

//   void _showSuccessSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
  
//   void _showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   String _formatDateTime(DateTime dateTime) {
//     return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
//   }
// }
