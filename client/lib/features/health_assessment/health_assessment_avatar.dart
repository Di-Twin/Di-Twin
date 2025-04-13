import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer; // Import developer for better logging

import 'package:client/widgets/CustomButton.dart';

// Class to store avatar data that can be shared across the app
class AvatarData {
  static File? uploadedImage;
  static String? selectedAvatarUrl;
  static bool isCustomImage = false;

  // Save avatar data to shared preferences
  static Future<void> saveAvatarData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save selected avatar URL if custom image is not used
    if (!isCustomImage && selectedAvatarUrl != null) {
      await prefs.setString('selectedAvatarUrl', selectedAvatarUrl!);
      await prefs.setBool('isCustomImage', false);
      
      // Debug print
      developer.log('Saved predefined avatar: $selectedAvatarUrl', name: 'AvatarData');
    } 
    // For custom images, save the path
    else if (isCustomImage && uploadedImage != null) {
      await prefs.setString('uploadedImagePath', uploadedImage!.path);
      await prefs.setBool('isCustomImage', true);
      
      // Debug print
      developer.log('Saved custom image path: ${uploadedImage!.path}', name: 'AvatarData');
    }
  }

  // Load avatar data from shared preferences
  static Future<void> loadAvatarData() async {
    final prefs = await SharedPreferences.getInstance();
    
    isCustomImage = prefs.getBool('isCustomImage') ?? false;
    
    if (isCustomImage) {
      String? path = prefs.getString('uploadedImagePath');
      if (path != null) {
        uploadedImage = File(path);
        developer.log('Loaded custom image: $path', name: 'AvatarData');
      }
    } else {
      selectedAvatarUrl = prefs.getString('selectedAvatarUrl');
      developer.log('Loaded predefined avatar: $selectedAvatarUrl', name: 'AvatarData');
    }
  }
  
  // Get the current avatar widget for use in other components
  static Widget getCurrentAvatarWidget({
    double? width, 
    double? height, 
    double? borderRadius,
  }) {
    width = width ?? 100;
    height = height ?? 100;
    borderRadius = borderRadius ?? 20;
    
    // Print current avatar info
    if (isCustomImage && uploadedImage != null) {
      developer.log('Displaying custom image: ${uploadedImage!.path}', name: 'AvatarData');
    } else if (selectedAvatarUrl != null) {
      developer.log('Displaying predefined avatar: $selectedAvatarUrl', name: 'AvatarData');
    } else {
      developer.log('No avatar selected, displaying default', name: 'AvatarData');
    }
    
    if (isCustomImage && uploadedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.file(
          uploadedImage!,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );
    } else if (selectedAvatarUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SvgPicture.network(
          selectedAvatarUrl!,
          width: width,
          height: height,
          placeholderBuilder: (context) => Center(
            child: SizedBox(
              width: width! * 0.3,
              height: height! * 0.3,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
          fit: BoxFit.cover,
        ),
      );
    } else {
      // Default avatar if nothing is selected
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(
            Icons.person,
            size: width * 0.6,
            color: Colors.grey[600],
          ),
        ),
      );
    }
  }
  
  // Get current avatar info for debug purposes
  static String getAvatarInfo() {
    if (isCustomImage && uploadedImage != null) {
      return "Custom Image: ${uploadedImage!.path.split('/').last}";
    } else if (selectedAvatarUrl != null) {
      // Extract seed from URL
      final RegExp regExp = RegExp(r'seed=([^&]+)');
      final match = regExp.firstMatch(selectedAvatarUrl!);
      final seed = match?.group(1) ?? "Unknown";
      return "Predefined Avatar: $seed";
    } else {
      return "No avatar selected";
    }
  }
}

class HealthAssessmentAvatar extends StatefulWidget {
  const HealthAssessmentAvatar({super.key});

  @override
  State<HealthAssessmentAvatar> createState() => _HealthAssessmentAvatarState();
}

