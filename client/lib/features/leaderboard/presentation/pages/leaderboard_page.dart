import 'package:client/features/leaderboard/presentation/providers/leaderboard_provider.dart';
import 'package:client/features/leaderboard/presentation/widgets/leaderboard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/leaderboard_controller.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Load initial leaderboard data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaderboardControllerProvider.notifier).loadLeaderboard();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) return;
    
    final controller = ref.read(leaderboardControllerProvider.notifier);
    if (_tabController.index == 0) {
      controller.changeType(LeaderboardType.daily);
    } else {
      controller.changeType(LeaderboardType.monthly);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final controller = ref.read(leaderboardControllerProvider.notifier);
    final state = ref.read(leaderboardControllerProvider);
    
    final initialDate = DateTime.tryParse(state.selectedDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      controller.selectDate(formattedDate);
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    final controller = ref.read(leaderboardControllerProvider.notifier);
    final state = ref.read(leaderboardControllerProvider);
    
    final initialDate = DateTime(state.selectedYear, state.selectedMonth);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    
    if (picked != null) {
      controller.selectMonth(picked.year, picked.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderboardControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Date/Month selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildDateSelector(state),
          ),
          
          // Leaderboard content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Daily leaderboard
                _buildLeaderboardContent(state),
                
                // Monthly leaderboard
                _buildLeaderboardContent(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(LeaderboardState state) {
    if (state.currentType == LeaderboardType.daily) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Date: ${state.selectedDate}'),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => _selectDate(context),
            child: const Text('Change Date'),
          ),
        ],
      );
    } else {
      final monthName = DateFormat('MMMM').format(DateTime(2022, state.selectedMonth));
      
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Period: $monthName ${state.selectedYear}'),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => _selectMonth(context),
            child: const Text('Change Month'),
          ),
        ],
      );
    }
  }

  Widget _buildLeaderboardContent(LeaderboardState state) {
    switch (state.status) {
      case LeaderboardStatus.initial:
      case LeaderboardStatus.loading:
        return const Center(child: CircularProgressIndicator());
      
      case LeaderboardStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.errorMessage ?? 'An error occurred',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(leaderboardControllerProvider.notifier).loadLeaderboard(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      
      case LeaderboardStatus.loaded:
        if (state.leaderboard == null || state.leaderboard!.entries.isEmpty) {
          return const Center(child: Text('No leaderboard data available'));
        }
        
        return Column(
          children: [
            // User's rank
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Your Rank: ${state.leaderboard!.userRank} of ${state.leaderboard!.totalUsers}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            
            // Leaderboard entries
            Expanded(
              child: ListView.builder(
                itemCount: state.leaderboard!.entries.length,
                itemBuilder: (context, index) {
                  final entry = state.leaderboard!.entries[index];
                  return LeaderboardEntryWidget(entry: entry);
                },
              ),
            ),
          ],
        );
    }
  }
}
