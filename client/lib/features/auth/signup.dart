import 'package:client/features/auth/OtpScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ditwin_country_code/ditwin_country_code.dart';
import 'package:client/widgets/CustomButton.dart';
import 'package:client/widgets/CustomTextField.dart';
import 'package:client/features/auth/signin.dart';
import 'package:client/data/providers/auth_provider.dart';

final phoneProvider = StateProvider<String>((ref) => '');
final firstNameProvider = StateProvider<String>((ref) => '');
final lastNameProvider = StateProvider<String>((ref) => '');
final loadingProvider = StateProvider<bool>((ref) => false);

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  String countryCode = "+91"; // Default country code

  bool _validateFields() {
    if (firstNameController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter your first name");
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter your last name");
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter a valid phone number");
      return false;
    }
    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void handleSignUp() async {
    if (!_validateFields()) return;

    final authService = ref.read(authProvider);
    String phoneNumber = "$countryCode${phoneController.text.trim()}";

    // Update state providers with latest values
    ref.read(phoneProvider.notifier).state = phoneController.text.trim();
    ref.read(firstNameProvider.notifier).state =
        firstNameController.text.trim();
    ref.read(lastNameProvider.notifier).state = lastNameController.text.trim();

    // Show loading
    ref.read(loadingProvider.notifier).state = true;

    try {
      await authService.registerUser(
        phoneNumber: phoneNumber,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
      );

      // Navigate to OTP screen if registration is successful
      ref.read(loadingProvider.notifier).state = false;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => OtpVerificationScreen(
                phoneNumber: phoneNumber
              ),
        ),
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
        ref.read(loadingProvider.notifier).state = false;
      }
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
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
                          height: 0.45.sh,
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
                                  text:
                                      isLoading ? "Please wait..." : "Continue",
                                  iconPath: 'images/SignInAddIcon.png',
                                  onPressed: isLoading ? null : handleSignUp,
                                ),
                                SizedBox(height: 15.h),

                                // 📌 Already have an account?
                                Center(
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Already have an account? ",
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.grey.shade700,
                                        fontSize: 15.sp,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Sign In",
                                          style: GoogleFonts.plusJakartaSans(
                                            color: const Color(0xFF264D73),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.sp,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer:
                                              TapGestureRecognizer()
                                                ..onTap = () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              const SignInScreen(),
                                                    ),
                                                  );
                                                },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15.h),

                                // 📌 Terms & Conditions
                                Center(
                                  child: Text.rich(
                                    TextSpan(
                                      text: "By signing up, you agree to our ",
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.grey.shade700,
                                        fontSize: 14.sp,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Privacy Policy",
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.sp,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer:
                                              TapGestureRecognizer()
                                                ..onTap = () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/privacy',
                                                  );
                                                },
                                        ),
                                        TextSpan(
                                          text: " and ",
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.grey.shade700,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Terms & Conditions",
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.sp,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer:
                                              TapGestureRecognizer()
                                                ..onTap = () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/questions/goal',
                                                  );
                                                },
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
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
