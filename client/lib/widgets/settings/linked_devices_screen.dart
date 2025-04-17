import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LinkedDeviceScreen extends StatefulWidget {
  const LinkedDeviceScreen({super.key});

  @override
  State<LinkedDeviceScreen> createState() => _LinkedDeviceScreenState();
}

class _LinkedDeviceScreenState extends State<LinkedDeviceScreen> with SingleTickerProviderStateMixin {
  // Enhanced device model with more properties
  final List<Map<String, dynamic>> devices = [
    {
      'name': 'Fitbit Sense 2',
      'type': 'fitbit',
      'model': 'Sense 2',
      'lastSynced': DateTime.now().subtract(const Duration(minutes: 5)),
      'isConnected': true,
      'batteryLevel': 78,
      'image': 'images/fitbit.png',
      'metrics': ['steps', 'heart_rate', 'sleep', 'calories'],
      'color': const Color(0xFF00B0B9),
    },
    {
      'name': 'Apple Watch Series 8',
      'type': 'apple_watch',
      'model': 'Series 8',
      'lastSynced': DateTime.now().subtract(const Duration(hours: 2)),
      'isConnected': true,
      'batteryLevel': 65,
      'image': 'images/apple_watch.png',
      'metrics': ['steps', 'heart_rate', 'sleep', 'calories', 'blood_oxygen'],
      'color': const Color(0xFF007AFF),
    },
    {
      'name': 'Withings Body+',
      'type': 'scale',
      'model': 'Body+',
      'lastSynced': DateTime.now().subtract(const Duration(days: 1)),
      'isConnected': false,
      'batteryLevel': 42,
      'image': 'images/weight_scale.png',
      'metrics': ['weight', 'body_fat', 'bmi'],
      'color': const Color(0xFF6E45E2),
    },
    {
      'name': 'Omron Blood Pressure',
      'type': 'bp_monitor',
      'model': 'M7 Intelli IT',
      'lastSynced': DateTime.now().subtract(const Duration(days: 3)),
      'isConnected': false,
      'batteryLevel': 30,
      'image': 'images/bp_monitor.png',
      'metrics': ['systolic', 'diastolic', 'pulse'],
      'color': const Color(0xFFE53935),
    },
  ];

