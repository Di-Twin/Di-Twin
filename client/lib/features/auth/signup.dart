import 'package:client/widgets/CustomButton.dart';
import 'package:client/widgets/CustomTextField.dart';
import 'package:client/features/auth/signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ditwin_country_code/ditwin_country_code.dart';

final phoneProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final loadingProvider = StateProvider<bool>((ref) => false);

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String countryCode = "+91"; // Default country code

  @override
  void initState() {
    super.initState();
    // Initialize any listeners here if needed
  }

  @override
  void dispose() {
    // First, clear any provider state that might be using these controllers
    ref.read(phoneProvider.notifier).state = '';
    ref.read(passwordProvider.notifier).state = '';

    // Next, dispose controllers
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    // Finally dispose focus nodes
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // Set this to true to allow scrolling when keyboard appears
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // 📌 Header Section (Fixed but slightly reduced height)
              Container(
                height: 0.25.sh, // Reduced from 28% to 25% of screen height
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
                    Image.asset('images/WhiteDtwinLogo.png', height: 50.h),
                    SizedBox(height: 10.h),
                    Text(
                      'Sign Up For Free!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // 📌 Sign-up Form (Scrollable)
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  // Reduced padding to prevent overflow
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📌 Phone Number Input with Country Picker
                        // 📌 Phone Number Input with DitwinCountryCodePicker
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
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              // 📌 Ditwin Country Code Picker
                              DitwinCountryCodePicker(
                                initialCountryCode: "IN", // Default to India
                                onChanged: (String dialCode) {
                                  setState(() {
                                    countryCode = dialCode;
                                  });
                                },
                              ),
                              SizedBox(width: 5.w), // 🚀 Added small space
                              // 📌 Input Field wrapped in Expanded to prevent overflow
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
                                    hintStyle: GoogleFonts.plusJakartaSans(
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
                                      ref.read(phoneProvider.notifier).state =
                                          value;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 15.h),

                        // 📌 Password Input
                        CustomTextField(
                          label: "Password",
                          hintText: "Enter your password",
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: true,
                          controller: passwordController,
                        ),
                        SizedBox(height: 15.h),

                        // 📌 Confirm Password Input
                        CustomTextField(
                          label: "Confirm Password",
                          hintText: "Re-enter your password",
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: true,
                          controller: confirmPasswordController,
                        ),
                        SizedBox(height: 20.h),

                        // 📌 Continue Button
                        CustomButton(
                          text: "Continue",
                          iconPath: 'images/SignInAddIcon.png',
                          onPressed: () {
                            Navigator.pushNamed(context, '/otpverify');
                          },
                        ),
                        SizedBox(height: 15.h),

                        // 📌 OR Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Text(
                                'OR',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.h),

                        // 📌 Google Sign-In Button
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 45.h),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Center content
                            children: [
                              Image.asset(
                                'images/google_logo.png',
                                height: 20.h,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                // 🚀 FIX: Prevents text overflow inside Row
                                child: Text(
                                  'Sign in with Google',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                  textAlign:
                                      TextAlign.center, // Centers the text
                                ),
                              ),
                            ],
                          ),
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
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp,
                                    decoration: TextDecoration.underline,
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
                        // Add padding at bottom to ensure content isn't cut off
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
