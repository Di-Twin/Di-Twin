import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:client/widgets/CustomButton.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool loading = false;

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _selectedIndex = 0;
  late String currentVerificationId;

  @override
  void initState() {
    super.initState();
    currentVerificationId = widget.verificationId;

    // Start listening for OTP
    _listenForOtp();

    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() {
            _selectedIndex = i;
          });
        }
      });
    }
  }

  // Function to start OTP listening
  void _listenForOtp() async {
    SmsAutoFill().listenForCode();
    SmsAutoFill().code.listen((otp) {
      if (otp.isNotEmpty && otp.length == 6) {
        _onOtpFilled(otp);
      }
    });
  }

  void _onOtpFilled(String otp) {
    if (otp.length == 6) {
      for (int i = 0; i < otp.length; i++) {
        _controllers[i].text = otp[i]; // Autofill each box
      }
      _verifyOtp(); // Automatically verify after autofill
    }
  }

  @override
  void dispose() {
    SmsAutoFill()
        .unregisterListener(); // Stop listening when screen is disposed
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

void _onDigitChanged(int index, String value) {
  if (value.isNotEmpty) {
    // Overwrite existing digit instead of appending
    _controllers[index].text = value[value.length - 1];  
    _controllers[index].selection = TextSelection.fromPosition(
      TextPosition(offset: 1), // Keep cursor at the end
    );

    // Move to next field if it's not the last one
    if (index < _controllers.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  } else {
    // If erased, move to the previous field
    if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }
}
  

  void _verifyOtp() async {
    String otp = _controllers.map((controller) => controller.text).join();
    if (otp.length == 6) {
      setState(() {
        loading = true;
      });

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: currentVerificationId,
        smsCode: otp,
      );

      try {
        await _auth.signInWithCredential(credential);
        Navigator.pushNamed(context, '/loading');
      } catch (e) {
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid OTP. Please try again.")),
        );
      }
    }
  }

  void _resendOtp() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "OTP resend failed")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          currentVerificationId = verificationId;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP resent successfully")),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF1A1D1F),
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.all(8.r),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    'OTP Security',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1D1F),
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: bottomPadding,
                    left: 20.w,
                    right: 20.w,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Please enter the 6-digit code you received on\nyour phone!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A1D1F),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          bool isSelected = _selectedIndex == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.symmetric(horizontal: 6.w),
                            width: 43.w,
                            height: 55.w,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(0xFF0066FF)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.blueAccent
                                        : Colors.grey.shade300,
                                width: isSelected ? 3.0 : 2.0,
                              ),
                            ),
                            child: Center(
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                ),
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged:
                                    (value) => _onDigitChanged(index, value),
                              ),
                            ),
                          );
                        }),
                      ),

                      SizedBox(height: 30.h),
                      Center(
                        child: GestureDetector(
                          onTap: _resendOtp,
                          child: Text.rich(
                            TextSpan(
                              text: "Didn’t get OTP? ",
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey.shade700,
                                fontSize: 12.sp,
                              ),
                              children: [
                                TextSpan(
                                  text: "Resend OTP",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      SizedBox(height: 40.h),
                      CustomButton(
                        text: loading ? "Verifying..." : "Verify",
                        iconPath: 'images/SignInAddIcon.png',
                        onPressed: loading ? null : () => _verifyOtp(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
