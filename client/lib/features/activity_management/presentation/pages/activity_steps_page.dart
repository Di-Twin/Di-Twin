import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:client/core/network/api_client.dart';
import 'package:client/core/network/network_info.dart';
import 'package:client/features/activity_management/data/datasources/step_activity_remote_datasource.dart';
import 'package:client/features/activity_management/data/repositories/step_activity_repository_impl.dart';
import 'package:client/features/activity_management/domain/usecases/get_step_activity_usecase.dart';
import 'package:client/features/activity_management/domain/usecases/get_weekly_progress_usecase.dart';
import 'package:client/features/activity_management/presentation/providers/step_activity_provider.dart';
import 'package:client/features/activity_management/presentation/widgets/metric_card.dart';
import 'package:client/features/activity_management/presentation/widgets/month_selection_drawer.dart';
import 'package:client/features/activity_management/presentation/widgets/step_progress_card.dart';
import 'package:client/features/activity_management/presentation/widgets/weekly_progress_chart.dart';

class ActivityStepsPage extends ConsumerStatefulWidget {
  const ActivityStepsPage({super.key});

  @override
  ConsumerState<ActivityStepsPage> createState() => _ActivityStepsPageState();
}

class _ActivityStepsPageState extends ConsumerState<ActivityStepsPage>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _drawerAnimationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for drawer
    _drawerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _drawerAnimationController.dispose();
    super.dispose();
  }

  void _showMonthSelectionDrawer() {
    _drawerAnimationController.forward();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            final provider = ref.watch(stepActivityProvider);
            return MonthSelectionDrawer(
              selectedMonth: provider.selectedMonth,
              onMonthSelected: (month) {
                ref.read(stepActivityProvider.notifier).selectMonth(month);
              },
              drawerAnimationController: _drawerAnimationController,
            );
          },
        ),
      ),
    ).then((_) {
      _drawerAnimationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        stepActivityProvider.overrideWith((ref) {
          // Set up dependencies
          final httpClient = http.Client();
          final apiClient = ApiClient(
            baseUrl: 'https://test-prod-f427.onrender.com',
            httpClient: httpClient,
          );
          final connectionChecker = InternetConnectionChecker.createInstance();
          final networkInfo = NetworkInfoImpl(connectionChecker);
          final remoteDataSource = StepActivityRemoteDataSourceImpl(
            client: httpClient,
            baseUrl: 'https://test-prod-f427.onrender.com',
          );
          final repository = StepActivityRepositoryImpl(
            remoteDataSource: remoteDataSource,
            networkInfo: networkInfo,
          );
          final getStepActivityUseCase = GetStepActivityUseCase(repository);
          final getWeeklyProgressUseCase = GetWeeklyProgressUseCase(repository);

          return StepActivityProvider(
            getStepActivityUseCase: getStepActivityUseCase,
            getWeeklyProgressUseCase: getWeeklyProgressUseCase,
          );
        }),
      ],
      child: _ActivityStepsContent(
        showMonthSelectionDrawer: _showMonthSelectionDrawer,
      ),
    );
  }
}

// Provider definition
final stepActivityProvider = ChangeNotifierProvider.autoDispose<StepActivityProvider>((ref) {
  throw UnimplementedError('Provider will be overridden');
});

class _ActivityStepsContent extends ConsumerStatefulWidget {
  final VoidCallback showMonthSelectionDrawer;

  const _ActivityStepsContent({
    required this.showMonthSelectionDrawer,
  });

  @override
  ConsumerState<_ActivityStepsContent> createState() => _ActivityStepsContentState();
}

class _ActivityStepsContentState extends ConsumerState<_ActivityStepsContent> {
  @override
  void initState() {
    super.initState();
    // Load data when the widget is first created
    Future.microtask(() {
      ref.read(stepActivityProvider.notifier).loadStepActivity();
      ref.read(stepActivityProvider.notifier).loadWeeklyProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(stepActivityProvider);
    final stepActivity = provider.stepActivity;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            if (provider.status == StepActivityStatus.loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (provider.status == StepActivityStatus.error)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        provider.errorMessage,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(stepActivityProvider.notifier).loadStepActivity();
                          ref.read(stepActivityProvider.notifier).loadWeeklyProgress();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (stepActivity != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24.h),
                        _buildTodayStepsSection(stepActivity.currentSteps),
                        SizedBox(height: 24.h),
                        StepProgressCard(
                          currentSteps: stepActivity.currentSteps,
                          goalSteps: stepActivity.goalSteps,
                        ),
                        SizedBox(height: 24.h),
                        _buildMetricsRow(
                          calories: stepActivity.calories,
                          distance: stepActivity.distance,
                          duration: stepActivity.duration,
                        ),
                        SizedBox(height: 32.h),
                        _buildProgressSection(),
                        SizedBox(height: 16.h),
                        WeeklyProgressChart(
                          weeklyProgress: stepActivity.weeklyProgress,
                          selectedWeek: provider.selectedWeek,
                          onWeekChanged: (week) {
                            ref.read(stepActivityProvider.notifier).selectWeek(week);
                          },
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text('No data available'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFDFE4EC), width: 1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Icon(
                  Icons.chevron_left,
                  size: 24.sp,
                  color: const Color(0xFF1A1F36),
                ),
              ),
            ),
          ),

          // Title
          Text(
            'Steps',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1F36),
            ),
          ),

          // Status pill
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFD9E4F5),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'On Track',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0066FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayStepsSection(int currentSteps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today, you have walked',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1F36),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$currentSteps',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 64.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1F36),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'steps',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8F9BB3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsRow({
    required String calories,
    required String distance,
    required String duration,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MetricCard(
          icon: Icons.local_fire_department,
          iconColor: Colors.white,
          iconBgColor: const Color(0xFFFF5A5F),
          label: 'Calories',
          value: calories,
        ),
        MetricCard(
          icon: Icons.place,
          iconColor: Colors.white,
          iconBgColor: const Color(0xFF0066FF),
          label: 'Distance',
          value: distance,
        ),
        MetricCard(
          icon: Icons.timer,
          iconColor: Colors.white,
          iconBgColor: const Color(0xFF00B884),
          label: 'Duration',
          value: duration,
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Weekly Progress',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1F36),
          ),
        ),
        GestureDetector(
          onTap: widget.showMonthSelectionDrawer,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFDFE4EC)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16.sp,
                  color: const Color(0xFF1A1F36),
                ),
                SizedBox(width: 8.w),
                Consumer(
                  builder: (context, ref, _) {
                    final provider = ref.watch(stepActivityProvider);
                    final months = [
                      'January', 'February', 'March', 'April',
                      'May', 'June', 'July', 'August',
                      'September', 'October', 'November', 'December'
                    ];
                    return Text(
                      months[provider.selectedMonth.month - 1],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1F36),
                      ),
                    );
                  },
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16.sp,
                  color: const Color(0xFF1A1F36),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
