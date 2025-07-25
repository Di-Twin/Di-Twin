import 'package:client/features/auth/presentation/pages/sign_in_page.dart';
import 'package:client/features/auth/presentation/pages/sign_up_page.dart';
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
import 'package:client/features/welcome/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:client/features/dashboard/dashboard.dart';
// Import notification services
import 'package:firebase_messaging/firebase_messaging.dart';
import 'features/notification/services/socket_services.dart';
import 'features/notification/managers/notification_manager.dart';
// Import cache and sync services
import 'package:client/services/cache_service.dart';
import 'package:client/services/background_sync_service.dart';

// Import app_links
import 'package:app_links/app_links.dart';
import 'dart:async';
// Import feedback form
import 'package:client/widgets/settings/feedback_form_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:client/core/network/api_client.dart';
import 'package:client/core/network/network_info.dart';
import 'package:client/features/food_management/data/datasources/daily_food_remote_datasource.dart';
import 'package:client/features/food_management/data/repositories/daily_food_repository_impl.dart';
import 'package:client/features/food_management/domain/usecases/get_daily_food_usecase.dart';
import 'package:client/features/food_management/presentation/providers/daily_food_provider.dart';
import 'package:client/features/food_management/domain/usecases/get_daily_food_score_usecase.dart';
import 'package:client/features/food_management/domain/usecases/get_food_score_usecase.dart';
import 'package:client/features/food_management/presentation/providers/food_score_provider.dart';
import 'package:client/features/food_management/data/datasources/food_remote_datasource.dart';
import 'package:client/features/food_management/data/repositories/food_repository_impl.dart';
import 'package:client/core/network/network_checker.dart';
import 'dart:developer' as developer;
import 'package:client/features/water_intake/data/providers/water_intake_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Store pending Fitbit URI for processing when dashboard is available
Uri? pendingFitbitUri;

