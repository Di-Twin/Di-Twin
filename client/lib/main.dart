import 'package:client/features/activity_management/activity_calories.dart';
import 'package:client/features/activity_management/activity_nutrition.dart';
import 'package:client/features/activity_management/activity_stats.dart';
import 'package:client/features/activity_management/activity_steps.dart';
import 'package:client/features/activity_management/activity_today.dart';
import 'package:client/features/activity_management/activity_calories_tracker.dart';
import 'package:client/features/auth/signup.dart';
import 'package:client/features/food_logs_management/food_logs_intelligence.dart';
import 'package:client/features/food_logs_management/food_logs_nutrition_tracker.dart';
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
import 'package:client/features/welcome/StartPage.dart';
import 'package:client/features/welcome/WelcomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/signin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:client/features/dashboard/dashboard.dart';

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
                '/aoihdfawpoin': (context) => const Startpage(),
                '/welcome': (context) => const WelcomePage(),
                '/signin': (context) => const SignInScreen(),
                '/signup': (context) => const SignUpScreen(),
                '/questions/goal':
                    (context) => PopScope(
                      canPop: false, // Prevents back navigation
                      child: const HealthAssessmentGoal(),
                    ),
                '/questions/weight':
                    (context) =>
                        PopScope(canPop: false, child: const WeightInputPage()),
                '/questions/height':
                    (context) =>
                        PopScope(canPop: false, child: const HeightInputPage()),
                '/questions/age':
                    (context) => 
                        PopScope(canPop: false, child: const HealthAssessmentAge()),
                '/loading':
                    (context) => PopScope(
                      canPop: false,
                      child: const HealthAssessmentLoading(
                        loadingDuration: Duration(seconds: 5),
                        nextScreen: HealthAssessmentScore(score: 22),
                      ),
                    ),
                '/avatar':
                    (context) => PopScope(
                      canPop: false,
                      child: const HealthAssessmentAvatar(),
                    ),
                '/questions/gender': (context) =>  const HealthAssessmentGender(),
                '/questions/allergy': (context) => const SymptomsSelectionPage(),
                '/questions/medication': (context) => const HealthAssessmentMedication(),
                '/dashboard': (context) => const HomeScreen(),
                '/dashboard/activity/today': (context) => const ActivityToday(),
                '/dashboard/activity/stats': (context) => ActivityStats(),
                '/dashboard/activity/calories': (context) => const ActivityCalories(),
                '/dashboard/activity/calroies_tracker': (context) =>  ActivityCaloriesTracker(),
                '/dashboard/activity/nutrition': (context) => const ActivityNutrition(),
                '/dashboard/activity/steps': (context) => const ActivitySteps(),
                '/fhdasupihfas': (context) => FoodLogsIntelligence(),
                '/': (context) => const FoodLogsNutritionTracker()
              },
              
            );
          },
        );
      },
    );
  }
}
