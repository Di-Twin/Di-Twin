import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/wearable_integration/fitbit_appauth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FitbitConnectionDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback? onFitbitConnect;
  final VoidCallback? onManualEntry;
  final ScrollController? scrollController;

  const FitbitConnectionDrawer({
    super.key,
    required this.onClose,
    this.onFitbitConnect,
    this.onManualEntry,
    this.scrollController,
  });

  @override
  _FitbitConnectionDrawerState createState() => _FitbitConnectionDrawerState();
}

class _FitbitConnectionDrawerState extends State<FitbitConnectionDrawer>
    with TickerProviderStateMixin {
  final FitbitAppAuthService _fitbitService = FitbitAppAuthService();
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  bool _hasInitialSync = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectionStatus() async {
    final isConnected = await _fitbitService.isAuthenticated();
    final lastSyncTime = await _fitbitService.getLastSyncTime();
    final hasInitialSync = await _fitbitService.hasCompletedInitialSync();

    setState(() {
      _isConnected = isConnected;
      _lastSyncTime = lastSyncTime;
      _hasInitialSync = hasInitialSync;
    });
  }

  Future<void> _connectFitbit() async {
    if (widget.onFitbitConnect != null) {
      widget.onFitbitConnect!();
    } else {
      // Fallback implementation
      setState(() {
        _isConnecting = true;
      });

      try {
        final success = await _fitbitService.authenticate(context);

        if (success) {
          // Set cache to true so drawer won't show again
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('fitbit_connection_completed', true);
          await prefs.setBool('watch_connected', true);
          await prefs.setString('watch_type', 'Fitbit');

          setState(() {
            _isConnected = true;
          });

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Please complete authorization in your browser',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                margin: EdgeInsets.all(16.r),
                duration: Duration(seconds: 5),
              ),
            );
          }

          // Close drawer after short delay
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            widget.onClose();
          }
        } else {
          throw Exception('Authentication failed');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Failed to connect to Fitbit. Please try again.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.all(16.r),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isConnecting = false;
          });
        }
      }
    }
  }

  Future<void> _selectManualEntry() async {
    if (widget.onManualEntry != null) {
      widget.onManualEntry!();
    } else {
      // Fallback implementation
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('fitbit_connection_completed', true);
      await prefs.setBool('watch_connected', true);
      await prefs.setString('watch_type', 'Manual');

      widget.onClose();
    }
  }

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      final result = await _fitbitService.syncDailyData();

      if (result['success'] == true) {
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
            content: Text(result['message'] ?? 'Failed to sync Fitbit data'),
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
      final result = await _fitbitService.initialSync();

      if (result['success'] == true) {
        await _fitbitService.markInitialSyncCompleted();
        final lastSyncTime = await _fitbitService.getLastSyncTime();

        setState(() {
          _lastSyncTime = lastSyncTime;
          _hasInitialSync = true;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully performed initial sync (30 days)'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to perform initial sync'),
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
        // Update local state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('watch_connected', false);
        await prefs.remove('watch_type');
        await prefs.setBool('fitbit_connection_completed', false);

        setState(() {
          _isConnected = false;
          _lastSyncTime = null;
          _hasInitialSync = false;
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                controller: widget.scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),

                    // Header Section
                    Padding(
                      padding: EdgeInsets.fromLTRB(24.r, 16.r, 24.r, 8.r),
                      child: Column(
                        children: [
                          // Illustration
                          Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF0F67FE).withOpacity(0.1),
                                  const Color(0xFF00B0B9).withOpacity(0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 50.w,
                                height: 50.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF0F67FE).withOpacity(0.2),
                                      blurRadius: 12,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.watch,
                                  size: 28.sp,
                                  color: const Color(0xFF0F67FE),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 20.h),

                          // Title
                          Text(
                            _isConnected ? 'Fitbit Connected' : 'Connect Your Health Device',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 8.h),

                          // Subtitle
                          Text(
                            _isConnected
                                ? 'Manage your Fitbit connection and sync data'
                                : 'Get personalized insights by connecting your Fitbit or track manually',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Connected state or Connection Options
                    if (_isConnected) ...[
                      // Connected state UI
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.r),
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
                                        'Last sync: ${_lastSyncTime!.day}/${_lastSyncTime!.month}/${_lastSyncTime!.year}',
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
                        padding: EdgeInsets.symmetric(horizontal: 24.r),
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
                      if (!_hasInitialSync) ...[
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.r),
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
                              child: Text(
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
                        padding: EdgeInsets.symmetric(horizontal: 24.r),
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
                            child: Text(
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
                      // Connection Options
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.r),
                        child: Column(
                          children: [
                            // Fitbit Connection Option
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF0F67FE),
                                    const Color(0xFF00B0B9),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F67FE).withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16.r),
                                child: InkWell(
                                  onTap: _isConnecting ? null : _connectFitbit,
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Padding(
                                    padding: EdgeInsets.all(20.r),
                                    child: Row(
                                      children: [
                                        // Fitbit Icon
                                        Container(
                                          width: 48.w,
                                          height: 48.w,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          child: _isConnecting
                                              ? Center(
                                            child: SizedBox(
                                              width: 24.w,
                                              height: 24.w,
                                              child: const CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                              : Icon(
                                            Icons.watch,
                                            color: Colors.white,
                                            size: 24.sp,
                                          ),
                                        ),

                                        SizedBox(width: 16.w),

                                        // Text Content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _isConnecting
                                                    ? 'Connecting to Fitbit...'
                                                    : 'Connect Fitbit',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                _isConnecting
                                                    ? 'Please wait while we connect your device'
                                                    : 'Automatically sync your health data',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white.withOpacity(0.8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Arrow Icon
                                        if (!_isConnecting)
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white.withOpacity(0.8),
                                            size: 16.sp,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Manual Entry Option
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16.r),
                                child: InkWell(
                                  onTap: _isConnecting ? null : _selectManualEntry,
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Padding(
                                    padding: EdgeInsets.all(20.r),
                                    child: Row(
                                      children: [
                                        // Manual Icon
                                        Container(
                                          width: 48.w,
                                          height: 48.w,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF6700).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          child: Icon(
                                            Icons.edit_outlined,
                                            color: const Color(0xFFFF6700),
                                            size: 24.sp,
                                          ),
                                        ),

                                        SizedBox(width: 16.w),

                                        // Text Content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Manual Entry',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF1E293B),
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                'Enter your health metrics manually',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Arrow Icon
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: const Color(0xFF64748B),
                                          size: 16.sp,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Benefits Section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.r),
                        child: Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: const Color(0xFFBAE6FD),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: const Color(0xFF0369A1),
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Why connect your device?',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0369A1),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '• Get personalized health insights\n• Track progress automatically\n• Receive smart recommendations\n• Monitor trends over time',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF0369A1),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
