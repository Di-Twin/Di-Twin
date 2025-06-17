import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/wearable_integration/fitbit_appauth_service.dart';
import 'package:intl/intl.dart';

class FitbitConnectionDrawer extends StatefulWidget {
  final VoidCallback onClose;

  const FitbitConnectionDrawer({super.key, required this.onClose});

  @override
  _FitbitConnectionDrawerState createState() => _FitbitConnectionDrawerState();
}

class _FitbitConnectionDrawerState extends State<FitbitConnectionDrawer> {
  final FitbitAppAuthService _fitbitService = FitbitAppAuthService();
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
  }

  Future<void> _checkConnectionStatus() async {
    final isConnected = await _fitbitService.isAuthenticated();
    
    if (isConnected) {
      final lastSyncTime = await _fitbitService.getLastSyncTime();
      
      setState(() {
        _isConnected = true;
        _lastSyncTime = lastSyncTime;
      });
    }
  }

  Future<void> _connectFitbit() async {
    setState(() {
      _isConnecting = true;
    });
    
    try {
      final success = await _fitbitService.authenticate(context);
      
      if (success) {
        final lastSyncTime = await _fitbitService.getLastSyncTime();
        
        setState(() {
          _isConnected = true;
          _lastSyncTime = lastSyncTime;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully connected to Fitbit'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to connect to Fitbit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error connecting to Fitbit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
    });
    
    try {
      final data = await _fitbitService.syncDailyData();
      
      if (data['success'] == true) {
        final lastSyncTime = await _fitbitService.getLastSyncTime();
        
        setState(() {
          _lastSyncTime = lastSyncTime;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully synced Fitbit data'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to sync Fitbit data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error syncing Fitbit data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _initialSync() async {
    setState(() {
      _isSyncing = true;
    });
    
    try {
      final data = await _fitbitService.initialSync();
      
      if (data['success'] == true) {
        final lastSyncTime = await _fitbitService.getLastSyncTime();
        
        setState(() {
          _lastSyncTime = lastSyncTime;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully performed initial sync'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to perform initial sync'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during initial sync: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _disconnect() async {
    setState(() {
      _isConnecting = true;
    });
    
    try {
      final success = await _fitbitService.disconnect();
      
      if (success) {
        setState(() {
          _isConnected = false;
          _lastSyncTime = null;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully disconnected from Fitbit'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to disconnect from Fitbit'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error disconnecting from Fitbit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle bar
        Center(
          child: Container(
            margin: EdgeInsets.only(top: 8.h),
            width: 32.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),

        // Header
        Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              // Illustration
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5FF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.watch,
                      size: 24.sp,
                      color: const Color(0xFF0F67FE),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 16.w),

              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isConnected ? 'Fitbit Connected' : 'Connect Your Fitbit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _isConnected
                          ? 'Manage your Fitbit connection'
                          : 'Sync your health data automatically',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Close button
              IconButton(
                onPressed: widget.onClose,
                icon: Icon(
                  Icons.close,
                  color: const Color(0xFF64748B),
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ),

        // Connected state
        if (_isConnected) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF5FF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF0F67FE),
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fitbit Account Connected',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        if (_lastSyncTime != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            'Last sync: ${DateFormat.yMMMd().add_jm().format(_lastSyncTime!)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Sync button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSyncing ? null : _syncData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F67FE),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: _isSyncing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Syncing...',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Sync Now',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),

          // Initial sync button (for new connections)
          if (_lastSyncTime == null) ...[
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSyncing ? null : _initialSync,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F67FE),
                    side: const BorderSide(color: Color(0xFF0F67FE)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isSyncing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  const Color(0xFF0F67FE),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Syncing...',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Initial Sync (30 days)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
          
          SizedBox(height: 16.h),
          
          // Disconnect button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isConnecting ? null : _disconnect,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isConnecting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Disconnecting...',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Disconnect Fitbit',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ] else ...[
          // Connect button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isConnecting ? null : _connectFitbit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F67FE),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: _isConnecting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Connecting...',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Connect Fitbit',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: Text(
              'Connecting your Fitbit account will allow the app to automatically sync your activity, sleep, heart rate, and other health data.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Manual entry option
          SizedBox(height: 24.h),
          
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: Text(
              'Other Options',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Manual entry button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                child: InkWell(
                  onTap: () {
                    widget.onClose();
                    // Trigger manual entry on parent widget
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: Row(
                      children: [
                        // Icon container
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6700).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: const Color(0xFFFF6700),
                            size: 20.sp,
                          ),
                        ),

                        SizedBox(width: 12.w),

                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Manual Entry',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Enter your health metrics manually',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Arrow icon
                        Icon(
                          Icons.arrow_forward_ios,
                          color: const Color(0xFF64748B),
                          size: 14.sp,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        
        // Bottom note
        const Spacer(),
        
        Padding(
          padding: EdgeInsets.all(16.r),
          child: Center(
            child: Text(
              'You can change your device connection any time in settings',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}