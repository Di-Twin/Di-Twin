import 'package:client/widgets/CustomButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ditwin_country_code/ditwin_country_code.dart'; // ✅ Updated import

final phoneProvider = StateProvider<String>((ref) => '');
final loadingProvider = StateProvider<bool>((ref) => false);

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final FocusNode phoneFocusNode = FocusNode();
  final TextEditingController phoneController = TextEditingController();
  String countryCode = "+91"; // Default country code

  @override
  void dispose() {
    ref.read(phoneProvider.notifier).state = '';
    phoneController.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 📌 Top Section with Color Gradient Background
                    Container(
                      height: constraints.maxHeight * 0.65,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0A1B40), Color(0xFF264D73)],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40.r),
                          bottomRight: Radius.circular(40.r),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/WhiteDtwinLogo.png',
                            height: 70.h,
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'Welcome Back!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            "Sign in to continue your journey",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 📌 Sign-in Form
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h), // ✅ Added spacing
                          // 📌 Phone Number Input
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
                                // ✅ Country Picker
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

                          // 📌 Continue Button
                          CustomButton(
                            text: "Continue",
                            iconPath: 'images/SignInAddIcon.png',
                            onPressed: () {
                              Navigator.pushNamed(context, '/loading');
                            },
                          ),

                          SizedBox(height: 10.h),

                          // ✅ "Don't have an account? Sign Up" text
                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey.shade700,
                                  fontSize: 14.sp,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Sign Up",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF264D73),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.pushNamed(
                                              context,
                                              '/signup',
                                            );
                                          },
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: 10.h),

                          // 📌 Terms & Privacy Policy Text
                          Center(
                            child: Text.rich(
                              TextSpan(
                                text: "By clicking Continue, you accept our ",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey.shade700,
                                  fontSize: 14.sp,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Terms & Conditions",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.pushNamed(
                                              context,
                                              '/terms',
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
                                    text: "Privacy Policy",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
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
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: 20.h), // ✅ Final spacing
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
