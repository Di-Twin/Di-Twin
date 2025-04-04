import 'package:client/features/activity_management/activity_calories.dart';
import 'package:client/features/activity_management/activity_nutrition.dart';
import 'package:client/features/activity_management/activity_stats.dart';
import 'package:client/features/activity_management/activity_steps.dart';
import 'package:client/features/activity_management/activity_today.dart';
import 'package:client/features/activity_management/activity_calories_tracker.dart';
import 'package:client/features/auth/signup.dart';
import 'package:client/features/health_assessment/health_assessment_age.dart';
import 'package:client/features/health_assessment/health_assessment_medication.dart';
import 'package:client/features/health_assessment/health_assessment_symptoms.dart';
import 'package:client/features/health_assessment/health_assessment_avatar.dart';
import 'package:client/features/health_assessment/health_assessment_gender.dart';
import 'package:client/features/health_assessment/health_assessment_goal.dart';
import 'package:client/features/health_assessment/health_assessment_loading.dart';
import 'package:client/features/health_assessment/health_assessment_height.dart';
import 'package:client/features/health_assessment/health_assessment_score.dart';
import 'package:client/features/health_assessment/health_assessment_weight.dart';
import 'package:client/features/medication_management/medication_management_add_step2.dart';
import 'package:client/features/welcome/StartPage.dart';
import 'package:client/features/welcome/WelcomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/signin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:client/features/dashboard/dashboard.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); // ✅ Unique navigator key

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
        bool isTablet = constraints.maxWidth > 600;

        return ScreenUtilInit(
          designSize: isTablet ? const Size(768, 1024) : const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              navigatorKey: navigatorKey, // ✅ Ensuring navigation key is unique
              debugShowCheckedModeBanner: false,
              title: 'DTwin',
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
                '/questions/goal': (context) => const HealthAssessmentGoal(),
                '/questions/weight': (context) => const WeightInputPage(),
                '/questions/height': (context) => const HeightInputPage(),
                '/questions/age': (context) => const HealthAssessmentAge(),
                '/loading': (context) => const HealthAssessmentLoading(
                      loadingDuration: Duration(seconds: 5),
                      nextScreen: HealthAssessmentScore(score: 22),
                    ),
                '/avatar': (context) => const HealthAssessmentAvatar(),
                '/questions/gender': (context) => const HealthAssessmentGender(),
                '/questions/allergy': (context) => const SymptomsSelectionPage(),
                '/questions/medication': (context) => const HealthAssessmentMedication(),
                '/dashboard': (context) => const HomeScreen(),
                '/dashboard/activity/today': (context) => const ActivityToday(),
                '/dashboard/activity/stats': (context) => const ActivityStats(),
                '/dashboard/activity/calories': (context) => const ActivityCalories(),
                '/dashboard/activity/calories_tracker': (context) => const ActivityCaloriesTracker(), // ✅ Fixed Typo
                '/dashboard/activity/nutrition': (context) => const ActivityNutrition(),
                '/dashboard/activity/steps': (context) => const ActivitySteps(),
                '/gggh': (context) => const AddMedicationPage(),
              },
            );
          },
        );
      },
    );
  }
}
