import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/widgets/CustomButton.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:client/data/providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  bool loading = false;
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
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

  void _listenForOtp() async {
    await SmsAutoFill().listenForCode();
    SmsAutoFill().code.listen((otp) {
      if (otp.isNotEmpty && otp.length == 6) {
        _onOtpFilled(otp);
      }
    });
  }

  void _onOtpFilled(String otp) {
    for (int i = 0; i < otp.length; i++) {
      _controllers[i].text = otp[i];
    }
    _verifyOtp();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
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
      _controllers[index].text = value[value.length - 1];
      _controllers[index].selection = TextSelection.fromPosition(
        const TextPosition(offset: 1),
      );

      if (index < _controllers.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else if (_controllers.every((c) => c.text.isNotEmpty)) {
        _verifyOtp();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  void _verifyOtp() async {
    String otp = _controllers.map((controller) => controller.text).join();
    if (otp.length == 6) {
      setState(() => loading = true);

      try {
        final authService = ref.read(authProvider);

        // Check if access token exists
        final String? accessToken = authService.getAccessToken();

        if (accessToken == null) {
          // If no token, it's a sign-in process
          await authService.signInUser(
            phoneNumber: widget.phoneNumber,
            otpCode: otp,
          );
        } else {
          // If token exists, proceed with OTP verification
          await authService.verifyOtp(otpCode: otp);
        }

        if (mounted) {
          Navigator.pushNamed(context, '/questions/goal');
        }
      } catch (e) {
        setState(() => loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _resendOtp() async {
    try {
      final authService = ref.read(authProvider);
      await authService.resendOtp(widget.phoneNumber);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("OTP resent successfully")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
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
                                autofillHints: const [
                                  AutofillHints.oneTimeCode,
                                ],
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
                      GestureDetector(
                        onTap: _resendOtp,
                        child: Text(
                          "Didn't get OTP? Resend OTP",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      SizedBox(height: 40.h),
                      CustomButton(
                        text: loading ? "Verifying..." : "Verify",
                        iconPath: 'images/SignInAddIcon.png',
                        onPressed: loading ? null : _verifyOtp,
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
