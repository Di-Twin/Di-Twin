import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

import 'package:client/core/network/api_client.dart';
import 'package:client/core/network/network_info.dart';
import 'package:client/features/activity_management/data/datasources/activity_detail_remote_datasource.dart';
import 'package:client/features/activity_management/data/models/activity_detail_model.dart';
import 'package:client/features/activity_management/data/repositories/activity_detail_repository_impl.dart';
import 'package:client/features/activity_management/domain/usecases/get_activity_detail_usecase.dart';
import 'package:client/features/activity_management/presentation/providers/activity_detail_provider.dart';
import 'package:client/features/activity_management/presentation/widgets/activity_detail_header.dart';
import 'package:client/features/activity_management/presentation/widgets/activity_metrics_card.dart';

class ActivityDetailedPage extends StatelessWidget {
  final String activityId;

  const ActivityDetailedPage({
    super.key,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final httpClient = http.Client();
        final apiClient = ApiClient(baseUrl: 'https://test-prod-f427.onrender.com', httpClient: httpClient);
        final connectionChecker = InternetConnectionChecker.createInstance();
        final networkInfo = NetworkInfoImpl(connectionChecker: connectionChecker);
        
        final remoteDataSource = ActivityDetailRemoteDataSourceImpl(
          client: httpClient,
        );
        
        final repository = ActivityDetailRepositoryImpl(
          remoteDataSource: remoteDataSource,
        );
        
        final useCase = GetActivityDetailUseCase(repository);
        
        return ActivityDetailProvider(
          getActivityDetailUseCase: useCase,
        )..loadActivityDetail(activityId);
      },
      child: _ActivityDetailedContent(),
    );
  }
}

class _ActivityDetailedContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1F36)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Activity Details',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1F36),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF1A1F36)),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: Consumer<ActivityDetailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (provider.error != null) {
            return Center(
              child: Text(
                'Error: ${provider.error}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  color: Colors.red,
                ),
              ),
            );
          }
          
          if (provider.activityDetail == null) {
            return Center(
              child: Text(
                'No activity details found',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  color: const Color(0xFF8F9BB3),
                ),
              ),
            );
          }
          
          final activity = provider.activityDetail as ActivityDetailModel;
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ActivityDetailHeader(activity: activity),
                SizedBox(height: 20.h),
                ActivityMetricsCard(activity: activity),
                SizedBox(height: 20.h),
                _buildHeartRateSection(),
                SizedBox(height: 20.h),
                _buildMapSection(),
                SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeartRateSection() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
          Text(
            'Heart Rate',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1F36),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 180.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                'Heart Rate Graph',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  color: const Color(0xFF8F9BB3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
          Text(
            'Route Map',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1F36),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                'Activity Route Map',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.sp,
                  color: const Color(0xFF8F9BB3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
