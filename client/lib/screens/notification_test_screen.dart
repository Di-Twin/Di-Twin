import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers/notification_provider.dart';

class NotificationTestScreen extends ConsumerStatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  ConsumerState<NotificationTestScreen> createState() =>
      _NotificationTestScreenState();
}

class _NotificationTestScreenState
    extends ConsumerState<NotificationTestScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDateTime = DateTime.now().add(const Duration(minutes: 1));

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/dashboard');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Sleep Notifications'),
            _buildSleepNotificationTests(),

            const SizedBox(height: 24),
            _buildSectionTitle('Reduction Notifications'),
            _buildReductionNotificationTests(),

            const SizedBox(height: 24),
            _buildSectionTitle('Food Log Notifications'),
            _buildFoodLogNotificationTests(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSleepNotificationTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final sleepChannel = ref.read(sleepNotificationChannelProvider);
            await sleepChannel.showSleepTrackingNotification(isTracking: false);
            _showSuccessSnackbar('Sleep tracking notification sent');
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
          child: const Text('Test Sleep Start Notification'),
        ),

        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            final sleepHandler = ref.read(sleepNotificationHandlerProvider);
            await sleepHandler.startSleepTracking();
            _showSuccessSnackbar('Sleep tracking started');
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
          child: const Text('Start Sleep Tracking'),
        ),

        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            final sleepHandler = ref.read(sleepNotificationHandlerProvider);
            await sleepHandler.stopSleepTracking();
            _showSuccessSnackbar('Sleep tracking stopped');
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
          child: const Text('Stop Sleep Tracking'),
        ),

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _selectTime(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                ),
                child: Text('Select Time: ${_selectedTime.format(context)}'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                final sleepChannel = ref.read(sleepNotificationChannelProvider);
                await sleepChannel.scheduleSleepReminder(
                  reminderTime: _selectedTime,
                  message: 'Time to prepare for sleep!',
                );
                _showSuccessSnackbar(
                  'Sleep reminder scheduled for ${_selectedTime.format(context)}',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              child: const Text('Schedule'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReductionNotificationTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final reductionChannel = ref.read(
              reductionNotificationChannelProvider,
            );
            await reductionChannel.showReductionReminder(
              medicationName: 'Amoxicillin',
              dosage: '500mg',
              instructions: 'Take with food',
            );
            _showSuccessSnackbar('Reduction reminder notification sent');
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          child: const Text('Test Immediate Reduction Reminder'),
        ),

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _selectTime(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                ),
                child: Text('Select Time: ${_selectedTime.format(context)}'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                final reductionChannel = ref.read(
                  reductionNotificationChannelProvider,
                );
                await reductionChannel.scheduleReductionReminder(
                  medicationName: 'Amoxicillin',
                  dosage: '500mg',
                  reminderTime: _selectedTime,
                  instructions: 'Take with food',
                );
                _showSuccessSnackbar(
                  'Reduction reminder scheduled for ${_selectedTime.format(context)}',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('Schedule Daily'),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _selectDateTime(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                ),
                child: Text(
                  'One-time: ${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                final reductionChannel = ref.read(
                  reductionNotificationChannelProvider,
                );
                await reductionChannel.scheduleOneTimeReductionReminder(
                  medicationName: 'Amoxicillin',
                  dosage: '500mg',
                  reminderTime: _selectedDateTime,
                  instructions: 'Take with food',
                );
                _showSuccessSnackbar('One-time reduction reminder scheduled');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('Schedule Once'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFoodLogNotificationTests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final foodLogChannel = ref.read(foodLogNotificationChannelProvider);
            await foodLogChannel.showFoodLogReminder(
              mealType: 'Lunch',
              customMessage:
                  'Time to log your lunch! Maintaining a food log helps you stay on track.',
            );
            _showSuccessSnackbar('Food log reminder notification sent');
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Test Immediate Food Log Reminder'),
        ),

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _selectTime(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                ),
                child: Text('Select Time: ${_selectedTime.format(context)}'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                final foodLogChannel = ref.read(
                  foodLogNotificationChannelProvider,
                );
                await foodLogChannel.scheduleFoodLogReminder(
                  mealType: 'Dinner',
                  reminderTime: _selectedTime,
                  customMessage: 'Time to log your dinner!',
                );
                _showSuccessSnackbar(
                  'Food log reminder scheduled for ${_selectedTime.format(context)}',
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Schedule'),
            ),
          ],
        ),

        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            final foodLogChannel = ref.read(foodLogNotificationChannelProvider);
            await foodLogChannel.scheduleAllMealReminders(
              mealSchedule: {
                'Breakfast': TimeOfDay(hour: 8, minute: 0),
                'Lunch': TimeOfDay(hour: 12, minute: 30),
                'Dinner': TimeOfDay(hour: 19, minute: 0),
              },
            );
            _showSuccessSnackbar('All meal reminders scheduled');
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Schedule All Meals'),
        ),
      ],
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
