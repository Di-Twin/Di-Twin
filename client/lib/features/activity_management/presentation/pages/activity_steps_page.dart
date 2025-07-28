import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'dart:math' as math;

import 'package:client/core/network/api_client.dart';
import 'package:client/core/network/network_info.dart';
import 'package:client/features/activity_management/data/datasources/step_activity_remote_datasource.dart';
import 'package:client/features/activity_management/data/repositories/step_activity_repository_impl.dart';
import 'package:client/features/activity_management/domain/usecases/get_step_activity_usecase.dart';
import 'package:client/features/activity_management/domain/usecases/get_weekly_progress_usecase.dart';
import 'package:client/features/activity_management/presentation/providers/step_activity_provider.dart';

class ActivityStepsPage extends ConsumerStatefulWidget {
  const ActivityStepsPage({super.key});

  @override
  ConsumerState<ActivityStepsPage> createState() => _ActivityStepsPageState();
}

class _ActivityStepsPageState extends ConsumerState<ActivityStepsPage> {
  DateTime _selectedMonth = DateTime.now();
  bool _isMonthDropdownOpen = false;

  void _toggleMonthDropdown() {
    setState(() {
      _isMonthDropdownOpen = !_isMonthDropdownOpen;
    });
  }

  void _selectMonth(DateTime month) {
    setState(() {
      _selectedMonth = month;
      _isMonthDropdownOpen = false;
    });
    ref.read(stepActivityProvider.notifier).selectMonth(month);
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        stepActivityProvider.overrideWith((ref) {
          final httpClient = http.Client();
          final apiClient = ApiClient(
            baseUrl: 'https://test-prod-f427.onrender.com',
            httpClient: httpClient,
          );
          final connectionChecker = InternetConnectionChecker.createInstance();
          final networkInfo = NetworkInfoImpl(connectionChecker: connectionChecker);
          final remoteDataSource = StepActivityRemoteDataSourceImpl(
            apiClient: apiClient,
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
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: _buildBody(),
                  ),
                ],
              ),
              if (_isMonthDropdownOpen)
                Positioned(
                  top: 80.h,
                  right: 16.w,
                  child: _buildMonthDropdown(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    size: 20.sp,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                'Steps',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _toggleMonthDropdown,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16.sp,
                    color: const Color(0xFF64748B),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    _getMonthName(_selectedMonth.month),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    _isMonthDropdownOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16.sp,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer(
      builder: (context, ref, child) {
        final provider = ref.watch(stepActivityProvider);

        // Initialize data loading
        ref.listen(stepActivityProvider, (previous, next) {
          if (previous == null) {
            Future.microtask(() {
              ref.read(stepActivityProvider.notifier).loadStepActivity();
              ref.read(stepActivityProvider.notifier).loadWeeklyProgress();
            });
          }
        });

        if (provider.status == StepActivityStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF0066FF),
            ),
          );
        }

        if (provider.status == StepActivityStatus.error) {
          return _buildErrorState(provider.errorMessage);
        }

        if (provider.stepActivity == null) {
          return _buildEmptyState();
        }

        return _buildContent(provider.stepActivity!);
      },
    );
  }

  Widget _buildContent(stepActivity) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          _buildStatusBadge(stepActivity),
          SizedBox(height: 24.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepsCounter(stepActivity),
                    SizedBox(height: 32.h),
                    _buildMetricsGrid(stepActivity),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                flex: 2,
                child: _buildCircularChart(stepActivity),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          _buildWeeklyProgress(stepActivity),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(stepActivity) {
    final progress = stepActivity.currentSteps / stepActivity.goalSteps;
    String statusText;
    Color statusColor;
    Color bgColor;

    if (progress >= 1.0) {
      statusText = 'Goal Achieved';
      statusColor = const Color(0xFF059669);
      bgColor = const Color(0xFFD1FAE5);
    } else if (progress >= 0.7) {
      statusText = 'On Track';
      statusColor = const Color(0xFF0066FF);
      bgColor = const Color(0xFFDBEAFE);
    } else {
      statusText = 'Keep Going';
      statusColor = const Color(0xFFDC2626);
      bgColor = const Color(0xFFFEE2E2);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildStepsCounter(stepActivity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Steps Today',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${stepActivity.currentSteps}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 48.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
                height: 1.0,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'steps',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          'Goal: ${stepActivity.goalSteps} steps',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(stepActivity) {
    return Column(
      children: [
        _buildMetricCard(
          icon: Icons.local_fire_department,
          iconColor: const Color(0xFFDC2626),
          label: 'Calories',
          value: stepActivity.calories,
        ),
        SizedBox(height: 12.h),
        _buildMetricCard(
          icon: Icons.place,
          iconColor: const Color(0xFF0066FF),
          label: 'Distance',
          value: stepActivity.distance,
        ),
        SizedBox(height: 12.h),
        _buildMetricCard(
          icon: Icons.timer,
          iconColor: const Color(0xFF059669),
          label: 'Duration',
          value: stepActivity.duration,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularChart(stepActivity) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: CustomPaint(
        painter: CircularStepsChartPainter(
          currentSteps: stepActivity.currentSteps,
          goalSteps: stepActivity.goalSteps,
        ),
        child: Container(),
      ),
    );
  }

  Widget _buildWeeklyProgress(stepActivity) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 120.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _buildWeeklyBars(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWeeklyBars() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final mockProgress = [0.6, 0.8, 0.4, 0.9, 0.7, 0.3, 0.5]; // Mock data

    return List.generate(7, (index) {
      final isToday = index == DateTime.now().weekday - 1;

      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 24.w,
            height: (80 * mockProgress[index]).h,
            decoration: BoxDecoration(
              color: isToday
                  ? const Color(0xFF0066FF)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            days[index],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: isToday
                  ? const Color(0xFF0066FF)
                  : const Color(0xFF64748B),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMonthDropdown() {
    final months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];

    return Container(
      width: 180.w,
      constraints: BoxConstraints(maxHeight: 300.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: months.asMap().entries.map((entry) {
            final index = entry.key;
            final month = entry.value;
            final monthDate = DateTime(DateTime.now().year, index + 1);
            final isSelected = _selectedMonth.month == index + 1;

            return GestureDetector(
              onTap: () => _selectMonth(monthDate),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEDF2FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  month,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? const Color(0xFF0066FF)
                        : const Color(0xFF1E293B),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: const Color(0xFFDC2626),
            ),
            SizedBox(height: 16.h),
            Text(
              'Error Loading Data',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                ref.read(stepActivityProvider.notifier).loadStepActivity();
                ref.read(stepActivityProvider.notifier).loadWeeklyProgress();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_walk,
            size: 64.sp,
            color: const Color(0xFF94A3B8),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Data Available',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start walking to see your step data here',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

// Provider definition
final stepActivityProvider = ChangeNotifierProvider.autoDispose<StepActivityProvider>((ref) {
  throw UnimplementedError('Provider will be overridden');
});

class CircularStepsChartPainter extends CustomPainter {
  final int currentSteps;
  final int goalSteps;

  CircularStepsChartPainter({
    required this.currentSteps,
    required this.goalSteps,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 3;

    // Calculate progress
    final progress = (currentSteps / goalSteps).clamp(0.0, 1.0);

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = const Color(0xFF0066FF)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw percentage text
    final percentageText = '${(progress * 100).toInt()}%';
    final textPainter = TextPainter(
      text: TextSpan(
        text: percentageText,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E293B),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    // Draw "of goal" text
    final goalTextPainter = TextPainter(
      text: TextSpan(
        text: 'of goal',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF64748B),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    goalTextPainter.layout();
    goalTextPainter.paint(
      canvas,
      Offset(
        center.dx - goalTextPainter.width / 2,
        center.dy + 16,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CircularStepsChartPainter oldDelegate) {
    return oldDelegate.currentSteps != currentSteps ||
        oldDelegate.goalSteps != goalSteps;
  }
}
