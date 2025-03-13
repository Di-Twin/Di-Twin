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
import 'package:firebase_auth/firebase_auth.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String countryCode = "+91"; // Default country code
  bool loading = false;

  void sendOTP() async {
    final auth = FirebaseAuth.instance;
    String phoneNumber = "$countryCode${phoneController.text.trim()}";

    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid phone number")),
      );
      return;
    }

    ref.read(loadingProvider.notifier).state = true; // Show loading

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification Failed: ${e.message}")),
        );
        ref.read(loadingProvider.notifier).state = false; // Hide loading
      },
      codeSent: (String verificationId, int? resendToken) {
        ref.read(loadingProvider.notifier).state = false; // Hide loading

        // Navigate to OTP screen with verificationId and phoneNumber
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => OtpVerificationScreen(
                  verificationId: verificationId,
                  phoneNumber: phoneNumber,
                ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  void dispose() {
    ref.read(phoneProvider.notifier).state = '';
    ref.read(firstNameProvider.notifier).state = '';
    ref.read(lastNameProvider.notifier).state = '';
    ref.read(loadingProvider.notifier).state = true;

    phoneController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: CustomTextField(
                                        label: "Last Name",
                                        hintText: "Enter last name",
                                        prefixIcon: Icons.person_outline,
                                        controller: lastNameController,
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
                                  text: "Continue",
                                  iconPath: 'images/SignInAddIcon.png',
                                  onPressed: () {
                                    sendOTP(); // Call sendOTP() to initiate OTP verification
                                  },
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
