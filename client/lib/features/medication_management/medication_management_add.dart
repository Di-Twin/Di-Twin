import 'package:client/features/medication_management/medication_management_add_step2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class MedicationManagementAddPage extends StatefulWidget {
  const MedicationManagementAddPage({super.key});

  @override
  State<MedicationManagementAddPage> createState() =>
      _MedicationManagementAddPageState();
}

class _MedicationManagementAddPageState
    extends State<MedicationManagementAddPage>
    with TickerProviderStateMixin {
  File? _imageFile;
  bool _processingImage = false;
  String _scanStatus = 'SCANNING...';
  bool _cameraInitialized = false;

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Create pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animation
    _pulseController.repeat(reverse: true);

    // Request camera permission with a slight delay to ensure the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add a small delay to ensure the dialog appears after the screen is fully rendered
      Future.delayed(Duration(milliseconds: 500), () {
        _requestCameraPermission();
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    // First check the current status
    final status = await Permission.camera.status;

    if (status.isGranted) {
      // Permission already granted
      setState(() {
        _cameraInitialized = true;
      });
      return;
    }

    if (status.isPermanentlyDenied) {
      // User has permanently denied - need to direct them to settings
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: Text(
                  'Camera Permission Required',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Camera access is needed to scan your medications. Please enable it in your device settings.',
                  style: GoogleFonts.plusJakartaSans(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      openAppSettings();
                    },
                    child: Text(
                      'Open Settings',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF0F67FE),
                      ),
                    ),
                  ),
                ],
              ),
        );
      }
      return;
    }

    // If not permanently denied, request permission
    if (status.isDenied) {
      final result = await Permission.camera.request();

      if (result.isGranted) {
        setState(() {
          _cameraInitialized = true;
        });
      } else {
        // Show explanation dialog if permission not granted
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(
                    'Camera Permission Required',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    'Camera access is needed to scan your medications for AI identification.',
                    style: GoogleFonts.plusJakartaSans(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'OK',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF0F67FE),
                        ),
                      ),
                    ),
                  ],
                ),
          );
        }
      }
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final permissionStatus = await Permission.camera.status;

    if (!permissionStatus.isGranted) {
      // Show permission request dialog again if not granted
      await _requestCameraPermission();
      // Return early if permission not granted
      if (!(await Permission.camera.status).isGranted) {
        return;
      }
    }

    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _processingImage = true;
        });

        // Simulate AI processing
        await Future.delayed(const Duration(seconds: 3));

        setState(() {
          _processingImage = false;
        });

        // Navigate to next step with the scanned data
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicationPage()),
          );
        }
      }
    } catch (e) {
      print("Camera error: $e");
      setState(() {
        _processingImage = false;
        _scanStatus = 'Error: Could not access camera';
      });
    }
  }

  void _resetScan() {
    setState(() {
      _imageFile = null;
      _processingImage = false;
      _scanStatus = 'SCANNING...';
    });
  }

  void _navigateToManualSetup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMedicationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Stack(
          children: [
            // Display captured image or camera preview
            _imageFile != null
                ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(_imageFile!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                : Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black,
                  child: Center(
                    child:
                        _cameraInitialized
                            ? Icon(
                              Icons.camera_alt,
                              size: 80.sp,
                              color: Colors.white.withOpacity(0.3),
                            )
                            : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 60.sp,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Camera permission required',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16.sp,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                ElevatedButton(
                                  onPressed: _requestCameraPermission,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0F67FE),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Grant Permission',
                                    style: GoogleFonts.plusJakartaSans(),
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),

            // Scanning overlay
            if (_processingImage)
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withOpacity(0.5),
              ),

            // Scanning UI elements
            if (_processingImage)
              Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search,
                              size: 18.sp,
                              color: const Color(0xFF0F67FE),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _scanStatus,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F67FE),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Control buttons
            Positioned(
              bottom: 40.h,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Camera controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Update the left button (previously "Add manually button")
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.r),
                            onTap: _navigateToManualSetup,
                            child: Center(
                              child: Icon(
                                Icons
                                    .edit, // Changed from add to edit to better indicate manual entry
                                size: 30.sp,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 20.w),

                      // Capture button
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F67FE),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F67FE).withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16.r),
                            onTap: _takePicture,
                            child: Center(
                              child: Icon(
                                Icons.add,
                                size: 40.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 20.w),

                      // Reset button
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.r),
                            onTap: _resetScan,
                            child: Center(
                              child: Icon(
                                Icons.refresh,
                                size: 30.sp,
                                color: Colors.black,
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

            // Back button
            Positioned(
              top: 16.h,
              left: 16.w,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFE1E2E6)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18.sp,
                      color: const Color(0xFF1A202C),
                    ),
                  ),
                ),
              ),
            ),

            // Title
            Positioned(
              top: 16.h,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Scan Medication',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
