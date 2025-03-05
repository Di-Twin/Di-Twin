import 'package:client/pages/OnboardingPages/StartPage.dart';
import 'package:client/pages/OnboardingPages/WelcomePage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide debug banner
      title: 'Flutter App',
      initialRoute: '/',
      routes: {
        '/': (context) => const Startpage(),
        '/welcome': (context) => const WelcomePage(),
      },
    );
  }
}
