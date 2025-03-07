import 'package:client/pages/AuthPages/OtpScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_code_picker/country_code_picker.dart';

class PhoneVerificationScreen extends ConsumerStatefulWidget {
  const PhoneVerificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState
    extends ConsumerState<PhoneVerificationScreen> {
  final TextEditingController _phoneController = TextEditingController(
    text: "87258 78915",
  );
  String _countryCode = "+91";

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              // Back Button and Title in a row
              Row(
                children: [
                  // Back Button
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade900),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                      iconSize: 24.sp,
                      padding: EdgeInsets.all(4.r),
                      constraints: const BoxConstraints(),
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Title
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

              // Illustration - using your image asset
              Center(
                child: Image.asset(
                  'images/phono-verify.png',
                  height: 245.h,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 20.h),

              // SMS message text
              Center(
                child: Text(
                  'We will send a one time SMS message.\nCarrier rates may apply.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Phone number input field with CountryCodePicker
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    // Country code picker from the package
                    SizedBox(
                      height: 48.h, // Fixed height for better alignment
                      child: CountryCodePicker(
                        onChanged: (CountryCode countryCode) {
                          setState(() {
                            _countryCode = countryCode.dialCode ?? "+91";
                          });
                        },
                        initialSelection: 'IN',
                        favorite: const ['+91', '+1', '+44', '+61'],
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                        padding: EdgeInsets.zero,
                        textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        flagWidth: 24.w,
                        boxDecoration: BoxDecoration(color: Colors.transparent),
                      ),
                    ),

                    // Vertical divider
                    Container(
                      height: 30.h,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),

                    // Text field for phone number
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Row(
                          children: [
                            Text(
                              "($_countryCode) ",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.sp,
                                color: Colors.black,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,

                                  hintText: "Phone number",
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 16.sp,
                                    fontWeight:
                                        FontWeight
                                            .w600, // Adjust this for more weight
                                    color: Colors.grey, // Change if needed
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16.sp,
                                  color: Colors.black,
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Clipboard button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Icon(
                        Icons.content_paste_outlined,
                        size: 20.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OtpVerificationScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F67FE),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.add, size: 16.sp),
                    ],
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
