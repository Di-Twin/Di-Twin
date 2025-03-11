import 'package:client/features/auth/OtpScreen.dart';
import 'package:client/features/auth/signup.dart';
import 'package:client/features/auth/phono_verification.dart';
import 'package:client/features/health_assessment/health_assessment_avatar.dart';
import 'package:client/features/health_assessment/health_assessment_loading.dart';
import 'package:client/features/health_assessment/health_assessment_score.dart';
import 'package:client/features/welcome/StartPage.dart';
import 'package:client/features/welcome/WelcomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/signin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Base design size (adjust if needed)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Di-Twin',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: GoogleFonts.plusJakartaSansTextTheme(),
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const Startpage(),
            '/welcome': (context) => const WelcomePage(),
            '/signin': (context) => const SignInScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/numberverification': (context) => const PhoneVerificationScreen(),
            '/otpverify': (context) => const OtpVerificationScreen(),
            '/loading': (context) => const HealthAssessmentLoading(loadingDuration: Duration(seconds: 5), nextScreen: HealthAssessmentScore(score: 22,)),
            '/avatar': (context) => const HealthAssessmentAvatar(),
            '/dashboard': (context) => const HealthAssessmentScore(score: 22,),
          },
        );
      },
    );
  }
}
