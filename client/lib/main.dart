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
import 'package:client/features/welcome/StartPage.dart';
import 'package:client/features/welcome/WelcomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/signin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:client/features/dashboard/dashboard.dart';
// Import notification service
import 'package:client/services/notification/notification_service.dart';
// Import notification test screen
import 'package:client/screens/notification_test_screen.dart';
// Import app_links
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
// Import feedback form
import 'package:client/widgets/settings/feedback_form_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  print('✅ Firebase Initialized');

  // Initialize notification service
  final notificationService = NotificationService();

  print('🚀 Init notification service...');
  try {
    await notificationService.init();
    print('✅ Notification service initialized');
  } catch (e) {
    print('❌ Error initializing notification service: $e');
  }

  print('🔐 Requesting notification permissions...');
  try {
    await notificationService.requestPermissions();
    print('✅ Notification permissions granted');
  } catch (e) {
    print('❌ Error requesting notification permissions: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Create an instance of AppLinks
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initAppLinks();

    // Register URL launcher for Fitbit domain
    // _registerCustomScheme();

    // Check if we should show feedback form
    _checkFeedbackReminder();
  }

  // Check if feedback form should be shown (every 3 days)
  Future<void> _checkFeedbackReminder() async {
    // Wait for app to fully initialize
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shouldShow = await FeedbackFormScreen.shouldShowFeedback();
      if (shouldShow && mounted) {
        // Show the feedback form
        Navigator.of(navigatorKey.currentContext!).push(
          MaterialPageRoute(builder: (context) => const FeedbackFormScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  // Register custom URL scheme handler
  // Future<void> _registerCustomScheme() async {
  //   // This is a workaround to ensure URL launcher works properly
  //   try {
  //     // Try to launch a test URL to initialize the URL launcher
  //     final Uri testUri = Uri.parse('https://www.google.com');
  //     if (await canLaunchUrl(testUri)) {
  //       await launchUrl(testUri, mode: LaunchMode.externalApplication);
  //       print('✅ URL launcher initialized');
  //     }
  //   } catch (e) {
  //     print('❌ Error initializing URL launcher: $e');
  //   }
  // }

  // Initialize app links and handle both initial and incoming links
  Future<void> initAppLinks() async {
    _appLinks = AppLinks();

    // Handle app links when the app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleIncomingLink(uri);
      },
      onError: (Object error) {
        print('Error in app link stream: $error');
      },
    );

    // Get the initial link if the app was launched from a link
    try {
      final appLink = await _appLinks.getInitialLink();
      if (appLink != null) {
        print('Initial app link: $appLink');
        _handleIncomingLink(appLink);
      }
    } catch (e) {
      print('Error getting initial app link: $e');
    }
  }

  // Handle incoming links
  void _handleIncomingLink(Uri uri) {
    print('Received app link: $uri');

    if (uri.scheme == 'dtwin' && uri.host == 'fitbit-auth') {
      // Extract the authorization code
      final code = uri.queryParameters['code'];
      if (code != null) {
        print('Received Fitbit authorization code: $code');

        // Show a success message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navigatorKey.currentContext != null) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
              SnackBar(
                content: Text('Successfully authenticated with Fitbit'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });

        // Here you would send this code to your backend to exchange for an access token
        // For now, we'll just log it
      }
    }
  }

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
                '/loading':
                    (context) => const HealthAssessmentLoading(
                      loadingDuration: Duration(seconds: 5),
                      nextScreen: HealthAssessmentScore(),
                    ),
                '/avatar': (context) => const HealthAssessmentAvatar(),
                '/questions/gender':
                    (context) => const HealthAssessmentGender(),
                '/questions/allergy':
                    (context) => const SymptomsSelectionPage(),
                '/questions/medication':
                    (context) => const HealthAssessmentMedication(),
                '/dashboard': (context) => const HomeScreen(),
                '/feedback': (context) => const FeedbackFormScreen(),
                // Add notification test screen route
                '/notification-test':
                    (context) => const NotificationTestScreen(),
                // '/': (context) => const MedicationsScreen(),
              },
            );
          },
        );
      },
    );
  }
}