class _HealthAssessmentAvatarState extends State<HealthAssessmentAvatar> {
  int selectedAvatarIndex = 0; // Default selected avatar
  bool isLoadingImage = false;
  PageController _pageController = PageController(
    viewportFraction: 0.5, // Reduced from 0.6 to show more avatars with less space
    initialPage: 0,
  );

  // Generate avatars using DiceBear API
  final List<String> avatars = List.generate(
    9,
    (index) =>
        'https://api.dicebear.com/9.x/identicon/svg?seed=User${index + 1}',
  );

  @override
  void initState() {
    super.initState();
    _loadSavedAvatarData();
    
    // Initialize page controller with initial page
    _pageController = PageController(
      viewportFraction: 0.5, // Reduced from 0.6 to show more avatars with less space
      initialPage: selectedAvatarIndex,
    );
  }

  // Load any previously saved avatar data
  Future<void> _loadSavedAvatarData() async {
    await AvatarData.loadAvatarData();
    
    if (AvatarData.isCustomImage && AvatarData.uploadedImage != null) {
      setState(() {
        // If we have a saved custom image
        _selectedImage = AvatarData.uploadedImage;
        developer.log('Restored custom image: ${AvatarData.uploadedImage!.path}', name: 'HealthAssessmentAvatar');
      });
    } else if (!AvatarData.isCustomImage && AvatarData.selectedAvatarUrl != null) {
      // If we have a saved avatar URL
      int index = avatars.indexOf(AvatarData.selectedAvatarUrl!);
      if (index != -1) {
        setState(() {
          selectedAvatarIndex = index;
          developer.log('Restored avatar index: $index (${avatars[index]})', name: 'HealthAssessmentAvatar');
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    }
  }

  File? get _selectedImage => AvatarData.uploadedImage;
  set _selectedImage(File? image) {
    AvatarData.uploadedImage = image;
    if (image != null) {
      AvatarData.isCustomImage = true;
      developer.log('Set custom image: ${image.path}', name: 'HealthAssessmentAvatar');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Request runtime permission and pick image
  Future<void> _pickImage() async {
    Map<Permission, PermissionStatus> statuses =
        await [
          Permission.photos,
          Permission.mediaLibrary, // For Android 13+
        ].request();

    if ((statuses[Permission.photos] != null &&
            statuses[Permission.photos]!.isGranted) ||
        (statuses[Permission.mediaLibrary] != null &&
            statuses[Permission.mediaLibrary]!.isGranted)) {
      setState(() {
        isLoadingImage = true;
      });
      
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Reduce size for performance
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          isLoadingImage = false;
          developer.log('Picked custom image: ${pickedFile.path}', name: 'HealthAssessmentAvatar');
        });
      } else {
        setState(() {
          isLoadingImage = false;
          developer.log('User canceled image picking', name: 'HealthAssessmentAvatar');
        });
      }
    } else {
      developer.log('Permission denied for image picking', name: 'HealthAssessmentAvatar');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permission denied! Please allow access."),
        ),
      );
    }
  }

