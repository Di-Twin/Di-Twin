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
import 'package:client/features/medication_management/medication_management_screen.dart';
import 'package:client/features/welcome/StartPage.dart';
import 'package:client/features/welcome/WelcomePage.dart';
import 'package:client/widgets/dashboard/medication_section.dart';
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
// Import feedback form
import 'package:client/widgets/settings/feedback_form_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Store pending Fitbit URI for processing when dashboard is available
Uri? pendingFitbitUri;

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
  
  // Reset feedback session flag on app start
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('feedback_shown_this_session', false);

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
  bool _isFeedbackChecked = false;

  @override
  void initState() {
    super.initState();
    initAppLinks();
    
    // Register URL launcher for Fitbit domain
    // _registerCustomScheme();
  }
  
  // Check if feedback form should be shown (every 3 days)
  Future<void> _checkFeedbackReminder() async {
    // Prevent multiple checks
    if (_isFeedbackChecked) return;
    _isFeedbackChecked = true;
    
    // Wait for app to fully initialize and be stable
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final shouldShow = await FeedbackFormScreen.shouldShowFeedback();
    if (shouldShow && mounted && navigatorKey.currentContext != null) {
      // Show the feedback form
      Navigator.of(navigatorKey.currentContext!).push(
        MaterialPageRoute(builder: (context) => const FeedbackFormScreen())
      );
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
  
  // Initialize app links and handle both initial and incoming links
  Future<void> initAppLinks() async {
    _appLinks = AppLinks();

    // Handle app links when the app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleIncomingLink(uri);
    }, onError: (Object error) {
      print('Error in app link stream: $error');
    });

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
        
        // Store the URI for processing when the dashboard is available
        pendingFitbitUri = uri;
        
        // Try to find the current route
        final currentContext = navigatorKey.currentContext;
        if (currentContext != null) {
          // Check if we're on the dashboard screen
          final currentRoute = ModalRoute.of(currentContext)?.settings.name;
          if (currentRoute == '/dashboard') {
            // We're on the dashboard, try to process the callback
            processFitbitCallback(uri);
          } else {
            // We're not on the dashboard, navigate there
            Navigator.of(currentContext).pushReplacementNamed('/dashboard');
          }
        }
      }
    }
  }
  
  // Process Fitbit callback by finding the HomeScreen and calling its method
  void processFitbitCallback(Uri uri) {
    // This will be called when we're on the dashboard screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentContext = navigatorKey.currentContext;
      if (currentContext != null) {
        // Use a notification to let any listening HomeScreen know about the callback
        // This avoids the need to directly access the private state class
        FitbitCallbackNotification(uri).dispatch(currentContext);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check feedback after the first build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFeedbackReminder();
    });
    
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
                '/afdf': (context) => const Startpage(),
                '/welcome': (context) => const WelcomePage(),
                '/signin': (context) => const SignInScreen(),
                '/signup': (context) => const SignUpScreen(),
                '/questions/goal': (context) => const HealthAssessmentGoal(),
                '/questions/weight': (context) => const WeightInputPage(),
                '/questions/height': (context) => const HeightInputPage(),
                '/questions/age': (context) => const HealthAssessmentAge(),
                '/loading': (context) => const HealthAssessmentLoading(
                      loadingDuration: Duration(seconds: 5),
                      nextScreen: HealthAssessmentScore(),
                    ),
                '/avatar': (context) => const HealthAssessmentAvatar(),
                '/questions/gender': (context) => const HealthAssessmentGender(),
                '/questions/allergy': (context) => const SymptomsSelectionPage(),
                '/questions/medication': (context) => const HealthAssessmentMedication(),
                '/dashboard': (context) => const HomeScreen(),
                '/feedback': (context) => const FeedbackFormScreen(),
                // Add notification test screen route
                '/notification-test': (context) => const NotificationTestScreen(),
                // '/': (context) => const MedicationsScreen(),
              },
            );
          },
        );
      },
    );
  }
}

// Create a notification class to communicate with the HomeScreen
class FitbitCallbackNotification extends Notification {
  final Uri uri;
  
  FitbitCallbackNotification(this.uri);
}