// Background message handler for Firebase Cloud Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Initialize Firebase if not already initialized
    await Firebase.initializeApp();

    print('Handling a background message: ${message.messageId}');

    // Process the notification
    NotificationManager.processFirebaseMessage(message);
  } catch (e) {
    print('Error in background handler: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  developer.log('✅ Firebase Initialized', name: 'Main');

  // Set background message handler for FCM
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize notification manager
  developer.log('🚀 Initializing notification service...', name: 'Main');
  try {
    await NotificationManager.initialize();
    developer.log('✅ Notification manager initialized', name: 'Main');

    // Set notification tap handler
    NotificationManager.onNotificationTap = (payload) {
      if (payload != null) {
        developer.log('Notification tapped: $payload', name: 'Main');
        // Navigate to appropriate screen based on payload
        // You can use navigatorKey.currentState?.pushNamed() here
      }
    };
  } catch (e) {
    developer.log('❌ Error initializing notification manager: $e', name: 'Main');
  }

  // Reset feedback session flag on app start
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('feedback_shown_this_session', false);

  // Create API client
  final apiClient = ApiClient(
    baseUrl: 'https://test-prod-f427.onrender.com/api',
    httpClient: http.Client(),
  );

  // Test API connection
  developer.log('🔍 Testing API connection...', name: 'Main');
  try {
    final isConnected = await NetworkChecker.isApiServerReachable(
      'https://test-prod-f427.onrender.com/api',
    );
    developer.log(
      '🔍 API connection test result: ${isConnected ? 'SUCCESS' : 'FAILED'}',
      name: 'Main',
    );

    if (!isConnected) {
      developer.log(
        '⚠️ Warning: API server appears to be unreachable. The app may not function correctly.',
        name: 'Main',
      );
    }
  } catch (e) {
    developer.log('🔍 API connection test error: $e', name: 'Main');
  }

  // Create network info
  final networkInfo = NetworkInfoImpl(
    connectionChecker: InternetConnectionChecker.createInstance(),
  );

  // Create daily food remote data source
  final dailyFoodRemoteDataSource = DailyFoodRemoteDataSourceImpl(
    apiClient: apiClient,
  );

  // Create daily food repository
  final dailyFoodRepository = DailyFoodRepositoryImpl(
    remoteDataSource: dailyFoodRemoteDataSource,
    networkInfo: networkInfo,
  );

  // Create daily food use case
  final getDailyFoodUseCase = GetDailyFoodUseCase(dailyFoodRepository);

  // Create daily food provider
  final dailyFoodProvider = DailyFoodProvider(
    getDailyFoodUseCase: getDailyFoodUseCase,
  );

  // Create food remote data source
  final foodRemoteDataSource = FoodRemoteDataSourceImpl(
    apiClient: apiClient,
    client: http.Client(),
  );

  // Create food repository
  final foodRepository = FoodRepositoryImpl(
    remoteDataSource: foodRemoteDataSource,
    networkInfo: networkInfo,
  );

  // Create food score use cases
  final getDailyFoodScoreUseCase = GetDailyFoodScoreUseCase(foodRepository);
  final getFoodScoreUseCase = GetFoodScoreUseCase(foodRepository);

  // Create food score provider
  final foodScoreProvider = FoodScoreProvider(
    getDailyFoodScoreUseCase: getDailyFoodScoreUseCase,
    getFoodScoreUseCase: getFoodScoreUseCase,
  );

  // Initialize cache service
  developer.log('🗄️ Initializing cache service...', name: 'Main');
  try {
    final cacheInfo = await CacheService.getCacheInfo();
    developer.log('✅ Cache service initialized. Info: $cacheInfo', name: 'Main');
  } catch (e) {
    developer.log('❌ Error initializing cache service: $e', name: 'Main');
  }

  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider<DailyFoodProvider>(
          create: (context) => dailyFoodProvider,
        ),
        provider.ChangeNotifierProvider<FoodScoreProvider>(
          create: (context) => foodScoreProvider,
        ),
        // Add SocketService provider
        provider.ChangeNotifierProvider<SocketService>(
          create: (context) => SocketService(),
        ),
        provider.ChangeNotifierProvider<WaterIntakeProvider>(
          create: (context) => WaterIntakeProvider()..initialize(),
        ),
      ],
      child: ProviderScope(child: const MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Create an instance of AppLinks
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  bool _isFeedbackChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initAppLinks();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        developer.log('📱 App resumed, starting background sync', name: 'Main');
        // Start background sync when app resumes
        BackgroundSyncService.instance.startBackgroundSync();
        break;
      case AppLifecycleState.paused:
        developer.log('📱 App paused', name: 'Main');
        break;
      case AppLifecycleState.detached:
        developer.log('📱 App detached, stopping background sync', name: 'Main');
        // Stop background sync when app is detached
        BackgroundSyncService.instance.stopBackgroundSync();
        break;
      default:
        break;
    }
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
        MaterialPageRoute(builder: (context) => const FeedbackFormScreen()),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    BackgroundSyncService.instance.stopBackgroundSync();
    super.dispose();
  }

  // Initialize app links and handle both initial and incoming links
  Future<void> initAppLinks() async {
    _appLinks = AppLinks();

    // Handle app links when the app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(
          (Uri uri) {
        _handleIncomingLink(uri);
      },
      onError: (Object error) {
        developer.log('❌ Error in app link stream: $error', name: 'Main');
      },
    );

    // Get the initial link if the app was launched from a link
    try {
      final appLink = await _appLinks.getInitialLink();
      if (appLink != null) {
        developer.log('🔗 Initial app link: $appLink', name: 'Main');
        _handleIncomingLink(appLink);
      }
    } catch (e) {
      developer.log('❌ Error getting initial app link: $e', name: 'Main');
    }
  }

  // Handle incoming links
  void _handleIncomingLink(Uri uri) {
    developer.log('🔗 Received app link: $uri', name: 'Main');

    if (uri.scheme == 'dtwin' && uri.host == 'fitbit-auth') {
      // Extract the authorization code
      final code = uri.queryParameters['code'];
      if (code != null) {
        developer.log('✅ Received Fitbit authorization code: $code', name: 'Main');

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
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'DTwin',
              theme: ThemeData(
                primarySwatch: Colors.blue,
                textTheme: GoogleFonts.plusJakartaSansTextTheme(),
              ),
              initialRoute: '/',
              onGenerateRoute: (settings) {
                // Handle back button prevention for dashboard
                if (settings.name == '/dashboard') {
                  return PageRouteBuilder(
                    settings: settings,
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return WillPopScope(
                        onWillPop: () async {
                          // Prevent back navigation from dashboard
                          // Show exit confirmation dialog instead
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Exit App'),
                              content: const Text('Are you sure you want to exit the app?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                    SystemNavigator.pop(); // Exit the app
                                  },
                                  child: const Text('Exit'),
                                ),
                              ],
                            ),
                          ) ?? false;
                        },
                        child: AuthGuard(child: const HomeScreen()),
                      );
                    },
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  );
                }
                return null;
              },
              routes: {
                '/': (context) => const Startpage(),
                '/welcome': (context) => const WelcomePage(),
                '/signin': (context) => const SignInPage(),
                '/signup': (context) => const SignUpPage(),
                '/questions/goal': (context) => AuthGuard(child: const HealthAssessmentGoal()),
                '/questions/weight': (context) => AuthGuard(child: const WeightInputPage()),
                '/questions/height': (context) => AuthGuard(child: const HeightInputPage()),
                '/questions/age': (context) => AuthGuard(child: const HealthAssessmentAge()),
                '/loading': (context) => AuthGuard(
                  child: const HealthAssessmentLoading(
                    loadingDuration: Duration(seconds: 5),
                    nextScreen: HealthAssessmentScore(),
                  ),
                ),
                '/avatar': (context) => AuthGuard(child: const HealthAssessmentAvatar()),
                '/questions/gender': (context) => AuthGuard(child: const HealthAssessmentGender()),
                '/questions/allergy': (context) => AuthGuard(child: const SymptomsSelectionPage()),
                '/questions/medication': (context) => AuthGuard(child: const HealthAssessmentMedication()),
                '/feedback': (context) => AuthGuard(child: const FeedbackFormScreen()),
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