  // Current page index for device slider
  int currentDeviceIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _syncAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentDeviceIndex);
    
    // Setup animation for sync button
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _syncAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _getTimeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return dateTime.toString().substring(0, 10);
    }
  }

  // Get icon based on device type
  IconData _getDeviceIcon(String type) {
    switch (type) {
      case 'fitbit':
        return Icons.watch;
      case 'apple_watch':
        return Icons.watch;
      case 'scale':
        return Icons.monitor_weight_outlined;
      case 'bp_monitor':
        return Icons.favorite_border;
      default:
        return Icons.devices_other;
    }
  }

  // Get metrics icons
  IconData _getMetricIcon(String metric) {
    switch (metric) {
      case 'steps':
        return Icons.directions_walk;
      case 'heart_rate':
        return Icons.favorite;
      case 'sleep':
        return Icons.nightlight_round;
      case 'calories':
        return Icons.local_fire_department;
      case 'blood_oxygen':
        return Icons.air;
      case 'weight':
        return Icons.monitor_weight;
      case 'body_fat':
        return Icons.percent;
      case 'bmi':
        return Icons.straighten;
      case 'systolic':
      case 'diastolic':
        return Icons.favorite_border;
      case 'pulse':
        return Icons.timeline;
      default:
        return Icons.data_usage;
    }
  }

  // Get formatted metric name
  String _formatMetricName(String metric) {
    return metric.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }

  void _showUnlinkDialog(BuildContext context, Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning icon
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Unlink Device',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),

              // Device info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    // Device icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: device['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getDeviceIcon(device['type']),
                        color: device['color'],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Device details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device['name'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last synced: ${_getTimeAgo(device['lastSynced'])}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Warning message
              Text(
                'Are you sure you want to unlink this device? You will need to reconnect it later if you want to use it again.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E293B),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Unlink button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Remove device logic
                          setState(() {
                            if (devices.length > 1) {
                              devices.removeAt(currentDeviceIndex);
                              if (currentDeviceIndex >= devices.length) {
                                currentDeviceIndex = devices.length - 1;
                              }
                              _pageController.jumpToPage(currentDeviceIndex);
                            }
                          });

                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Device unlinked successfully',
                                style: GoogleFonts.plusJakartaSans(),
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Unlink',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDeviceBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Add New Device',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Device list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDeviceTypeCard(
                    'Fitbit',
                    'Connect your Fitbit device to track steps, heart rate, and sleep',
                    Icons.watch,
                    const Color(0xFF00B0B9),
                    onTap: () {
                      Navigator.pop(context);
                      _showConnectingDialog('Fitbit');
                    },
                  ),
                  
                  _buildDeviceTypeCard(
                    'Apple Watch',
                    'Connect your Apple Watch to track your health metrics',
                    Icons.watch,
                    const Color(0xFF007AFF),
                    onTap: () {
                      Navigator.pop(context);
                      _showConnectingDialog('Apple Watch');
                    },
                  ),
                  
                  _buildDeviceTypeCard(
                    'Smart Scale',
                    'Connect your smart scale to track weight and body composition',
                    Icons.monitor_weight_outlined,
                    const Color(0xFF6E45E2),
                    onTap: () {
                      Navigator.pop(context);
                      _showConnectingDialog('Smart Scale');
                    },
                  ),
                  
                  _buildDeviceTypeCard(
                    'Blood Pressure Monitor',
                    'Connect your BP monitor to track blood pressure readings',
                    Icons.favorite_border,
                    const Color(0xFFE53935),
                    onTap: () {
                      Navigator.pop(context);
                      _showConnectingDialog('Blood Pressure Monitor');
                    },
                  ),
                  
                  _buildDeviceTypeCard(
                    'Manual Entry',
                    'Manually log your health data without a connected device',
                    Icons.edit_note,
                    const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.pop(context);
                      // Add manual entry device
                      setState(() {
                        devices.add({
                          'name': 'Manual Tracking',
                          'type': 'manual',
                          'model': 'Manual Entry',
                          'lastSynced': DateTime.now(),
                          'isConnected': true,
                          'batteryLevel': 100,
                          'image': 'images/manual_entry.png',
                          'metrics': ['weight', 'heart_rate', 'blood_pressure', 'steps'],
                          'color': const Color(0xFF4CAF50),
                        });
                        currentDeviceIndex = devices.length - 1;
                        _pageController.animateToPage(
                          currentDeviceIndex,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceTypeCard(String title, String description, IconData icon, Color color, {required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConnectingDialog(String deviceType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Connecting to $deviceType',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we connect to your device...',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Simulate connection process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      
      // Add new device to the list
      setState(() {
        Map<String, dynamic> newDevice = {};
        
        switch (deviceType) {
          case 'Fitbit':
            newDevice = {
              'name': 'Fitbit Versa 3',
              'type': 'fitbit',
              'model': 'Versa 3',
              'lastSynced': DateTime.now(),
              'isConnected': true,
              'batteryLevel': 92,
              'image': 'images/fitbit.png',
              'metrics': ['steps', 'heart_rate', 'sleep', 'calories'],
              'color': const Color(0xFF00B0B9),
            };
            break;
          case 'Apple Watch':
            newDevice = {
              'name': 'Apple Watch SE',
              'type': 'apple_watch',
              'model': 'SE',
              'lastSynced': DateTime.now(),
              'isConnected': true,
              'batteryLevel': 85,
              'image': 'images/apple_watch.png',
              'metrics': ['steps', 'heart_rate', 'sleep', 'calories', 'blood_oxygen'],
              'color': const Color(0xFF007AFF),
            };
            break;
          case 'Smart Scale':
            newDevice = {
              'name': 'Withings Body Cardio',
              'type': 'scale',
              'model': 'Body Cardio',
              'lastSynced': DateTime.now(),
              'isConnected': true,
              'batteryLevel': 90,
              'image': 'images/weight_scale.png',
              'metrics': ['weight', 'body_fat', 'bmi'],
              'color': const Color(0xFF6E45E2),
            };
            break;
          case 'Blood Pressure Monitor':
            newDevice = {
              'name': 'Omron Connect',
              'type': 'bp_monitor',
              'model': 'M7 Intelli IT',
              'lastSynced': DateTime.now(),
              'isConnected': true,
              'batteryLevel': 95,
              'image': 'images/bp_monitor.png',
              'metrics': ['systolic', 'diastolic', 'pulse'],
              'color': const Color(0xFFE53935),
            };
            break;
        }
        
        devices.add(newDevice);
        currentDeviceIndex = devices.length - 1;
        _pageController.animateToPage(
          currentDeviceIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$deviceType connected successfully',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    });
  }

  void _syncDevice() {
    final currentDevice = devices[currentDeviceIndex];
    
    // Start animation
    _animationController.reset();
    _animationController.forward();
    
    // Update last synced time
    setState(() {
      devices[currentDeviceIndex]['lastSynced'] = DateTime.now();
    });
    
    // Show syncing message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Syncing with ${currentDevice['name']}...',
          style: GoogleFonts.plusJakartaSans(),
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    
    // After animation completes, show success message
    Future.delayed(const Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Device synced successfully',
            style: GoogleFonts.plusJakartaSans(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          children: [
            // Navigation bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  // Back button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, size: 28),
                      onPressed: () => Navigator.pop(context),
                      color: const Color(0xFF1E293B),
                    ),
                  ),

                  // Title
                  const SizedBox(width: 16),
                  Text(
                    'Connected Devices',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Add device button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, size: 28),
                      onPressed: _showAddDeviceBottomSheet,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Device carousel
            Expanded(
              child: devices.isEmpty
                  ? _buildEmptyState()
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: devices.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentDeviceIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        return _buildDeviceCard(device);
                      },
                    ),
            ),

            // Page indicator
            if (devices.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    devices.length,
                    (index) => GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentDeviceIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentDeviceIndex == index
                              ? devices[currentDeviceIndex]['color']
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            // Bottom action buttons
            if (devices.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Remove button
                    Container(
                      width: 64,
                      height: 64,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 28),
                        onPressed: () => _showUnlinkDialog(context, devices[currentDeviceIndex]),
                        color: Colors.grey.shade500,
                      ),
                    ),

                    // Sync button (larger)
                    AnimatedBuilder(
                      animation: _syncAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: devices[currentDeviceIndex]['color'],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: Transform.rotate(
                              angle: _syncAnimation.value * 6.28,
                              child: const Icon(Icons.sync, size: 36),
                            ),
                            onPressed: _syncDevice,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'No Devices Connected',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add a device to track your health metrics',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddDeviceBottomSheet,
            icon: const Icon(Icons.add),
            label: Text(
              'Add Device',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final bool isFitbit = device['type'] == 'fitbit';
    final bool isManual = device['type'] == 'manual';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Device type badge
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: device['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getDeviceIcon(device['type']),
                  size: 16,
                  color: device['color'],
                ),
                const SizedBox(width: 8),
                Text(
                  device['model'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: device['color'],
                  ),
                ),
              ],
            ),
          ),
          
          // Device image
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: device['color'].withOpacity(0.05),
                      border: Border.all(
                        color: device['color'].withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  
                  // Dotted circle
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: CustomPaint(
                      painter: DottedCirclePainter(
                        color: device['color'].withOpacity(0.3),
                        dottedLength: 5,
                        space: 5,
                      ),
                    ),
                  ),
                  
                  // Device image
                  Hero(
                    tag: 'device_${device['name']}',
                    child: Image.asset(
                      device['image'],
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback images based on device type
                        String fallbackUrl = '';
                        if (isFitbit) {
                          fallbackUrl = 'https://www.fitbit.com/global/content/dam/fitbit/global/pdp/devices/sense-2/hero-static/black/sense2-black-device-3qt.png';
                        } else if (device['type'] == 'apple_watch') {
                          fallbackUrl = 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MKU93_VW_34FR+watch-45-alum-silver-nc-8s_VW_34FR_WF_CO?wid=1400&hei=1400&trim=1%2C0&fmt=p-jpg&qlt=95&.v=1683237043713';
                        } else if (device['type'] == 'scale') {
                          fallbackUrl = 'https://www.withings.com/us/en/body-cardio';
                        } else if (device['type'] == 'bp_monitor') {
                          fallbackUrl = 'https://omronhealthcare.com/wp-content/uploads/HEM-7322T-E-1.png';
                        } else if (isManual) {
                          return Icon(
                            Icons.edit_note,
                            size: 100,
                            color: device['color'],
                          );
                        }
                        
                        return Image.network(
                          fallbackUrl,
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              _getDeviceIcon(device['type']),
                              size: 100,
                              color: device['color'],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  
                  // Battery indicator
                  if (device['batteryLevel'] != null && !isManual)
                    Positioned(
                      bottom: 30,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              device['batteryLevel'] > 20 
                                  ? Icons.battery_full 
                                  : Icons.battery_alert,
                              size: 16,
                              color: device['batteryLevel'] > 20 
                                  ? Colors.green 
                                  : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${device['batteryLevel']}%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: device['batteryLevel'] > 20 
                                    ? Colors.green 
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Device name
          Text(
            device['name'],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Connection status and last synced
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Connection status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: device['isConnected'] 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      device['isConnected'] ? Icons.check_circle : Icons.error,
                      size: 16,
                      color: device['isConnected'] ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      device['isConnected'] ? 'Connected' : 'Disconnected',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: device['isConnected'] ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Last synced
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.sync,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTimeAgo(device['lastSynced']),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Metrics section
          if (device['metrics'] != null && device['metrics'].isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tracked Metrics',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (device['metrics'] as List).map<Widget>((metric) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: device['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getMetricIcon(metric),
                              size: 16,
                              color: device['color'],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatMetricName(metric),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: device['color'],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Custom painter for dotted circle
class DottedCirclePainter extends CustomPainter {
  final Color color;
  final double dottedLength;
  final double space;

  DottedCirclePainter({
    required this.color,
    required this.dottedLength,
    required this.space,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    final Path path = Path();

    for (double i = 0; i < 360; i += dottedLength + space) {
      final double startAngle = i * 3.14159 / 180;
      final double endAngle = (i + dottedLength) * 3.14159 / 180;

      path.addArc(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius),
        startAngle,
        endAngle - startAngle,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
