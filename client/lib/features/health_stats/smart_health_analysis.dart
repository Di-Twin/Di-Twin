import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmartHealthAnalysisScreen extends StatefulWidget {
  const SmartHealthAnalysisScreen({super.key});

  @override
  State<SmartHealthAnalysisScreen> createState() => _SmartHealthAnalysisScreenState();
}

class _SmartHealthAnalysisScreenState extends State<SmartHealthAnalysisScreen> {
  // Time period selection state
  String _selectedHeartRatePeriod = 'Day';
  String _selectedBloodPressurePeriod = 'Day';
  
  // Current date for API queries
  final DateTime _currentDate = DateTime.now();
  
  // Data states
  bool _isLoadingHeartRate = true;
  bool _isLoadingBloodPressure = true;
  String? _errorHeartRate;
  String? _errorBloodPressure;
  
  // Heart rate data
  int _restingHeartRate = 0;
  List<FlSpot> _heartRateSpots = [];
  
  // Blood pressure data
  int _systolicPressure = 0;
  int _diastolicPressure = 0;
  List<FlSpot> _bloodPressureSpots = [];
  
  @override
  void initState() {
    super.initState();
    _fetchData();
  }
  
  // Fetch data based on current selections
  Future<void> _fetchData() async {
    _fetchHeartRateData();
    _fetchBloodPressureData();
  }
  
  // Format date for API query
  String _formatDateForQuery(DateTime date) {
    return DateFormat('yyyy-M-d').format(date);
  }
  
