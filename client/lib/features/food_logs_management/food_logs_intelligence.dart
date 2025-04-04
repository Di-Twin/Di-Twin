import 'package:client/widgets/CustomActivityHeaderWidget.dart';
import 'package:flutter/material.dart';

class FoodLogsIntelligence extends StatelessWidget{
  const FoodLogsIntelligence({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomActivityHeader(
        title: 'Food Intelligence',
        badgeText: 'Healthy',
        score: '16',
        subtitle: 'You`re metabolic score',
        buttonImage: 'images/SignInAddIcon.png',
        onButtonTap: () {
          // Add button tap functionality
        },
      )

    );
  }
}