import 'package:client/features/auth/signup.dart';
import 'package:client/features/health_assessment/health_assessment_avatar.dart';
import 'package:client/features/health_assessment/health_assessment_loading.dart';
import 'package:client/features/health_assessment/health_assessment_height.dart';
import 'package:client/features/health_assessment/health_assessment_score.dart';
import 'package:client/features/health_assessment/health_assessment_weight.dart';
import 'package:client/features/welcome/StartPage.dart';
import 'package:client/features/welcome/WelcomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/signin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet =
            constraints.maxWidth > 600; // Adjust breakpoint as needed

        return ScreenUtilInit(
          designSize: isTablet ? const Size(768, 1024) : const Size(375, 812),
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
                '/loading':
                    (context) => const HealthAssessmentLoading(
                      loadingDuration: Duration(seconds: 5),
                      nextScreen: HealthAssessmentScore(score: 22),
                    ),
                '/avatar': (context) => const HealthAssessmentAvatar(),
                '/dashboard':
                    (context) => const HealthAssessmentScore(score: 22),
                '/questions/weight': (context) => const WeightInputPage(),
                '/questions/height': (context) => const HeightInputPage(),
              },
            );
          },
        );
      },
    );
  }
}