  // Get access token from shared preferences
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }
  
  // Fetch heart rate data
  Future<void> _fetchHeartRateData() async {
    setState(() {
      _isLoadingHeartRate = true;
      _errorHeartRate = null;
    });
    
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("No access token found");
      }
      
      // Construct query params based on selected time period
      String dateParam = _formatDateForQuery(_currentDate);
      
      final response = await http.get(
        Uri.parse('${_getBaseUrl()}/api/health-metrics/heart?date=$dateParam'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          setState(() {
            _restingHeartRate = data['data']['resting_heart_rate'] ?? 0;
            
            // Parse heart rate data for graph
            final heartRateData = data['data']['heart_rate_data'] as List;
            _heartRateSpots = _parseHeartRateData(heartRateData);
            
            _isLoadingHeartRate = false;
          });
        } else {
          throw Exception(data['message'] ?? "Failed to load heart rate data");
        }
      } else {
        throw Exception("Failed to load heart rate data: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoadingHeartRate = false;
        _errorHeartRate = e.toString();
      });
    }
  }
  
  // Parse heart rate data for chart
  List<FlSpot> _parseHeartRateData(List heartRateData) {
    List<FlSpot> spots = [];
    
    for (int i = 0; i < heartRateData.length; i++) {
      final item = heartRateData[i];
      final timeString = item['time'] as String;
      final value = item['value'] as int;
      
      // Convert time string to hours for x-axis
      final timeParts = timeString.split(':');
      final hours = int.parse(timeParts[0]);
      final minutes = int.parse(timeParts[1]);
      final timeAsDecimal = hours + (minutes / 60.0);
      
      spots.add(FlSpot(timeAsDecimal, value.toDouble()));
    }
    
    return spots;
  }
  
  // Fetch blood pressure data
  Future<void> _fetchBloodPressureData() async {
    setState(() {
      _isLoadingBloodPressure = true;
      _errorBloodPressure = null;
    });
    
    try {
      final token = await _getAccessToken();
      if (token == null) {
        throw Exception("No access token found");
      }
      
      // Construct query params based on selected time period
      String dateParam = _formatDateForQuery(_currentDate);
      
      final response = await http.get(
        Uri.parse('${_getBaseUrl()}/api/health-metrics?date=$dateParam'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          setState(() {
            // For demo purposes, we're parsing the BP value if it exists
            // In a real app, you might need to handle this differently based on your API
            if (data['data']['bp'] != null) {
              final bp = data['data']['bp'].toString().split('/');
              _systolicPressure = int.tryParse(bp[0]) ?? 120;
              _diastolicPressure = int.tryParse(bp[1]) ?? 80;
            } else {
              // Default values if BP is not available
              _systolicPressure = 120;
              _diastolicPressure = 80;
            }
            
            // In a real app, you would generate blood pressure spots from actual data
            // This is a placeholder that generates mock data points
            _bloodPressureSpots = _generateMockBloodPressureData();
            
            _isLoadingBloodPressure = false;
          });
        } else {
          throw Exception(data['message'] ?? "Failed to load blood pressure data");
        }
      } else {
        throw Exception("Failed to load blood pressure data: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoadingBloodPressure = false;
        _errorBloodPressure = e.toString();
      });
    }
  }
  
  // Generate mock blood pressure data for display
  // In a real app, you would parse this from your API response
  List<FlSpot> _generateMockBloodPressureData() {
    List<FlSpot> spots = [];
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    
    for (int i = 6; i < 22; i++) {
      spots.add(FlSpot(
        i.toDouble(), 
        _systolicPressure + (random % 20 - 10 + i % 5).toDouble()
      ));
    }
    
    return spots;
  }
  
  // Get base URL for API requests
  String _getBaseUrl() {
    // Replace with your actual API base URL
    return 'https://api.yourhealth.com';
  }
  
  // Handle time period selection for heart rate
  void _selectHeartRatePeriod(String period) {
    if (_selectedHeartRatePeriod != period) {
      setState(() {
        _selectedHeartRatePeriod = period;
      });
      _fetchHeartRateData();
    }
  }
  
  // Handle time period selection for blood pressure
  void _selectBloodPressurePeriod(String period) {
    if (_selectedBloodPressurePeriod != period) {
      setState(() {
        _selectedBloodPressurePeriod = period;
      });
      _fetchBloodPressureData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.chevron_left,
                            color: Color(0xFF1E293B),
                            size: 28,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Title
                    Text(
                      'Smart Health Analysis',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const Spacer(),

                    // Menu
                    const Icon(
                      Icons.more_horiz,
                      color: Color(0xFF64748B),
                      size: 24,
                    ),
                  ],
                ),
              ),

              // Heart Rate Stats
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heart Rate Title
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFECDCD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.favorite,
                              color: Color(0xFFEF4444),
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Heart Rate Stats',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Heart Rate Value - Centered
                    Center(
                      child: _isLoadingHeartRate 
                      ? const CircularProgressIndicator(color: Color(0xFFEF4444))
                      : _errorHeartRate != null
                        ? Text(
                            'Error loading data',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFECDCD),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.favorite,
                                    color: Color(0xFFEF4444),
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '$_restingHeartRate',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 64,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  'BPM',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ),

                    const SizedBox(height: 24),

                    // Time Period Selector - Heart Rate
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildTimePeriodButton('Day', _selectedHeartRatePeriod == 'Day', () => _selectHeartRatePeriod('Day')),
                          _buildTimePeriodButton('Week', _selectedHeartRatePeriod == 'Week', () => _selectHeartRatePeriod('Week')),
                          _buildTimePeriodButton('Month', _selectedHeartRatePeriod == 'Month', () => _selectHeartRatePeriod('Month')),
                          _buildTimePeriodButton('3 Month', _selectedHeartRatePeriod == '3 Month', () => _selectHeartRatePeriod('3 Month')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Heart Rate Graph
                    Container(
                      height: 200,
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: _isLoadingHeartRate 
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFEF4444)))
                      : _errorHeartRate != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'Failed to load data',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_errorHeartRate != null && _errorHeartRate!.isNotEmpty)
                                  Text(
                                    _errorHeartRate!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: Colors.red[300],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                              ],
                            ),
                          )
                        : _heartRateSpots.isEmpty
                          ? Center(
                              child: Text(
                                'No heart rate data available',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  horizontalInterval: 20,
                                  verticalInterval: 2,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: const Color(0xFFE2E8F0),
                                      strokeWidth: 1,
                                    );
                                  },
                                  getDrawingVerticalLine: (value) {
                                    return FlLine(
                                      color: const Color(0xFFE2E8F0),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        String text = '';
                                        if (value % 2 == 0 && value >= 6 && value <= 22) {
                                          int hour = value.toInt();
                                          text = hour > 12 ? '${hour - 12}PM' : '${hour}AM';
                                        }
                                        return Text(
                                          text,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '${value.toInt()}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                minX: 6,
                                maxX: 22,
                                minY: 50,
                                maxY: 170,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _heartRateSpots,
                                    isCurved: true,
                                    color: const Color(0xFFEF4444),
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: false,
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: const Color(0xFFFECDCD).withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Blood Pressure Stats
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Blood Pressure Title
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFBFDBFE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.water_drop,
                              color: Color(0xFF2563EB),
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'SPO2 Stats',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Blood Pressure Value - Centered
                    Center(
                      child: _isLoadingBloodPressure 
                      ? const CircularProgressIndicator(color: Color(0xFF2563EB))
                      : _errorBloodPressure != null
                        ? Text(
                            'Error loading data',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBFDBFE),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.water_drop,
                                    color: Color(0xFF2563EB),
                                    size: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '$_systolicPressure/$_diastolicPressure',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  'mmHg',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    ),

                    const SizedBox(height: 24),

                    // Time Period Selector - Blood Pressure
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildTimePeriodButton('Day', _selectedBloodPressurePeriod == 'Day', () => _selectBloodPressurePeriod('Day')),
                          _buildTimePeriodButton('Week', _selectedBloodPressurePeriod == 'Week', () => _selectBloodPressurePeriod('Week')),
                          _buildTimePeriodButton('Month', _selectedBloodPressurePeriod == 'Month', () => _selectBloodPressurePeriod('Month')),
                          _buildTimePeriodButton('3 Month', _selectedBloodPressurePeriod == '3 Month', () => _selectBloodPressurePeriod('3 Month')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Blood Pressure Graph
                    Container(
                      height: 200,
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: _isLoadingBloodPressure 
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
                      : _errorBloodPressure != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'Failed to load data',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_errorBloodPressure != null && _errorBloodPressure!.isNotEmpty)
                                  Text(
                                    _errorBloodPressure!,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: Colors.red[300],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                              ],
                            ),
                          )
                        : _bloodPressureSpots.isEmpty
                          ? Center(
                              child: Text(
                                'No blood pressure data available',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  horizontalInterval: 20,
                                  verticalInterval: 2,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: const Color(0xFFE2E8F0),
                                      strokeWidth: 1,
                                    );
                                  },
                                  getDrawingVerticalLine: (value) {
                                    return FlLine(
                                      color: const Color(0xFFE2E8F0),
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        String text = '';
                                        if (value % 2 == 0 && value >= 6 && value <= 22) {
                                          int hour = value.toInt();
                                          text = hour > 12 ? '${hour - 12}PM' : '${hour}AM';
                                        }
                                        return Text(
                                          text,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 20,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '${value.toInt()}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                minX: 6,
                                maxX: 22,
                                minY: 60,
                                maxY: 180,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _bloodPressureSpots,
                                    isCurved: true,
                                    color: const Color(0xFF2563EB),
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: false,
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: const Color(0xFFBFDBFE).withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriodButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}