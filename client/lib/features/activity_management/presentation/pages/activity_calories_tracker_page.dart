import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:client/features/activity_management/presentation/providers/activity_calories_provider.dart';
import 'package:client/features/activity_management/presentation/widgets/activity_item_widget.dart';
import 'package:client/features/activity_management/presentation/widgets/calories_chart_widget.dart';
import 'package:client/features/activity_management/domain/usecases/get_activities_usecase.dart';
import 'package:client/features/activity_management/domain/usecases/get_total_calories_burned_usecase.dart';
import 'package:client/features/activity_management/data/repositories/activity_calories_repository_impl.dart';
import 'package:client/features/activity_management/data/datasources/activity_calories_remote_datasource.dart';
import 'package:client/core/network/api_client.dart';
import 'package:client/core/network/network_info.dart';
import 'package:fl_chart/fl_chart.dart';

class ActivityCaloriesTrackerPage extends StatelessWidget {
  const ActivityCaloriesTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Create dependencies and provider here
    return ChangeNotifierProvider<ActivityCaloriesProvider>(
      create: (context) {
        // Create the dependencies for the provider
        final httpClient = http.Client();

        // Create the proper InternetConnectionChecker instance
        final connectionChecker = InternetConnectionChecker.createInstance();

        final apiClient = ApiClient(
          baseUrl: 'https://test-prod-f427.onrender.com',
          httpClient: httpClient,
        );

        final networkInfo = NetworkInfoImpl(connectionChecker: connectionChecker);

        final remoteDataSource = ActivityCaloriesRemoteDataSourceImpl(
          client: httpClient,
          baseUrl: 'https://test-prod-f427.onrender.com',
        );

        final repository = ActivityCaloriesRepositoryImpl(
          remoteDataSource: remoteDataSource,
        );

        final getActivitiesUseCase = GetActivitiesUseCase(repository);
        final getTotalCaloriesBurnedUseCase = GetTotalCaloriesBurnedUseCase(
          repository,
        );

        // Create and return the provider
        return ActivityCaloriesProvider(
          getActivitiesUseCase: getActivitiesUseCase,
          getTotalCaloriesBurnedUseCase: getTotalCaloriesBurnedUseCase,
        );
      },
      child: _ActivityCaloriesTrackerContent(),
    );
  }
}

class _ActivityCaloriesTrackerContent extends StatefulWidget {
  @override
  State<_ActivityCaloriesTrackerContent> createState() =>
      _ActivityCaloriesTrackerContentState();
}

class _ActivityCaloriesTrackerContentState
    extends State<_ActivityCaloriesTrackerContent> {
  DateTime _selectedDate = DateTime.now();
  DateTime _today = DateTime.now();
  Map<String, dynamic>? _healthMetrics;
  bool _isLoadingMetrics = false;

  @override
  void initState() {
    super.initState();
    // Load activities when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityCaloriesProvider>().loadActivities();
      _loadHealthMetrics();
    });
  }

  Future<void> _loadHealthMetrics() async {
    setState(() {
      _isLoadingMetrics = true;
    });

    try {
      final apiClient = ApiClient(
        baseUrl: 'https://test-prod-f427.onrender.com',
        httpClient: http.Client(),
      );

      final dateString = DateFormat('yyyy-M-d').format(_selectedDate);
      final response = await apiClient.get('/api/health-metrics?date=$dateString');

      if (response['success'] == true) {
        setState(() {
          _healthMetrics = response['data'];
        });
      }
    } catch (e) {
      print('Error loading health metrics: $e');
    } finally {
      setState(() {
        _isLoadingMetrics = false;
      });
    }
  }

  Widget _buildStatusLabels() {
    final totalCaloriesBurned = _healthMetrics?['total_calories_burnt']?.toDouble() ?? 0.0;
    final targetCalories = _healthMetrics?['target_calories']?.toDouble() ?? 2000.0;
    final progress = targetCalories > 0 ? (totalCaloriesBurned / targetCalories) : 0.0;

    String status;
    Color statusColor;

    if (progress >= 0.8) {
      status = 'Good';
      statusColor = const Color(0xFF10B981);
    } else if (progress >= 0.5) {
      status = 'Need Improvements';
      statusColor = const Color(0xFFF59E0B);
    } else {
      status = 'Bad';
      statusColor = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<ActivityCaloriesProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading || _isLoadingMetrics) {
              return _buildLoader();
            }

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12.0 : 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left, size: 24),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Calories Tracking',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: isSmallScreen ? 20 : 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildStatusLabels(),

                    const SizedBox(height: 16),

                    _buildCaloriesCard(isSmallScreen),

                    const SizedBox(height: 16),

                    _buildActivitiesSection(provider.activities),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCaloriesCard(bool isSmallScreen) {
    final totalCaloriesBurned = _healthMetrics?['total_calories_burnt']?.toDouble() ?? 0.0;
    final targetCalories = _healthMetrics?['target_calories']?.toDouble() ?? 2000.0;
    final progress = targetCalories > 0 ? (totalCaloriesBurned / targetCalories).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Your Calories',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),

          const SizedBox(height: 8),

          // Large calories value
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  totalCaloriesBurned.toStringAsFixed(0),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'kcal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Metrics row
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Burned',
                  '${totalCaloriesBurned.toStringAsFixed(0)} kcal',
                  const Color(0xFF10B981),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.shade200,
              ),
              Expanded(
                child: _buildMetricItem(
                  'Target',
                  '${targetCalories.toStringAsFixed(0)} kcal',
                  const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48.w,
            height: 48.w,
            child: CircularProgressIndicator(
              strokeWidth: 3.w,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF0066FF),
              ),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          SizedBox(height: 16.h),
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              'Loading calories data...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'This may take a moment',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection(List activities) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Activities',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${activities.length} Activities',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCaloriesDifferenceChart(),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          activities.isEmpty
              ? Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                Icon(
                  Icons.fitness_center_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  "No activities found",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  "Start tracking your activities",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
              : Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: activities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ActivityItemWidget(activity: activities[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesDifferenceChart() {
    final burnedCalories = _healthMetrics?['calories_burned']?.toDouble() ?? 0.0;
    final targetCalories = _healthMetrics?['target_calories']?.toDouble() ?? 2000.0;
    final difference = burnedCalories - (targetCalories * 0.3); // Assuming 30% of target should be burned

    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B82F6).withOpacity(0.1),
            const Color(0xFF10B981).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Calories Balance',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  difference >= 0 ? '+${difference.toInt()}' : '${difference.toInt()}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: difference >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  ),
                ),
                Text(
                  difference >= 0 ? 'Surplus' : 'Deficit',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 80,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 0),
                        FlSpot(1, difference / 100),
                        FlSpot(2, (difference * 1.2) / 100),
                        FlSpot(3, (difference * 0.8) / 100),
                        FlSpot(4, difference / 100),
                      ],
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: difference >= 0
                            ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                            : [const Color(0xFFEF4444), const Color(0xFFF87171)],
                      ),
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: difference >= 0
                              ? [const Color(0xFF10B981).withOpacity(0.3), Colors.transparent]
                              : [const Color(0xFFEF4444).withOpacity(0.3), Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
