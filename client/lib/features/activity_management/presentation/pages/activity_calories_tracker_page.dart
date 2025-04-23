import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:client/widgets/ActivityHeader.dart';
import 'package:client/features/activity_management/presentation/providers/activity_calories_provider.dart';
import 'package:client/features/activity_management/presentation/widgets/activity_item_widget.dart';
import 'package:client/features/activity_management/presentation/widgets/calories_chart_widget.dart';
import 'package:client/features/activity_management/domain/usecases/get_activities_usecase.dart';
import 'package:client/features/activity_management/domain/usecases/get_total_calories_burned_usecase.dart';
import 'package:client/features/activity_management/data/repositories/activity_calories_repository_impl.dart';
import 'package:client/features/activity_management/data/datasources/activity_calories_remote_datasource.dart';
import 'package:client/core/network/api_client.dart';
import 'package:client/core/network/network_info.dart';

class ActivityCaloriesTrackerPage extends StatelessWidget {
  const ActivityCaloriesTrackerPage({Key? key}) : super(key: key);

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

        final networkInfo = NetworkInfoImpl(connectionChecker);

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
  @override
  void initState() {
    super.initState();
    // Load activities when the page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityCaloriesProvider>().loadActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3F8),
      body: SafeArea(
        child: Consumer<ActivityCaloriesProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return _buildLoader();
            }

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    ActivityHeader(
                      name: 'Calories',
                      onTrack: 'On Track',
                      onBackPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(height: 24.h),
                    _buildCaloriesSummary(provider.totalCaloriesBurned),
                    SizedBox(height: 24.h),
                    const CaloriesChartWidget(),
                    SizedBox(height: 24.h),
                    _buildActivitiesSection(provider.activities),
                  ],
                ),
              ),
            );
          },
        ),
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
              'Loading activities...',
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

  Widget _buildCaloriesSummary(double totalCaloriesBurned) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today, you just burned',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              totalCaloriesBurned.toStringAsFixed(0),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 40.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1F36),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'kcal',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivitiesSection(List activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.r)),
          ),
          color: Colors.white,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 200.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    'Activities',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child:
                      activities.isEmpty
                          ? Center(
                            child: Text(
                              "No activities found",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.sp,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          : Column(
                            children:
                                activities.map<Widget>((activity) {
                                  return Column(
                                    children: [
                                      ActivityItemWidget(activity: activity),
                                      SizedBox(height: 12.h),
                                    ],
                                  );
                                }).toList(),
                          ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
