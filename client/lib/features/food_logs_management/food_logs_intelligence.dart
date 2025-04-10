import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:flutter/material.dart';

class FoodLogsIntelligence extends StatelessWidget{
  const FoodLogsIntelligence({super.key});

  void onButtonTap(BuildContext context) {
    // Add your desired functionality here
    print('Button tapped!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomActivityHeader(
        title: 'Food Intelligence',
                  badgeText: 'Healthy',
                  score: '16',
                  subtitle: 'Your Metabolic Score',
                  buttonImage: 'images/SignInAddIcon.png',
                  onButtonTap: () => onButtonTap(context),
                  backgroundColor: Color(0xFFD9EAFF),
                  backgroundImagePath: 'images/activity_header_background.png',
                  buttonColor: Color(0xFF1E293B),
                  buttonShadowColor: Color(0xFF1E293B),
                  titleTextColor: Color(0xFF1E293B),
                  scoreTextColor: Color(0xFF1E293B),
                  subtitleTextColor: Color(0xFF1E293B),
                  backButtonBorderColor: Color(0xFF1E293B),
                  badgeBackgroundColor: Colors.blue.withOpacity(0.2),
                  badgeTextColor: Colors.blue,
                  backButtonBorderWidth: 1.0,
                  bottomLeftRadius: 30,
                  bottomRightRadius: 30,
                  buttonShadowSpread: 0,
                  headerHeight: 370.0,
                  showBadge: true,
                  showMenu: false,
      )

    );
  }
}