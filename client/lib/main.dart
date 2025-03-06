import 'package:client/pages/AuthPages/signup.dart';
import 'package:client/pages/OnboardingPages/StartPage.dart';
import 'package:client/pages/OnboardingPages/WelcomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/AuthPages/signin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Base design size (adjust if needed)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child){
        return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Sign In',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.plusJakartaSansTextTheme()
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Startpage(),
        '/welcome': (context) => const WelcomePage(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
      }
  );
  }
}
