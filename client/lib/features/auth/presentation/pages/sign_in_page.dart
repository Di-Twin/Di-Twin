import 'package:client/features/auth/presentation/providers/auth_provider.dart';
import 'package:client/features/auth/presentation/pages/sign_up_page.dart';
import 'package:client/features/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:client/widgets/CustomTextField.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool isLoading = false;
  String? errorMessage;
  bool showPassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    if (emailController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter your email address");
      return false;
    }
    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailController.text.trim())) {
      _showErrorSnackBar("Please enter a valid email address");
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter your password");
      return false;
    }
    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  void handleSignIn() async {
    if (!_validateFields()) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    ref.read(loadingProvider.notifier).state = true;
    ref.read(emailProvider.notifier).state = emailController.text.trim();
    ref.read(passwordProvider.notifier).state = passwordController.text.trim();

    try {
      final loginWithEmailUseCase = ref.read(loginWithEmailUseCaseProvider);
      
      final result = await loginWithEmailUseCase.execute(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ref.read(loadingProvider.notifier).state = false;

        if (result["success"] == true) {
          _showSuccessSnackBar("Login successful!");
          
          // Navigate to Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else {
          // Handle specific error cases
          if (result["error"] == "network_error") {
            _showErrorSnackBar("Network error. Please check your internet connection and try again.");
          } else if (result["error"] == "server_unreachable") {
            _showErrorSnackBar("Server is currently unreachable. Please try again later.");
          } else {
            _showErrorSnackBar(result["message"] ?? "Login failed. Please try again.");
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });
        ref.read(loadingProvider.notifier).state = false;
        _showErrorSnackBar("Login failed: ${e.toString()}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        // Enhanced Header Section with animated gradient
                        Container(
                          height: 0.35.sh,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1A2B50),
                                Color(0xFF0F67FE),
                              ],
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30.r),
                              bottomRight: Radius.circular(30.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Enhanced decorative elements
                              Positioned(
                                top: -20.h,
                                right: -20.w,
                                child: Container(
                                  height: 120.h,
                                  width: 120.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 20.h,
                                left: -30.w,
                                child: Container(
                                  height: 100.h,
                                  width: 100.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 40.h,
                                left: 20.w,
                                child: Container(
                                  height: 30.h,
                                  width: 30.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 60.h,
                                right: 40.w,
                                child: Container(
                                  height: 40.h,
                                  width: 40.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              // Enhanced content
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Logo with subtle animation
                                    TweenAnimationBuilder(
                                      tween: Tween<double>(begin: 0.8, end: 1.0),
                                      duration: const Duration(milliseconds: 800),
                                      curve: Curves.easeOutBack,
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: child,
                                        );
                                      },
                                      child: Image.asset(
                                        'images/WhiteDtwinLogo.png',
                                        height: 60.h,
                                      ),
                                    ),
                                    SizedBox(height: 15.h),
                                    // Welcome text with animation
                                    TweenAnimationBuilder(
                                      tween: Tween<double>(begin: 0.0, end: 1.0),
                                      duration: const Duration(milliseconds: 800),
                                      curve: Curves.easeOut,
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity: value,
                                          child: Transform.translate(
                                            offset: Offset(0, 20 * (1 - value)),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Welcome Back',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 28.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    // Animated divider
                                    TweenAnimationBuilder(
                                      tween: Tween<double>(begin: 0.0, end: 1.0),
                                      duration: const Duration(milliseconds: 1000),
                                      curve: Curves.easeOut,
                                      builder: (context, value, child) {
                                        return Container(
                                          width: 50.w * value,
                                          height: 4.h,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(2.r),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 15.h),
                                    // Subtitle with animation
                                    TweenAnimationBuilder(
                                      tween: Tween<double>(begin: 0.0, end: 1.0),
                                      duration: const Duration(milliseconds: 1200),
                                      curve: Curves.easeOut,
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity: value,
                                          child: child,
                                        );
                                      },
                                      child: Text(
                                        'Sign in to continue your health journey',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Enhanced Form Section
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 20.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Enhanced section title
                                Text(
                                  "Login to Your Account",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A2B50),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "Please enter your credentials to sign in",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 25.h),

                                // Enhanced Email Field
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
                                SizedBox(height: 15.h),

                                // Enhanced Password Field
                                CustomTextField(
                                  label: "Password",
                                  hintText: "Enter your password",
                                  prefixIcon: Icons.lock_outline,
                                  controller: passwordController,
                                  obscureText: !showPassword,
                                  onChanged: (value) {
                                    if (mounted) {
                                      ref
                                          .read(passwordProvider.notifier)
                                          .state = value;
                                    }
                                  },
                                ),
                                SizedBox(height: 15.h),

                                // Enhanced Remember Me & Forgot Password
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Remember Me with enhanced styling
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 24.h,
                                          width: 24.w,
                                          child: Checkbox(
                                            value: rememberMe,
                                            onChanged: (value) {
                                              setState(() {
                                                rememberMe = value ?? false;
                                              });
                                            },
                                            activeColor:
                                                const Color(0xFF0F67FE),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          "Remember me",
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14.sp,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Enhanced Forgot Password
                                    GestureDetector(
                                      onTap: () {
                                        // Navigate to forgot password screen
                                      },
                                      child: Text(
                                        "Forgot Password?",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0F67FE),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 25.h),

                                // Enhanced error message
                                if (errorMessage != null)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: EdgeInsets.all(12.r),
                                    margin: EdgeInsets.only(bottom: 20.h),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: Colors.red[200]!,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red[700],
                                          size: 22.sp,
                                        ),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Text(
                                            errorMessage!,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13.sp,
                                              color: Colors.red[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Enhanced Sign In Button
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 55.h,
                                  margin: EdgeInsets.only(bottom: 25.h),
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : handleSignIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0F67FE),
                                      foregroundColor: Colors.white,
                                      elevation: 3,
                                      shadowColor: const Color(0xFF0F67FE).withOpacity(0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.r),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                    ),
                                    child: isLoading
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 20.h,
                                                width: 20.w,
                                                child: const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 3,
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              Text(
                                                "Signing in...",
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Sign In",
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              SizedBox(width: 8.w),
                                              Image.asset(
                                                'images/SignInAddIcon.png',
                                                height: 24.h,
                                                width: 24.w,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                // Enhanced Don't have an account section
                                Container(
                                  padding: EdgeInsets.all(20.r),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(15.r),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Don't have an account?",
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
                                                  builder: (context) => const SignUpPage(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "Sign Up",
                                              style: GoogleFonts.plusJakartaSans(
                                                color: const Color(0xFF0F67FE),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.sp,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // SizedBox(height: 20.h),
                                      
                                      // Divider(color: Colors.grey[300]),
                                      // SizedBox(height: 20.h),
                                      
                                      // Text(
                                      //   "Or continue with",
                                      //   style: GoogleFonts.plusJakartaSans(
                                      //     color: Colors.grey.shade700,
                                      //     fontSize: 14.sp,
                                      //   ),
                                      // ),
                                      // SizedBox(height: 20.h),
                                      
                                      // Enhanced social login buttons
                                      // Row(
                                      //   mainAxisAlignment: MainAxisAlignment.center,
                                      //   children: [
                                      //     _enhancedSocialLoginButton(
                                      //       'images/google_icon.png',
                                      //       'Google',
                                      //       () {
                                      //         // Handle Google login
                                      //       },
                                      //     ),
                                      //     SizedBox(width: 20.w),
                                      //     _enhancedSocialLoginButton(
                                      //       'images/apple_icon.png',
                                      //       'Apple',
                                      //       () {
                                      //         // Handle Apple login
                                      //       },
                                      //     ),
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                ),
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

  // Enhanced social login button
  Widget _enhancedSocialLoginButton(String iconPath, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 12.h,
          horizontal: 24.w,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              height: 22.h,
              width: 22.w,
            ),
            SizedBox(width: 10.w),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
