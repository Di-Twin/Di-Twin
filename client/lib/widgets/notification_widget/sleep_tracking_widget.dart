import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/providers/notification_provider.dart';

class SleepTrackingWidget extends ConsumerStatefulWidget {
  const SleepTrackingWidget({super.key});

  @override
  ConsumerState<SleepTrackingWidget> createState() => _SleepTrackingWidgetState();
}

class _SleepTrackingWidgetState extends ConsumerState<SleepTrackingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  DateTime? _startTime;
  String _elapsedTime = '00:00:00';
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Check if sleep tracking is already active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActiveTracking();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _checkActiveTracking() {
    final sleepHandler = ref.read(sleepNotificationHandlerProvider);
    if (sleepHandler.isTrackingActive) {
      setState(() {
        _startTime = sleepHandler.currentSession?.startTime;
      });
      
      // Start timer to update elapsed time
      _startElapsedTimeTimer();
    }
  }
  
  void _startElapsedTimeTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _startTime != null) {
        setState(() {
          final now = DateTime.now();
          final difference = now.difference(_startTime!);
          
          final hours = difference.inHours.toString().padLeft(2, '0');
          final minutes = (difference.inMinutes % 60).toString().padLeft(2, '0');
          final seconds = (difference.inSeconds % 60).toString().padLeft(2, '0');
          
          _elapsedTime = '$hours:$minutes:$seconds';
        });
        
        // Continue updating
        _startElapsedTimeTimer();
      }
    });
  }
  
  Future<void> _toggleSleepTracking() async {
    final sleepHandler = ref.read(sleepNotificationHandlerProvider);
    
    if (sleepHandler.isTrackingActive) {
      // Stop tracking
      await sleepHandler.stopSleepTracking();
      setState(() {
        _startTime = null;
        _elapsedTime = '00:00:00';
      });
      
      // Update provider state
      ref.read(sleepTrackingStateProvider.notifier).state = false;
      ref.read(currentSleepSessionProvider.notifier).state = null;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sleep tracking stopped. Data saved successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Start tracking
      await sleepHandler.startSleepTracking();
      setState(() {
        _startTime = DateTime.now();
      });
      
      // Start timer to update elapsed time
      _startElapsedTimeTimer();
      
      // Update provider state
      ref.read(sleepTrackingStateProvider.notifier).state = true;
      ref.read(currentSleepSessionProvider.notifier).state = {
        'startTime': _startTime!.toIso8601String(),
      };
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isTracking = _startTime != null;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTracking 
              ? [Color(0xFF3949AB), Color(0xFF1A237E)]
              : [Color(0xFF42A5F5), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isTracking 
                ? Colors.indigo.withOpacity(0.4)
                : Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleSleepTracking,
            splashColor: Colors.white24,
            highlightColor: Colors.white10,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isTracking ? 'Sleep Tracking Active' : 'Track Your Sleep',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isTracking ? _pulseAnimation.value : 1.0,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isTracking 
                                    ? Colors.red.withOpacity(0.8)
                                    : Colors.green.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isTracking ? Icons.stop : Icons.play_arrow,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (isTracking) ...[
                    Text(
                      'Started at: ${DateFormat('hh:mm a').format(_startTime!)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Elapsed time:',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _elapsedTime,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to stop tracking',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Track your sleep to improve your health',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.nightlight,
                          color: Colors.white.withOpacity(0.9),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tap to start tracking',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
