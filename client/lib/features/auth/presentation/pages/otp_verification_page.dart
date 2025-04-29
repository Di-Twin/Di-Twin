import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/widgets/CustomButton.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:client/features/auth/presentation/providers/auth_provider.dart';
import 'dart:async';

class OtpVerificationPage extends ConsumerStatefulWidget {
  final String? phoneNumber;
  final String? email;
  final String? firstName;
  final String? lastName;
  final bool isEmailFlow;
  final String? signupToken; // Make nullable again

  const OtpVerificationPage({
    super.key,
    this.phoneNumber,
    this.email,
    this.firstName,
    this.lastName,
    this.isEmailFlow = false,
    this.signupToken, // Make nullable again
  });

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage>
    with SingleTickerProviderStateMixin {
  bool loading = false;
  bool verificationSuccess = false;
  final int otpLength = 4; // Changed from 6 to 4
  final List<TextEditingController> _controllers = List.generate(
    4, // Changed from 6 to 4
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _selectedIndex = 0;
  
  // Timer for OTP expiration
  Timer? _timer;
  int _secondsRemaining = 120; // 2 minutes
  
  // Timer for resend cooldown
  Timer? _resendTimer;
  int _resendCooldown = 0;
  
  // Animation controller
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    
    print("🔐 OTP Screen initialized");
    print("📧 Email: ${widget.email}");
    print("📱 Phone: ${widget.phoneNumber}");
    print("📝 Is Email Flow: ${widget.isEmailFlow}");
    print("🔑 Signup Token: ${widget.signupToken}");
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    if (!widget.isEmailFlow) {
      _listenForOtp();
    }
    
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() {
            _selectedIndex = i;
          });
        }
      });
    }
    
    // Start OTP expiration timer
    _startExpirationTimer();
    
    // Request focus on first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    });
  }
  
  void _startExpirationTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  void _listenForOtp() async {
    try {
      await SmsAutoFill().listenForCode();
      print("📱 Listening for SMS OTP");
      SmsAutoFill().code.listen((otp) {
        print("📱 Received OTP: $otp");
        if (otp.isNotEmpty && otp.length >= otpLength) {
          // Only use the first 4 digits if more are received
          String trimmedOtp = otp.substring(0, otpLength);
          _onOtpFilled(trimmedOtp);
        }
      });
    } catch (e) {
      print("❌ Error listening for SMS OTP: $e");
    }
  }

  void _onOtpFilled(String otp) {
    print("📱 OTP filled: $otp");
    for (int i = 0; i < otp.length && i < otpLength; i++) {
      _controllers[i].text = otp[i];
    }
    _verifyOtp();
  }

  @override
  void dispose() {
    if (!widget.isEmailFlow) {
      SmsAutoFill().unregisterListener();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    _resendTimer?.cancel();
    _animationController.dispose();
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
        // Auto-verify when all digits are entered
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
    print("🔐 Verifying OTP: $otp");

    if (otp.length == otpLength) {
      setState(() => loading = true);
      FocusScope.of(context).unfocus(); // Hide keyboard

      try {
        if (widget.isEmailFlow) {
          print("📧 Completing email signup with OTP: $otp");
          print("🔑 Using token: ${widget.signupToken}");
          
          if (widget.signupToken == null || widget.signupToken!.isEmpty) {
            setState(() => loading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Missing verification token. Please try again."),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            return;
          }
          
          // Email OTP flow - make exactly ONE verification attempt
          final completeEmailSignupUseCase = ref.read(completeEmailSignupUseCaseProvider);
          
          // Pass the token directly with the OTP
          final result = await completeEmailSignupUseCase.execute(
            otp: otp,
            token: widget.signupToken!, // Use the token passed from signup page
          );
          
          print("📊 OTP verification result: $result");
          
          if (result["success"] == true) {
            // Show success animation
            setState(() {
              verificationSuccess = true;
            });
            _animationController.forward();
            
            // Delay navigation to show success animation
            await Future.delayed(const Duration(milliseconds: 1500));

            // ➡️ Redirect newly signed-up users to health questions
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/questions/goal',
                (route) => false,
              );
            }
          } else {
            // Show error
            setState(() => loading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result["message"] ?? "Invalid OTP. Please try again."),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        } else {
          // Legacy phone OTP flow
          if (widget.firstName == null || widget.lastName == null) {
            // 🔐 Sign In flow
            print("📱 Signing in with phone OTP: $otp");
            final signInUserUseCase = ref.read(signInUserUseCaseProvider);
            final result = await signInUserUseCase.execute(
              phoneNumber: widget.phoneNumber!,
              otpCode: otp,
            );
            
            print("📊 Phone sign-in result: $result");
            
            if (result["success"] == true) {
              // Show success animation
              setState(() {
                verificationSuccess = true;
              });
              _animationController.forward();
              
              // Delay navigation to show success animation
              await Future.delayed(const Duration(milliseconds: 1500));

              // ➡️ Redirect signed-in users to dashboard
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/dashboard',
                  (route) => false,
                );
              }
            } else {
              // Show error
              setState(() => loading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result["message"] ?? "Invalid OTP. Please try again."),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          } else {
            // 🆕 Sign Up flow
            print("📱 Completing registration with phone OTP: $otp");
            final completeRegistrationUseCase = ref.read(completeRegistrationUseCaseProvider);
            final result = await completeRegistrationUseCase.execute(
              phoneNumber: widget.phoneNumber!,
              firstName: widget.firstName!,
              lastName: widget.lastName!,
              otpCode: otp,
            );
            
            print("📊 Phone registration result: $result");
            
            if (result["success"] == true) {
              // Show success animation
              setState(() {
                verificationSuccess = true;
              });
              _animationController.forward();
              
              // Delay navigation to show success animation
              await Future.delayed(const Duration(milliseconds: 1500));

              // ➡️ Redirect newly signed-up users to health questions
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/questions/goal',
                  (route) => false,
                );
              }
            } else {
              // Show error
              setState(() => loading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result["message"] ?? "Invalid OTP. Please try again."),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          }
        }
      } catch (e) {
        print("❌ OTP verification error: $e");
        setState(() => loading = false);
        
        // Show error with shake animation
        _animationController.reset();
        _animationController.forward();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _resendOtp() async {
    if (_resendCooldown > 0) return;
    
    setState(() {
      _resendCooldown = 30; // 30 seconds cooldown
      _secondsRemaining = 120; // Reset expiration timer
    });
    
    // Start resend cooldown timer
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCooldown > 0) {
          _resendCooldown--;
        } else {
          _resendTimer?.cancel();
        }
      });
    });
    
    try {
      if (widget.isEmailFlow) {
        print("📧 Resending email OTP to: ${widget.email}");
        // Resend email OTP
        final initiateEmailSignupUseCase = ref.read(initiateEmailSignupUseCaseProvider);
        final result = await initiateEmailSignupUseCase.execute(
          email: widget.email!,
          password: "",  // Password is not needed for resend
          firstName: widget.firstName!,
          lastName: widget.lastName!,
        );
        
        print("📊 Email OTP resend result: $result");
        
        if (result["success"] == true) {
          // Get the new token from the response
          if (result["token"] != null) {
            // Update the token in the state
            setState(() {
              // We can't update the widget property directly, but we'll use the new token
              // in the next verification attempt
            });
            print("✅ New signup token received after resend: ${result["token"]}");
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("OTP resent successfully to your email"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result["message"] ?? "Failed to resend OTP"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        // Legacy phone OTP resend
        print("📱 Resending phone OTP to: ${widget.phoneNumber}");
        final resendOtpUseCase = ref.read(resendOtpUseCaseProvider);
        final result = await resendOtpUseCase.execute(widget.phoneNumber!);
        
        print("📊 Phone OTP resend result: $result");
        
        if (result["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("OTP resent successfully to your phone"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result["message"] ?? "Failed to resend OTP"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      print("❌ OTP resend error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
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
                    'OTP Verification',
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
                      // Verification illustration
                      if (!verificationSuccess) ...[
                        Container(
                          width: 150.w,
                          height: 150.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(75.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              widget.isEmailFlow ? Icons.email : Icons.phone_android,
                              size: 80.sp,
                              color: const Color(0xFF0066FF),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Success animation
                        Container(
                          width: 150.w,
                          height: 150.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(75.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check_circle,
                              size: 80.sp,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                      
                      SizedBox(height: 30.h),
                      
                      Text(
                        widget.isEmailFlow
                            ? 'Please enter the 4-digit code you received in your email!'
                            : 'Please enter the 4-digit code you received on\nyour phone!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A1D1F),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        widget.isEmailFlow
                            ? widget.email ?? ""
                            : widget.phoneNumber ?? "",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0066FF),
                        ),
                      ),
                      
                      SizedBox(height: 10.h),
                      
                      // OTP expiration timer
                      Text(
                        'Code expires in: ${_formatTime(_secondsRemaining)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: _secondsRemaining < 30 
                              ? Colors.red 
                              : const Color(0xFF1A1D1F),
                        ),
                      ),
                      
                      SizedBox(height: 30.h),
                      
                      // OTP input fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(otpLength, (index) {
                          bool isSelected = _selectedIndex == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.symmetric(horizontal: 8.w),
                            width: 60.w,
                            height: 70.w,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(0xFF0066FF)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.blueAccent
                                        : Colors.grey.shade300,
                                width: isSelected ? 3.0 : 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected 
                                      ? const Color(0xFF0066FF).withOpacity(0.3) 
                                      : Colors.transparent,
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
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
                                  fontSize: 28.sp,
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
                      
                      // Resend OTP button
                      GestureDetector(
                        onTap: _resendCooldown > 0 ? null : _resendOtp,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: _resendCooldown > 0 
                                ? Colors.grey.shade200 
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30.r),
                            border: Border.all(
                              color: _resendCooldown > 0 
                                  ? Colors.grey.shade300 
                                  : const Color(0xFF0066FF),
                            ),
                          ),
                          child: Text(
                            _resendCooldown > 0
                                ? "Resend OTP in ${_resendCooldown}s"
                                : "Didn't get OTP? Resend OTP",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: _resendCooldown > 0 
                                  ? Colors.grey 
                                  : const Color(0xFF0066FF),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 40.h),
                      
                      // Verify button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: loading || verificationSuccess ? 60.w : 300.w,
                        height: 55.h,
                        child: loading 
                            ? Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0066FF),
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                ),
                              )
                            : verificationSuccess
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  )
                                : CustomButton(
                                    text: "Verify",
                                    iconPath: 'images/SignInAddIcon.png',
                                    onPressed: _verifyOtp,
                                  ),
                      ),
                      
                      SizedBox(height: 20.h),
                      
                      // Auto-verification message
                      Text(
                        "We'll automatically verify the OTP when you enter all digits",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
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
