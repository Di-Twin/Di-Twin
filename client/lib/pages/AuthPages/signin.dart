import 'package:client/pages/AuthPages/CustomButton.dart';
import 'package:client/pages/AuthPages/CustomTextField.dart';
import 'package:client/pages/AuthPages/signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final showPasswordProvider = StateProvider<bool>((ref) => false);
final loadingProvider = StateProvider<bool>((ref) => false);

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  void handleSubmit() {
    ref.read(loadingProvider.notifier).state = true;
    Future.delayed(const Duration(seconds: 2), () {
      ref.read(loadingProvider.notifier).state = false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signed In Successfully')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            final screenHeight = constraints.maxHeight;
            final adjustedKeyboardHeight =
                keyboardHeight > screenHeight * 0.3
                    ? keyboardHeight * 0.8
                    : keyboardHeight;
            return SingleChildScrollView(
              physics:
                  keyboardHeight > 0
                      ? const ClampingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                  maxHeight:
                      keyboardOpen
                          ? screenHeight + adjustedKeyboardHeight
                          : screenHeight,
                ),
                child: Container(
                  width: double.infinity,
                  height:
                      constraints.maxHeight +
                      (keyboardOpen ? keyboardHeight : 0),
                  color: Colors.grey[200],
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 270.h, // Responsive height
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
                                  height: 50.h, // Responsive height
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  'Sign In',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 35.sp, // Responsive font size
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Sign-in form card
                      Positioned(
                        top: 280.h,
                        left: 20.w,
                        right: 20.w,
                        child: Card(
                          color: Colors.grey[200],
                          elevation: 0,
                          child: Padding(
                            padding: EdgeInsets.all(15.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextField(label: "Email Address", hintText: "Enter your email", prefixIcon: FontAwesomeIcons.envelope),
                                CustomTextField(label: "Password", hintText: "Enter your password", prefixIcon: Icons.lock_outline_rounded, obscureText: true),
                                
                                SizedBox(height: 40.h),

                                // Sign In Button
                                CustomButton(text: "Sign in", iconPath: 'images/SignInAddIcon.png', onPressed: () { Navigator.pushNamed(context, '/dashbord'); },), 

                                // OR Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        thickness: 1,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.0.w,
                                      ),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey,
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
                                SizedBox(height: 25.h),

                                // Google Sign In Button
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 40.h),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.google,
                                        color: Colors.black,
                                        size: 18.sp,
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        'Sign in with Google',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 25.h),
                                Center(
                                    child: Text.rich(
                                      TextSpan(
                                        text: "Don’t have an account? ",
                                        style: TextStyle(
                                          color:
                                              Colors
                                                  .grey, // Gray color for text
                                          fontSize:
                                              14.sp, // Responsive font size
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "Sign Up",
                                            style: TextStyle(
                                              color:
                                                  Colors
                                                      .red, // Red color for "Sign Up"
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  14.sp, // Responsive font size
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Colors.red,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                                            }
                                          ),
                                        ],
                                      ),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
