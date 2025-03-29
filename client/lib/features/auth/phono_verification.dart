import 'package:client/features/auth/signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/services.dart';
import 'package:client/widgets/CustomButton.dart';

class PhoneVerificationScreen extends ConsumerStatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  ConsumerState<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState
    extends ConsumerState<PhoneVerificationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode(); // Focus Node for auto-scroll
  final ScrollController _scrollController = ScrollController();
  String _countryCode = "+91";

  @override
  void initState() {
    super.initState();

    // Listener to scroll when input field is focused
    _phoneFocusNode.addListener(() {
      if (_phoneFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController, // Attach Scroll Controller
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),

                      // Back Button and Title
                      Row(
                        children: [
                          // Back Button
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
                              'Phone Number Verification',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30.h),

                      // Illustration
                      Center(
                        child: Image.asset(
                          'images/phono-verify.png',
                          height: 245.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // SMS Message Text
                      Center(
                        child: Text(
                          'We will send a one-time SMS message.\nCarrier rates may apply.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),

                      // Phone Number Input Field
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            // Country Code Picker
                            SizedBox(
                              height: 48.h,
                              child: CountryCodePicker(
                                onChanged: (CountryCode countryCode) {
                                  setState(() {
                                    _countryCode =
                                        countryCode.dialCode ?? "+91";
                                  });
                                },
                                initialSelection: 'IN',
                                favorite: const ['+91', '+1', '+44', '+61'],
                                showCountryOnly: false,
                                alignLeft: false,
                                padding: EdgeInsets.zero,
                                textStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                                flagWidth: 24.w,
                                boxDecoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                              ),
                            ),

                            // Vertical Divider
                            Container(
                              height: 30.h,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),

                            // TextField for Phone Number
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.w),
                                child: TextField(
                                  controller: _phoneController,
                                  focusNode:
                                      _phoneFocusNode, // Attach Focus Node
                                  maxLength: 10,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    counterText: "",
                                    hintText: "Phone number",
                                    hintStyle: GoogleFonts.plusJakartaSans(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16.sp,
                                    color: Colors.black,
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Continue Button (Matching Signup Page)
                      CustomButton(
                        text: "Continue",
                        iconPath: 'images/SignInAddIcon.png',
                        onPressed: () {
                          if (_phoneController.text.length == 10) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const SignInScreen(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please enter a valid 10-digit phone number.",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),

                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
