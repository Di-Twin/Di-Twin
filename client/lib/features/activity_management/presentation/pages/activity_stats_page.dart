import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/activity_stats_remote_datasource.dart';
import '../../data/repositories/activity_stats_repository_impl.dart';
import '../../domain/usecases/get_activity_stats_usecase.dart';
import '../providers/activity_stats_provider.dart';
import '../widgets/activity_legend.dart';
import '../widgets/animated_activity_block.dart';
import '../widgets/decorative_block.dart';

class ActivityStatsPage extends StatelessWidget {
  const ActivityStatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set up dependencies
    final httpClient = http.Client();
    final apiClient = ApiClient(baseUrl: 'https://test-prod-f427.onrender.com', httpClient: httpClient);
    final connectionChecker = InternetConnectionChecker.createInstance();
    final networkInfo = NetworkInfoImpl(connectionChecker);
    final remoteDataSource = ActivityStatsRemoteDataSourceImpl(
      client: httpClient,
      baseUrl: 'https://test-prod-f427.onrender.com',
    );
    final repository = ActivityStatsRepositoryImpl(
      remoteDataSource: remoteDataSource,
      networkInfo: networkInfo,
    );
    final useCase = GetActivityStatsUseCase(repository);

    return ChangeNotifierProvider(
      create: (_) => ActivityStatsProvider(getActivityStatsUseCase: useCase)..loadActivityStats(),
      child: const _ActivityStatsContent(),
    );
  }
}

class _ActivityStatsContent extends StatefulWidget {
  const _ActivityStatsContent({Key? key}) : super(key: key);

  @override
  State<_ActivityStatsContent> createState() => _ActivityStatsContentState();
}

class _ActivityStatsContentState extends State<_ActivityStatsContent> with TickerProviderStateMixin {
  // Animation controllers for each activity block
  late final Map<String, AnimationController> _controllers = {};
  late final List<AnimationController> _decorativeControllers = [];
  
  // Additional decorative blocks
  final List<Map<String, dynamic>> _decorativeBlocks = [];
  final int _numDecorativeBlocks = 8;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    
    // Generate decorative blocks with random positions
    for (int i = 0; i < _numDecorativeBlocks; i++) {
      _decorativeBlocks.add({
        'xPos': 0.1 + _random.nextDouble() * 0.8, // Random x position between 0.1 and 0.9
        'yPos': 0.1 + _random.nextDouble() * 0.8, // Random y position between 0.1 and 0.9
        'size': 0.05 + _random.nextDouble() * 0.1, // Random size between 0.05 and 0.15
        'rotation': (_random.nextDouble() - 0.5) * 0.8, // Random rotation between -0.4 and 0.4
      });
      
      _decorativeControllers.add(
        AnimationController(
          duration: Duration(milliseconds: 600 + _random.nextInt(800)),
          vsync: this,
        ),
      );
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final provider = Provider.of<ActivityStatsProvider>(context);
    
    if (provider.status == ActivityStatsStatus.loaded && _controllers.isEmpty) {
      // Initialize animation controllers for activity blocks
      for (var stat in provider.stats) {
        _controllers[stat.name] = AnimationController(
          duration: Duration(milliseconds: 800 + _random.nextInt(700)),
          vsync: this,
        );
      }
      
      // Start animations with staggered delays
      _startAnimations();
    }
  }
  
  void _startAnimations() async {
    // Start activity block animations with staggered delay
    int delay = 100;
    _controllers.forEach((key, controller) async {
      await Future.delayed(Duration(milliseconds: delay));
      controller.forward();
      delay += 200;
    });
    
    // Start decorative block animations with staggered delay
    delay = 150;
    for (var controller in _decorativeControllers) {
      await Future.delayed(Duration(milliseconds: delay));
      controller.forward();
      delay += 150;
    }
  }

  @override
  void dispose() {
    // Dispose all animation controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var controller in _decorativeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFF1F5F9),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 20.sp, color: Colors.black54),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.more_horiz, size: 24.sp, color: Colors.black54),
                onPressed: () {},
              ),
            ],
          ),
          body: Consumer<ActivityStatsProvider>(
            builder: (context, provider, child) {
              if (provider.status == ActivityStatsStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              } else if (provider.status == ActivityStatsStatus.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${provider.errorMessage}',
                        style: TextStyle(color: Colors.red),
                      ),
                      ElevatedButton(
                        onPressed: () => provider.loadActivityStats(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              } else if (provider.status == ActivityStatsStatus.loaded) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      Text(
                        'Activity Stats',
                        style: GoogleFonts.poppins(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ActivityLegend(activities: provider.stats),
                      SizedBox(height: 24.h),
                      _buildActivityBlocks(provider),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActivityBlocks(ActivityStatsProvider provider) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final maxHeight = constraints.maxHeight;
          
          // Map of activity names to their positions and sizes
          final activityPositions = {
            'Jogging': {
              'left': maxWidth * 0.05,
              'top': maxWidth * 0.45,
              'targetTop': maxHeight * 0.25,
              'width': maxWidth * 0.42,
              'height': maxWidth * 0.42,
              'rotation': -0.1,
            },
            'Tennis': {
              'right': maxWidth * 0.08,
              'top': -maxWidth * 0.28,
              'targetTop': maxHeight * 0.2,
              'width': maxWidth * 0.3,
              'height': maxWidth * 0.3,
              'rotation': 0.15,
            },
            'Biking': {
              'right': maxWidth * 0.05,
              'top': -maxWidth * 0.3,
              'targetTop': maxHeight * 0.4,
              'width': maxWidth * 0.3,
              'height': maxWidth * 0.3,
              'rotation': 0.2,
            },
            'Hiking': {
              'left': maxWidth * 0.06,
              'top': -maxWidth * 0.2,
              'targetTop': maxHeight * 0.65,
              'width': maxWidth * 0.2,
              'height': maxWidth * 0.2,
              'rotation': -0.15,
            },
            'Yoga': {
              'left': maxWidth * 0.35,
              'top': -maxWidth * 0.55,
              'targetTop': maxHeight * 0.55,
              'width': maxWidth * 0.55,
              'height': maxWidth * 0.55,
              'rotation': 0.0,
            },
          };
          
          return Stack(
            children: [
              // Decorative blocks
              ..._buildDecorativeBlocks(maxWidth, maxHeight),
              
              // Activity blocks
              ...provider.stats.map((activity) {
                final position = activityPositions[activity.name];
                if (position != null && _controllers.containsKey(activity.name)) {
                  return AnimatedActivityBlock(
                    activity: activity.name,
                    value: activity.value,
                    color: activity.color,
                    controller: _controllers[activity.name]!,
                    left: position['left'] as double?,
                    right: position['right'] as double?,
                    top: position['top'] as double? ?? 0.0,
                    targetTop: position['targetTop'] as double? ?? 0.0,
                    width: position['width'] as double? ?? 100.0,
                    height: position['height'] as double? ?? 100.0,
                    rotation: position['rotation'] as double? ?? 0.0,
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildDecorativeBlocks(double maxWidth, double maxHeight) {
    List<Widget> blocks = [];
    
    for (int i = 0; i < _decorativeBlocks.length; i++) {
      final block = _decorativeBlocks[i];
      final controller = _decorativeControllers[i];
      
      blocks.add(
        DecorativeBlock(
          controller: controller,
          xPos: block['xPos'] as double,
          yPos: block['yPos'] as double,
          size: block['size'] as double,
          rotation: block['rotation'] as double,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
      );
    }
    
    return blocks;
  }
}