  // Save the current avatar selection
  void _saveSelectedAvatar() async {
    String debugInfo = "";
    
    if (_selectedImage != null) {
      // Custom image is already set in the setter
      AvatarData.isCustomImage = true;
      debugInfo = "Custom image: ${_selectedImage!.path.split('/').last}";
    } else {
      // Use predefined avatar
      AvatarData.isCustomImage = false;
      AvatarData.selectedAvatarUrl = avatars[selectedAvatarIndex];
      debugInfo = "Predefined avatar: User${selectedAvatarIndex + 1}";
    }
    
    // Save the data to persistent storage
    await AvatarData.saveAvatarData();
    
    // Show debug info in a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Selected $debugInfo"),
        duration: Duration(seconds: 2),
      ),
    );
    
    // Navigate to dashboard
    developer.log('Navigation to dashboard with avatar: $debugInfo', name: 'HealthAssessmentAvatar');
    Navigator.pushNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                // Top Navigation Bar
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade900),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                        iconSize: 24.sp,
                        padding: EdgeInsets.all(4.r),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        'Select Avatar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20.h), // Reduced spacing

                // Display current selection information for debugging
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      _selectedImage != null 
                          ? "Selected: Custom Image" 
                          : "Selected: Avatar ${selectedAvatarIndex + 1}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10.h),

                // Avatar Carousel with reduced space between items
                SizedBox(
                  height: 180.h, // Slightly reduced height
                  child: _selectedImage != null
                      ? Center(
                          child: _buildSelectedAvatar(),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: avatars.length,
                          onPageChanged: (index) {
                            setState(() {
                              selectedAvatarIndex = index;
                              // Log selection change
                              developer.log('Changed to avatar index: $index (${avatars[index]})', name: 'HealthAssessmentAvatar');
                              
                              // Update the AvatarData when avatar changes
                              AvatarData.selectedAvatarUrl = avatars[index];
                              AvatarData.isCustomImage = false;
                            });
                          },
                          itemBuilder: (context, index) {
                            bool isSelected = index == selectedAvatarIndex;
                            double scale = isSelected ? 1.0 : 0.8;
                            
                            return TweenAnimationBuilder(
                              tween: Tween<double>(begin: scale, end: scale),
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutQuint,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: _buildAvatar(index),
                                );
                              },
                            );
                          },
                        ),
                ),

                SizedBox(height: 16.h), // Reduced spacing

                Center(
                  child: Column(
                    children: [
                      Text(
                        'Select Avatar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'We have 9 premade avatars for your\nconvenience. Kindly choose one of them!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 24.h), // Reduced spacing

                      // Image Upload
                      GestureDetector(
                        onTap: _pickImage,
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: Radius.circular(20.r),
                          dashPattern: [8, 4],
                          color: const Color(0xFF0066FF),
                          strokeWidth: 2,
                          child: Container(
                            width: 120.w,
                            height: 120.h,
                            alignment: Alignment.center,
                            child: isLoadingImage
                                ? CircularProgressIndicator()
                                : Icon(
                                    Icons.upload_file,
                                    size: 32.sp,
                                    color: const Color(0xFF0066FF),
                                  ),
                          ),
                        ),
                      ),

                      SizedBox(height: 8.h),
                      Text(
                        'Or Upload your image',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 8.h),
                      Text(
                        'Max size: 5MB, Format: JPG, PNG',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 20.h), // Reduced spacing
                    ],
                  ),
                ),

                SizedBox(height: 16.h), // Reduced spacing

                CustomButton(
                  text: "Continue",
                  iconPath: 'images/SignInAddIcon.png',
                  onPressed: _saveSelectedAvatar, // Save avatar and navigate
                ),

                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build Avatar Widget for the PageView
  Widget _buildAvatar(int index) {
    bool isSelected = index == selectedAvatarIndex;
    
    return Center(
      child: Container(
        width: isSelected ? 160.w : 130.w,
        height: isSelected ? 160.h : 130.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.r),
          border: isSelected
              ? Border.all(
                  color: const Color(0xFF0066FF),
                  width: 4.w,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: SvgPicture.network(
            avatars[index],
            placeholderBuilder: (context) => Center(
              child: SizedBox(
                width: 30.w,
                height: 30.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                ),
              ),
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // Separate method for selected avatar (with polygon)
  Widget _buildSelectedAvatar() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 160.w,
            height: 160.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(
                color: const Color(0xFF0066FF),
                width: 4.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    )
                  : SvgPicture.network(
                      avatars[selectedAvatarIndex],
                      placeholderBuilder: (context) => Center(
                        child: SizedBox(
                          width: 30.w,
                          height: 30.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                          ),
                        ),
                      ),
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          // Always show the polygon indicator for the selected avatar
          Positioned(
            top: -45,
            child: Image.asset(
              'images/polygon.png',
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }
}