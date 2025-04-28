import 'package:client/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:client/features/auth/presentation/pages/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ditwin_country_code/ditwin_country_code.dart';
import 'package:client/widgets/CustomButton.dart';
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
    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailController.text.trim())) {
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
        action: message.contains("server is temporarily unavailable") 
            ? SnackBarAction(
                label: "Retry",
                textColor: Colors.white,
                onPressed: () {
                  handleSignUp(isRetry: true);
                },
              )
            : null,
      )
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      )
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
    ref.read(firstNameProvider.notifier).state = firstNameController.text.trim();
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
      final initiateEmailSignupUseCase = ref.read(initiateEmailSignupUseCaseProvider);
      
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
          _showErrorSnackBar("Failed to get verification token. Please try again.");
          return;
        }
        
        // Show success message
        if (mounted) {
          _showSuccessSnackBar("OTP sent successfully to your email!");
          
          // Navigate to OTP screen with the token
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationPage(
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
          _showErrorSnackBar("The server is temporarily unavailable. Please try again in a few minutes.");
        }
      } else if (result["error"] == "empty_response") {
        if (mounted) {
          _showErrorSnackBar("The server returned an empty response. Please try again.");
        }
      } else {
        if (mounted) {
          _showErrorSnackBar(result["message"] ?? "Failed to send OTP. Please try again.");
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        // Clean up the error message
        if (errorMessage.contains("Exception: Email Signup Error: Exception:")) {
          errorMessage = errorMessage.replaceAll("Exception: Email Signup Error: Exception:", "");
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
      backgroundColor: Colors.grey[100],
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
                        // 📌 Header Section
                        Container(
                          height: 0.35.sh, // Reduced height to make more room for form
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A2B50),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30.r),
                              bottomRight: Radius.circular(30.r),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'images/WhiteDtwinLogo.png',
                                height: 40.h,
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'Create Your Account!',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 📌 Sign-up Form (Now Scrollable)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 15.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // First Name & Last Name Fields
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
                                    SizedBox(width: 10.w),
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
                                SizedBox(height: 5.h),

                                // 📌 Email Field
                                CustomTextField(
                                  label: "Email",
                                  hintText: "Enter your email",
                                  prefixIcon: Icons.email_outlined,
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (value) {
                                    if (mounted) {
                                      ref
                                          .read(emailProvider.notifier)
                                          .state = value;
                                    }
                                  },
                                ),
                                SizedBox(height: 5.h),

                                // 📌 Password Field
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
                                SizedBox(height: 5.h),

                                // 📌 Phone Number
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
                                    horizontal: 10.w,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    color: Colors.white,
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
                                      SizedBox(width: 5.w),
                                      Expanded(
                                        child: TextField(
                                          controller: phoneController,
                                          keyboardType: TextInputType.phone,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w800,
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
                                SizedBox(height: 20.h),

                                // 📌 Continue Button
                                CustomButton(
                                  text: isLoading 
                                      ? (isRetrying ? "Retrying..." : "Please wait...") 
                                      : "Continue",
                                  iconPath: 'images/SignInAddIcon.png',
                                  onPressed: isLoading ? null : handleSignUp,
                                ),
                                SizedBox(height: 20.h),

                                // 📌 Enhanced Bottom Section with Card
                                Container(
                                  padding: EdgeInsets.all(15.r),
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
                                      // Already have an account section
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
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
                                                  builder: (context) => const SignInPage(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "Sign In",
                                              style: GoogleFonts.plusJakartaSans(
                                                color: const Color(0xFF264D73),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.sp,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15.h),
                                      
                                      // Divider
                                      Divider(color: Colors.grey.shade300),
                                      SizedBox(height: 15.h),
                                      
                                      // Terms & Conditions with icons
                                      Text(
                                        "By signing up, you agree to our",
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.grey.shade700,
                                          fontSize: 14.sp,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 10.h),
                                      
                                      // Privacy Policy button
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(context, '/privacy');
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8.h,
                                            horizontal: 15.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F7FA),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.privacy_tip_outlined,
                                                size: 18.sp,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8.w),
                                              Text(
                                                "Privacy Policy",
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      
                                      Text(
                                        "and",
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.grey.shade700,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      
                                      // Terms & Conditions button
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(context, '/terms');
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8.h,
                                            horizontal: 15.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F7FA),
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.description_outlined,
                                                size: 18.sp,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8.w),
                                              Text(
                                                "Terms & Conditions",
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10.h),
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
