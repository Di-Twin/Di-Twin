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

            return Column(
              children: [
                // Fixed header section
                Container(
                  color: const Color(0xFFF0F3F8),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ActivityHeader(
                        name: 'Calories',
                        onTrack:
                            'On Track', // dart(TODO: change this according to the user's goal which is set)
                        onBackPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8.h),
                              _buildCaloriesSummary(
                                provider.totalCaloriesBurned,
                              ),
                              SizedBox(height: 24.h),
                              const CaloriesChartWidget(),
                              SizedBox(height: 24.h),
                            ],
                          ),
                        ),
                        _buildActivitiesSection(provider.activities),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              ],
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 244, 244, 244),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Increased opacity
            blurRadius: 10, // Increased blur
            spreadRadius: 1, // Added spread
            offset: const Offset(0, 3), // Slightly increased offset
          ),
        ],
        borderRadius: BorderRadius.circular(8), // Added subtle rounded corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Text(
              'Activities',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: const Color(0xFFEEEEEE)),
          activities.isEmpty
              ? Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Text(
                  "No activities found",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16.sp,
                    color: Colors.grey,
                  ),
                ),
              )
              : Padding(
                padding: EdgeInsets.all(16.w),
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: activities.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    return ActivityItemWidget(activity: activities[index]);
                  },
                ),
              ),
        ],
      ),
    );
  }
}
