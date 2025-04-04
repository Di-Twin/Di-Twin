import 'package:flutter/material.dart';
import 'package:health/health.dart'; // Import Health package
import 'package:permission_handler/permission_handler.dart';
import 'package:client/widgets/dashboard/app_header.dart';
import 'package:client/widgets/dashboard/health_score_card.dart';
import 'package:client/widgets/dashboard/health_metrics_section.dart';
import 'package:client/widgets/dashboard/fitness_tracker_section.dart';
import 'package:client/widgets/dashboard/medication_section.dart';
import 'package:client/widgets/dashboard/bottom_navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Health? health; // Changed from HealthFactory to Health
  Map<String, dynamic> healthData = {}; // Store fetched health data

  @override
  void initState() {
    super.initState();
    health = Health(); // Changed from HealthFactory() to Health()
    requestHealthPermissions();
  }

  /// **Request Health Permissions**
  Future<void> requestHealthPermissions() async {
    var status = await Permission.activityRecognition.request();

    if (status.isGranted) {
      print("✅ Health permissions granted");
      fetchHealthData();
    } else {
      print("❌ Health permissions denied.");
    }
  }

  /// **Fetch Health Data**
  Future<void> fetchHealthData() async {
    if (health == null) return;

    List<HealthDataType> types = [
      HealthDataType.HEART_RATE,
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    ];

    bool requested = await health!.requestAuthorization(types);

    if (requested) {
      try {
        // Using named parameters instead of positional parameters
        List<HealthDataPoint> data = await health!.getHealthDataFromTypes(
          types: types,
          startTime: DateTime.now().subtract(const Duration(days: 1)),
          endTime: DateTime.now(),
        );

        Map<String, dynamic> parsedData = {};
        for (var point in data) {
          parsedData[point.typeString] = "${point.value} ${point.unit}";
          print("🩺 ${point.typeString}: ${point.value} ${point.unit}");
        }

        setState(() {
          healthData = parsedData;
        });
      } catch (e) {
        print("❌ Error fetching health data: $e");
      }
    } else {
      print("❌ Authorization not granted.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [SliverToBoxAdapter(child: SafeArea(child: AppHeader()))];
        },
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            const SizedBox(height: 20),
            const HealthScoreCard(),
            const SizedBox(height: 20),
            HealthMetricsSection(), // Added healthData parameter
            const SizedBox(height: 20),
            const FitnessTrackerSection(),
            const SizedBox(height: 20),
            const MedicationSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),

      /// **Bottom Navigation Bar**
      bottomNavigationBar: const BottomNavigation(),

      /// **Custom Floating Action Button for Refreshing Data**
      floatingActionButton: FloatingActionButton(
        onPressed: fetchHealthData,
        backgroundColor: const Color(0xFF2563EB),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}