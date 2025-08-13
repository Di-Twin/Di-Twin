import 'dart:io';
import 'package:client/data/providers/user_profile_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:client/data/API/user_profile_data.dart';
import 'package:client/features/health_assessment/health_assessment_avatar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  DateTime selectedDate = DateTime.now();
  String dateDisplay = 'DD/MM/YYYY';
  File? _profileImage;
  bool isLoading = true;
  bool isSaving = false;
  bool isLoadingLocation = false;
  String? errorMessage;

  // User data
  UserData? userData;

  // User provider instance
  final UserProvider _userProvider = UserProvider();

  // Location controller (new)
  final TextEditingController locationController = TextEditingController();

  // Controllers for editable fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Track which fields are in edit mode
  Map<String, bool> editModeMap = {
    'firstName': false,
    'lastName': false,
    'email': false,
    'dob': false,
    'location': false,
  };

  // Track if any field has been modified
  bool get isAnyFieldModified {
    if (userData == null) return false;

    return firstNameController.text != userData!.firstName ||
        lastNameController.text != userData!.lastName ||
        (userData!.dob != null && selectedDate != userData!.dob) ||
        locationController.text != (userData!.location ?? '');
  }

  // Add a method to update the AvatarData when profile image changes
  void _updateAvatarData() {
    if (_profileImage != null) {
      AvatarData.uploadedImage = _profileImage;
      AvatarData.isCustomImage = true;
      AvatarData.saveAvatarData();
      print('✅ Updated avatar data with custom image');
    }
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationDialog('Location services are disabled. Please enable location services.');
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationDialog('Location permissions are denied. Please grant location permission.');
          setState(() {
            isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationDialog('Location permissions are permanently denied. Please enable them in settings.');
        setState(() {
          isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '';

        if (place.locality != null && place.locality!.isNotEmpty) {
          address += place.locality!;
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }
        if (place.country != null && place.country!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.country!;
        }

        setState(() {
          locationController.text = address.isNotEmpty ? address : 'Location detected';
          isLoadingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location detected: $address'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoadingLocation = false;
      });

      String errorMsg = 'Failed to get location';
      if (e.toString().contains('timeout')) {
        errorMsg = 'Location request timed out. Please try again.';
      } else if (e.toString().contains('network')) {
        errorMsg = 'Network error. Please check your connection.';
      }

      _showLocationDialog(errorMsg);
    }
  }

  void _showLocationDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.location_off,
                color: Colors.orange.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text('Location Access'),
            ],
          ),
          content: Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Modify the _pickImage method to update AvatarData
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      // Update AvatarData with the new image
      _updateAvatarData();
    }
  }

  // In initState, add code to load the avatar from AvatarData
  @override
  void initState() {
    super.initState();
    _fetchUserData();

    // Load avatar from AvatarData
    if (AvatarData.isCustomImage && AvatarData.uploadedImage != null) {
      setState(() {
        _profileImage = AvatarData.uploadedImage;
      });
      print('✅ Loaded avatar from AvatarData');
    }
  }

  // Fetch user data from API
  Future<void> _fetchUserData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final userResponse = await _userProvider.getUser();

      setState(() {
        userData = userResponse.data;
        isLoading = false;

        // Update controllers with fetched data
        firstNameController.text = userData?.firstName ?? '';
        lastNameController.text = userData?.lastName ?? '';
        emailController.text = userData?.email ?? '';
        phoneController.text = userData?.mobileNumber ?? '';
        locationController.text = userData?.location ?? '';

        // Update date if available
        if (userData?.dob != null) {
          selectedDate = userData!.dob!;
          dateDisplay = '${selectedDate.day.toString().padLeft(2, '0')}/'
              '${selectedDate.month.toString().padLeft(2, '0')}/'
              '${selectedDate.year}';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load user data: $e';
      });
      debugPrint('Error loading user data: $e');
    }
  }

  // Show improved image source selection bottom sheet
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
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
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Update Profile Picture',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),

              const Divider(height: 1),

              // Current profile preview
              if (_profileImage != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _profileImage!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Current profile picture',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            _profileImage = null;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),

              // Options
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.blue),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Select a photo from your gallery',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),

              const SizedBox(height: 8),

              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.green),
                ),
                title: Text(
                  'Take a Photo',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Capture a new photo with camera',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),

              const SizedBox(height: 16),

              // Cancel button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      'Select Date',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          dateDisplay =
                          '${selectedDate.day.toString().padLeft(2, '0')}/'
                              '${selectedDate.month.toString().padLeft(2, '0')}/'
                              '${selectedDate.year}';
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Done',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate,
                    maximumDate: DateTime.now(),
                    minimumYear: 1900,
                    maximumYear: DateTime.now().year,
                    onDateTimeChanged: (DateTime newDate) {
                      selectedDate = newDate;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleEditMode(String field) {
    setState(() {
      editModeMap[field] = !editModeMap[field]!;
    });
  }

  // Method to update user data
  Future<void> _saveUserData() async {
    // Check if any data has been modified
    if (!isAnyFieldModified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No changes to save',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.grey.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final updatedUser = await _userProvider.updateUser(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        dob: selectedDate,
        location: locationController.text.isNotEmpty ? locationController.text : null,
        // We're not modifying the user plan in this interface
      );

      setState(() {
        userData = updatedUser.data;
        isSaving = false;
      });

      // Reset all edit modes
      setState(() {
        editModeMap.forEach((key, value) {
          editModeMap[key] = false;
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Profile updated successfully',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to update profile: ${e.toString()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      debugPrint('Error updating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Modern gradient header background
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top navigation with improved styling
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal Information',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your profile details',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Profile picture with enhanced design
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            image: _profileImage != null
                                ? DecorationImage(
                              image: FileImage(_profileImage!),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: _profileImage == null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: AvatarData.getCurrentAvatarWidget(
                              width: 130,
                              height: 130,
                              borderRadius: 24,
                            ),
                          )
                              : null,
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Form fields with improved spacing
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: isLoading
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF667EEA),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading your information...',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                        : errorMessage != null
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.red.shade200,
                              ),
                            ),
                            child: Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red.shade400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading data',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              errorMessage!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _fetchUserData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667EEA),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('First Name'),
                          _buildEditableField(
                            icon: Icons.person_outline,
                            controller: firstNameController,
                            isEditing: editModeMap['firstName']!,
                            onEditPressed: () => _toggleEditMode('firstName'),
                          ),
                          const SizedBox(height: 24),

                          _buildSectionTitle('Last Name'),
                          _buildEditableField(
                            icon: Icons.person_outline,
                            controller: lastNameController,
                            isEditing: editModeMap['lastName']!,
                            onEditPressed: () => _toggleEditMode('lastName'),
                          ),
                          const SizedBox(height: 24),

                          _buildSectionTitle('Email Address'),
                          _buildInfoField(
                            icon: Icons.alternate_email,
                            value: emailController.text,
                            editable: false,
                            isLocked: true,
                          ),
                          const SizedBox(height: 24),

                          _buildSectionTitle('Phone Number'),
                          _buildInfoField(
                            icon: Icons.phone_iphone,
                            value: phoneController.text,
                            editable: false,
                            isGrayed: true,
                          ),
                          const SizedBox(height: 24),

                          _buildSectionTitle('Date of Birth'),
                          _buildInfoField(
                            icon: Icons.calendar_today,
                            value: dateDisplay,
                            editable: true,
                            onTap: _showDatePicker,
                          ),

                          const SizedBox(height: 24),
                          _buildSectionTitle('Location'),
                          _buildLocationField(),

                          if (userData != null && userData!.userPlan != null) ...[
                            const SizedBox(height: 24),
                            _buildSectionTitle('Plan'),
                            _buildInfoField(
                              icon: Icons.workspace_premium,
                              value: userData!.userPlan!,
                              editable: false,
                              isPlan: true,
                            ),
                          ],

                          const SizedBox(height: 48),

                          // Enhanced save button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: isSaving ? null : _saveUserData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.save_outlined, size: 20),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Save Changes',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E293B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String value,
    required bool editable,
    bool isGrayed = false,
    bool isLocked = false,
    bool isPlan = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: editable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPlan
                ? const Color(0xFF667EEA).withOpacity(0.3)
                : const Color(0xFFE2E8F0),
            width: isPlan ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPlan
                    ? const Color(0xFF667EEA).withOpacity(0.1)
                    : isGrayed
                    ? Colors.grey.shade100
                    : const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isPlan
                    ? const Color(0xFF667EEA)
                    : isGrayed
                    ? Colors.grey.shade500
                    : const Color(0xFF667EEA),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value.isEmpty || value == 'DD/MM/YYYY' ? 'Not provided' : value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: isGrayed
                          ? Colors.grey.shade500
                          : (value.isEmpty || value == 'DD/MM/YYYY' || value == 'Not provided'
                          ? Colors.grey.shade400
                          : const Color(0xFF1E293B)),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isPlan) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Current subscription plan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF667EEA),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isLocked)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: Colors.grey.shade500,
                  size: 16,
                ),
              )
            else if (editable)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF667EEA),
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required IconData icon,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEditPressed,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isEditing) {
          onEditPressed();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEditing
                ? const Color(0xFF667EEA)
                : const Color(0xFFE2E8F0),
            width: isEditing ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF667EEA),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: isEditing
                  ? TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Enter ${icon == Icons.person_outline ? 'name' : 'information'}',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                autofocus: true,
              )
                  : Text(
                controller.text.isEmpty
                    ? 'Not provided'
                    : controller.text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: controller.text.isEmpty
                      ? Colors.grey.shade400
                      : const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: onEditPressed,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isEditing
                      ? Colors.green.withOpacity(0.1)
                      : const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isEditing ? Icons.check : Icons.edit_outlined,
                  color: isEditing ? Colors.green : const Color(0xFF667EEA),
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return GestureDetector(
      onTap: () {
        if (!editModeMap['location']!) {
          _toggleEditMode('location');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: editModeMap['location']!
                ? const Color(0xFF667EEA)
                : const Color(0xFFE2E8F0),
            width: editModeMap['location']! ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF667EEA),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: editModeMap['location']!
                  ? TextField(
                controller: locationController,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Enter your location',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                autofocus: true,
              )
                  : Text(
                locationController.text.isEmpty
                    ? 'Not provided'
                    : locationController.text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: locationController.text.isEmpty
                      ? Colors.grey.shade400
                      : const Color(0xFF1E293B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isLoadingLocation)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
                ),
              )
            else ...[
              GestureDetector(
                onTap: _getCurrentLocation,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _toggleEditMode('location'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: editModeMap['location']!
                        ? Colors.green.withOpacity(0.1)
                        : const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    editModeMap['location']! ? Icons.check : Icons.edit_outlined,
                    color: editModeMap['location']! ? Colors.green : const Color(0xFF667EEA),
                    size: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    super.dispose();
  }
}