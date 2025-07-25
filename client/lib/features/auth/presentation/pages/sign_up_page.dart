import 'package:client/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:client/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ditwin_country_code/ditwin_country_code.dart';
import 'package:client/widgets/CustomTextField.dart';
import 'package:client/features/auth/presentation/providers/auth_provider.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String countryCode = "+91"; // Default country code
  bool isRetrying = false;

  bool _validateFields() {
    if (firstNameController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter your first name");
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter your last name");
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter a valid email address");
      return false;
    }
    if (!RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(emailController.text.trim())) {
      _showErrorSnackBar("Please enter a valid email address");
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter a password");
      return false;
    }
    if (passwordController.text.trim().length < 6) {
      _showErrorSnackBar("Password must be at least 6 characters");
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter a valid phone number");
      return false;
    }
    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action:
        message.contains("server is temporarily unavailable")
            ? SnackBarAction(
          label: "Retry",
          textColor: Colors.white,
          onPressed: () {
            handleSignUp(isRetry: true);
          },
        )
            : null,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void handleSignUp({bool isRetry = false}) async {
    if (!_validateFields()) return;

    // Set retrying state if this is a retry attempt
    setState(() {
      isRetrying = isRetry;
    });

    // Update providers
    ref.read(emailProvider.notifier).state = emailController.text.trim();
    ref.read(passwordProvider.notifier).state = passwordController.text.trim();
    ref.read(firstNameProvider.notifier).state =
        firstNameController.text.trim();
    ref.read(lastNameProvider.notifier).state = lastNameController.text.trim();
    ref.read(phoneProvider.notifier).state = phoneController.text.trim();
    ref.read(loadingProvider.notifier).state = true;

    final fullPhone = "$countryCode${phoneController.text.trim()}";
    final email = emailController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final password = passwordController.text.trim();

    try {
      // Get the use case
      final initiateEmailSignupUseCase = ref.read(
        initiateEmailSignupUseCaseProvider,
      );

      // Execute the use case - make exactly ONE attempt
      final result = await initiateEmailSignupUseCase.execute(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        mobileNumber: fullPhone,
      );

      ref.read(loadingProvider.notifier).state = false;
      setState(() {
        isRetrying = false;
      });

      print("📊 Signup result: $result");

      if (result["userExists"] == true) {
        if (mounted) {
          _showErrorSnackBar("User already exists. Please sign in instead.");
        }
      } else if (result["success"] == true) {
        // Extract token from the nested data structure if it exists
        String token = "";
        if (result.containsKey("data") && result["data"] is Map) {
          token = (result["data"] as Map)["token"] ?? "";
        } else if (result.containsKey("token")) {
          token = result["token"] ?? "";
        }

        print("🔑 Extracted token: $token");

        if (token.isEmpty) {
          _showErrorSnackBar(
            "Failed to get verification token. Please try again.",
          );
          return;
        }

        // Show success message
        if (mounted) {
          _showSuccessSnackBar("OTP sent successfully to your email!");

          // Navigate to OTP screen with the token
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => OtpVerificationPage(
                email: email,
                firstName: firstName,
                lastName: lastName,
                isEmailFlow: true,
                signupToken: token, // Pass the token directly
              ),
            ),
          );
        }
      } else if (result["error"] == "server_unavailable") {
        if (mounted) {
          _showErrorSnackBar(
            "The server is temporarily unavailable. Please try again in a few minutes.",
          );
        }
      } else if (result["error"] == "empty_response") {
        if (mounted) {
          _showErrorSnackBar(
            "The server returned an empty response. Please try again.",
          );
        }
      } else {
        if (mounted) {
          _showErrorSnackBar(
            result["message"] ?? "Failed to send OTP. Please try again.",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        // Clean up the error message
        if (errorMessage.contains(
          "Exception: Email Signup Error: Exception:",
        )) {
          errorMessage = errorMessage.replaceAll(
            "Exception: Email Signup Error: Exception:",
            "",
          );
        }
        _showErrorSnackBar(errorMessage);
        ref.read(loadingProvider.notifier).state = false;
        setState(() {
          isRetrying = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enhanced Header Section
                        Container(
                          height: 0.32.sh, // Slightly reduced height
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1A2B50), Color(0xFF0F67FE)],
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30.r),
                              bottomRight: Radius.circular(30.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Decorative elements
                              Positioned(
                                top: -20.h,
                                right: -20.w,
                                child: Container(
                                  height: 120.h,
                                  width: 120.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 20.h,
                                left: -30.w,
                                child: Container(
                                  height: 100.h,
                                  width: 100.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 40.h,
                                left: 20.w,
                                child: Container(
                                  height: 30.h,
                                  width: 30.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              // Enhanced content with animations
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Animated logo
                                    TweenAnimationBuilder(
                                      tween: Tween<double>(
                                        begin: 0.8,
                                        end: 1.0,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 800,
                                      ),
                                      curve: Curves.easeOutBack,
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: child,
                                        );
                                      },
                                      child: Image.asset(
                                        'images/WhiteDtwinLogo.png',
                                        height: 50.h,
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
                                    // Animated title
                                    TweenAnimationBuilder(
                                      tween: Tween<double>(
                                        begin: 0.0,
                                        end: 1.0,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 800,
                                      ),
                                      curve: Curves.easeOut,
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity: value,
                                          child: Transform.translate(
                                            offset: Offset(0, 20 * (1 - value)),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Create Your Account!',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    // Animated divider
                                    TweenAnimationBuilder(
                                      tween: Tween<double>(
                                        begin: 0.0,
                                        end: 1.0,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 1000,
                                      ),
                                      curve: Curves.easeOut,
                                      builder: (context, value, child) {
                                        return Container(
                                          width: 50.w * value,
                                          height: 4.h,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              2.r,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 10.h),
                                    // Animated subtitle
                                    TweenAnimationBuilder(
                                      tween: Tween<double>(
                                        begin: 0.0,
                                        end: 1.0,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 1200,
                                      ),
                                      curve: Curves.easeOut,
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity: value,
                                          child: child,
                                        );
                                      },
                                      child: Text(
                                        'Join us to start your health journey',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Enhanced Sign-up Form
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 20.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Enhanced section title
                                Text(
                                  "Personal Information",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A2B50),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "Please fill in your details to create an account",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 20.h),

                                // Enhanced First Name & Last Name Fields
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        label: "First Name",
                                        hintText: "Enter first name",
                                        prefixIcon: Icons.person_outline,
                                        controller: firstNameController,
                                        onChanged: (value) {
                                          if (mounted) {
                                            ref
                                                .read(
                                              firstNameProvider.notifier,
                                            )
                                                .state = value;
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: CustomTextField(
                                        label: "Last Name",
                                        hintText: "Enter last name",
                                        prefixIcon: Icons.person_outline,
                                        controller: lastNameController,
                                        onChanged: (value) {
                                          if (mounted) {
                                            ref
                                                .read(lastNameProvider.notifier)
                                                .state = value;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                // Enhanced Email Field
                                CustomTextField(
                                  label: "Email",
                                  hintText: "Enter your email",
                                  prefixIcon: Icons.email_outlined,
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (value) {
                                    if (mounted) {
                                      ref.read(emailProvider.notifier).state =
                                          value;
                                    }
                                  },
                                ),

                                // Enhanced Password Field
                                CustomTextField(
                                  label: "Password",
                                  hintText: "Enter your password",
                                  prefixIcon: Icons.lock_outline,
                                  controller: passwordController,
                                  obscureText: true,
                                  onChanged: (value) {
                                    if (mounted) {
                                      ref
                                          .read(passwordProvider.notifier)
                                          .state = value;
                                    }
                                  },
                                ),

                                // Enhanced Phone Number
                                Text(
                                  "Phone Number",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 15.w,
                                    vertical: 5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      DitwinCountryCodePicker(
                                        initialCountryCode: "IN",
                                        onChanged: (String dialCode) {
                                          setState(() {
                                            countryCode = dialCode;
                                          });
                                        },
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: TextField(
                                          controller: phoneController,
                                          keyboardType: TextInputType.phone,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Enter your phone number",
                                            hintStyle:
                                            GoogleFonts.plusJakartaSans(
                                              fontSize: 14.sp,
                                              color: const Color.fromARGB(
                                                255,
                                                112,
                                                106,
                                                106,
                                              ),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            if (mounted) {
                                              ref
                                                  .read(phoneProvider.notifier)
                                                  .state = value;
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 25.h),

                                // Enhanced Continue Button with loading state
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 55.h,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : handleSignUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0F67FE),
                                      foregroundColor: Colors.white,
                                      elevation: 3,
                                      shadowColor: const Color(
                                        0xFF0F67FE,
                                      ).withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          15.r,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.h,
                                      ),
                                    ),
                                    child:
                                    isLoading
                                        ? Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20.h,
                                          width: 20.w,
                                          child:
                                          const CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Text(
                                          isRetrying
                                              ? "Retrying..."
                                              : "Please wait...",
                                          style:
                                          GoogleFonts.plusJakartaSans(
                                            fontSize: 16.sp,
                                            fontWeight:
                                            FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    )
                                        : Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Continue",
                                          style:
                                          GoogleFonts.plusJakartaSans(
                                            fontSize: 16.sp,
                                            fontWeight:
                                            FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Image.asset(
                                          'images/SignInAddIcon.png',
                                          height: 24.h,
                                          width: 24.w,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 25.h),

                                // Enhanced Bottom Section with Card
                                Container(
                                  padding: EdgeInsets.all(20.r),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Enhanced Already have an account section
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Already have an account?",
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.grey.shade700,
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                          SizedBox(width: 5.w),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                  const SignInPage(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "Sign In",
                                              style:
                                              GoogleFonts.plusJakartaSans(
                                                color: const Color(
                                                  0xFF0F67FE,
                                                ),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.sp,
                                                decoration:
                                                TextDecoration
                                                    .underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20.h),

                                      // Enhanced Divider
                                      Divider(color: Colors.grey.shade300),
                                      SizedBox(height: 20.h),

                                      // Enhanced Terms & Conditions with icons
                                      Text(
                                        "By signing up, you agree to our",
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.grey.shade700,
                                          fontSize: 14.sp,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 15.h),

                                      // Enhanced dropdown for Privacy Policy and Terms & Conditions
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 12.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F7FA),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.03,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            hint: Row(
                                              children: [
                                                Icon(
                                                  Icons.description_outlined,
                                                  size: 20.sp,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 12.w),
                                                Text(
                                                  "Select document to view",
                                                  style:
                                                  GoogleFonts.plusJakartaSans(
                                                    color: Colors.grey[600],
                                                    fontSize: 14.sp,
                                                    fontWeight:
                                                    FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            value: null,
                                            icon: Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.red,
                                              size: 24.sp,
                                            ),
                                            items: [
                                              DropdownMenuItem<String>(
                                                value: 'privacy',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.privacy_tip_outlined,
                                                      size: 20.sp,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(width: 12.w),
                                                    Text(
                                                      "Privacy Policy",
                                                      style:
                                                      GoogleFonts.plusJakartaSans(
                                                        color: Colors.red,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 14.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DropdownMenuItem<String>(
                                                value: 'terms',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.description_outlined,
                                                      size: 20.sp,
                                                      color: Colors.red,
                                                    ),
                                                    SizedBox(width: 12.w),
                                                    Text(
                                                      "Terms & Conditions",
                                                      style:
                                                      GoogleFonts.plusJakartaSans(
                                                        color: Colors.red,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 14.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            onChanged: (String? value) {
                                              if (value != null) {
                                                if (value == 'privacy') {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/privacy',
                                                  );
                                                } else if (value == 'terms') {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/terms',
                                                  );
                                                }
                                              }
                                            },
                                            dropdownColor: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(12.r),
                                            elevation: 8,
                                          ),
                                        ),
                                      ),
                                    ],
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
              );
            },
          ),
        ),
      ),
    );
  }
}
