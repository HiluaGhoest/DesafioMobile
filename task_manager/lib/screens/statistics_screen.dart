import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/services/activity_service.dart';
import 'package:task_manager/services/task_service.dart';
import 'package:task_manager/util/colors/app_colors.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  final ActivityService _activityService = ActivityService();
  final TaskService _taskService = TaskService();
  late TabController _tabController;
  bool _isLoading = false;
  Map<String, dynamic> _activityStatistics = {};
  Map<String, dynamic> _taskStatistics = {};
  Map<String, dynamic> _combinedStatistics = {};
  List<Map<String, dynamic>> _weeklyCompletion = [];
  List<Map<String, dynamic>> _monthlyCompletion = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllStatistics();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllStatistics() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final useSimulatedData = prefs.getBool('useSimulatedData') ?? false;

      if (useSimulatedData) {
        // Simulate activity statistics
        final activityStats = {
          'totalActivities': 15,
          'activeActivities': 8,
          'totalCompletions': 45,
          'activitiesCompletedToday': 3,
          'activitiesDueToday': 5,
        };
        
        // Simulate task statistics
        final taskStats = {
          'totalTasks': 20,
          'completedTasks': 12,
          'tasksCompletedToday': 4,
          'tasksDueToday': 6,
        };
        
        // Simulate weekly completion data
        final now = DateTime.now();
        final weeklyData = List.generate(7, (index) {
          final date = now.subtract(Duration(days: 6 - index));
          return {
            'date': date,
            'dayName': DateFormat('E').format(date),
            'formattedDate': DateFormat('yyyy-MM-dd').format(date),
            'taskCompletions': Random().nextInt(8), // Random number of task completions (0-7)
            'activityCompletions': Random().nextInt(6), // Random number of activity completions (0-5)
            'totalCompletions': Random().nextInt(10) + 2, // Random total (2-11)
          };
        });
        
        // Simulate monthly completion data
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final monthlyData = List.generate(daysInMonth, (index) {
          final date = DateTime(now.year, now.month, index + 1);
          // Don't generate data for future dates
          if (date.isAfter(now)) {
            return {
              'date': date,
              'dayNumber': date.day,
              'formattedDate': DateFormat('yyyy-MM-dd').format(date),
              'taskCompletions': 0,
              'activityCompletions': 0,
              'totalCompletions': 0,
            };
          }
          
          return {
            'date': date,
            'dayNumber': date.day,
            'formattedDate': DateFormat('yyyy-MM-dd').format(date),
            'taskCompletions': Random().nextInt(6), // Random number of task completions (0-5)
            'activityCompletions': Random().nextInt(5), // Random number of activity completions (0-4)
          };
        }).map((day) {
          return {
            ...day,
            'totalCompletions': (day['taskCompletions'] as int) + (day['activityCompletions'] as int),
          };
        }).toList();

        // Calculate combined statistics
        final combinedStats = _calculateCombinedStatistics(taskStats, activityStats);
        
        setState(() {
          _activityStatistics = activityStats;
          _taskStatistics = taskStats;
          _combinedStatistics = combinedStats;
          _weeklyCompletion = weeklyData;
          _monthlyCompletion = monthlyData;
          _isLoading = false;
        });
      } else {
        // Use real data
        final weeklyData = await _generateWeeklyCompletionData();
        final monthlyData = await _generateMonthlyCompletionData();
        
        // Get real statistics from services
        final taskStats = await _taskService.getTaskStatistics();
        final activityStats = await _activityService.getActivityStatistics();
        
        // Calculate combined statistics
        final combinedStats = _calculateCombinedStatistics(taskStats, activityStats);
        
        setState(() {
          _activityStatistics = activityStats;
          _taskStatistics = taskStats;
          _combinedStatistics = combinedStats;
          _weeklyCompletion = weeklyData;
          _monthlyCompletion = monthlyData;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load statistics: ${e.toString()}')),
        );
      }
    }
  }

  Map<String, dynamic> _calculateCombinedStatistics(
    Map<String, dynamic> taskStats, 
    Map<String, dynamic> activityStats
  ) {
    final totalTasks = taskStats['totalTasks'] ?? 0;
    final completedTasks = taskStats['completedTasks'] ?? 0;
    final totalActivities = activityStats['totalActivities'] ?? 0;
    final activeActivities = activityStats['activeActivities'] ?? 0;
    final activityCompletions = activityStats['totalCompletions'] ?? 0;
    
    final tasksCompletedToday = taskStats['tasksCompletedToday'] ?? 0;
    final activitiesCompletedToday = activityStats['activitiesCompletedToday'] ?? 0;
    final tasksDueToday = taskStats['tasksDueToday'] ?? 0;
    final activitiesDueToday = activityStats['activitiesDueToday'] ?? 0;
    
    return {
      'totalItems': totalTasks + totalActivities,
      'activeItems': (totalTasks - completedTasks) + activeActivities,
      'totalCompletions': completedTasks + activityCompletions,
      'itemsCompletedToday': tasksCompletedToday + activitiesCompletedToday,
      'itemsDueToday': tasksDueToday + activitiesDueToday,
      'completionRate': (tasksDueToday + activitiesDueToday) > 0 
          ? (tasksCompletedToday + activitiesCompletedToday) / 
            (tasksDueToday + activitiesDueToday) 
          : 0.0,
      'taskCompletionRate': tasksDueToday > 0 
          ? tasksCompletedToday / tasksDueToday 
          : 0.0,
      'activityCompletionRate': activitiesDueToday > 0 
          ? activitiesCompletedToday / activitiesDueToday 
          : 0.0,
    };
  }

  Future<List<Map<String, dynamic>>> _generateWeeklyCompletionData() async {
    final now = DateTime.now();
    final weeklyData = <Map<String, dynamic>>[];
    
    // Get data for the last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      
      final taskCompletions = await _taskService.getCompletedTasksForDate(date);
      final activityCompletions = await _activityService.getCompletionsForDate(date);
      
      weeklyData.add({
        'date': date,
        'dayName': DateFormat('E').format(date),
        'formattedDate': formattedDate,
        'taskCompletions': taskCompletions,
        'activityCompletions': activityCompletions,
        'totalCompletions': taskCompletions + activityCompletions,
      });
    }
    
    return weeklyData;
  }

  Future<List<Map<String, dynamic>>> _generateMonthlyCompletionData() async {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final monthlyData = <Map<String, dynamic>>[];
    
    // Get data for the current month
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(now.year, now.month, i);
      
      // Skip future dates
      if (date.isAfter(now)) {
        break;
      }
      
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      
      final taskCompletions = await _taskService.getCompletedTasksForDate(date);
      final activityCompletions = await _activityService.getCompletionsForDate(date);
      
      monthlyData.add({
        'date': date,
        'dayNumber': date.day,
        'formattedDate': formattedDate,
        'taskCompletions': taskCompletions,
        'activityCompletions': activityCompletions,
        'totalCompletions': taskCompletions + activityCompletions,
      });
    }
    
    return monthlyData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildWeeklyTab(),
                _buildMonthlyTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadAllStatistics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            _buildCompletionRateCard(),
            const SizedBox(height: 24),
            
            Text(
              'Tasks & Activities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            
            // Comparison chart: Tasks vs Activities
            Container(
              height: 240,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 5,
                        centerSpaceRadius: 40,
                        sections: [
                            PieChartSectionData(
                            value: _taskStatistics['totalTasks']?.toDouble() ?? 0,
                            title: 'Tasks',
                            color: Colors.blue,
                            radius: 60,
                            titleStyle: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            ),
                          PieChartSectionData(
                            value: _activityStatistics['totalActivities']?.toDouble() ?? 0,
                            title: 'Activities',
                            color: AppColors.primary(context),
                            radius: 60,
                            titleStyle: TextStyle(
                              color: AppColors.surface(context),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLegendItem(
                        color: Colors.blue,
                        label: 'Tasks',
                        value: '${_taskStatistics['totalTasks'] ?? 0}',
                      ),
                      const SizedBox(width: 24),
                      _buildLegendItem(
                        color: AppColors.primary(context),
                        label: 'Activities',
                        value: '${_activityStatistics['totalActivities'] ?? 0}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Tasks statistics
            const Text(
              'Task Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTaskStatisticsCards(),
            
            const SizedBox(height: 24),
            
            // Activity statistics
            const Text(
              'Activity Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityStatisticsCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTab() {
    if (_weeklyCompletion.isEmpty) {
      return Center(
        child: Text(
          'No data available for the past week',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
      );
    }
    
    final maxCompletions = _weeklyCompletion
        .map((day) => day['totalCompletions'] as int)
        .reduce((a, b) => a > b ? a : b);
    
    return RefreshIndicator(
      onRefresh: _loadAllStatistics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Completion Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            
            // Weekly chart
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxCompletions + 1.0,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final day = _weeklyCompletion[groupIndex];
                        return BarTooltipItem(
                          '${day['dayName']}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: 'Tasks: ${day['taskCompletions']}\n',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: 'Activities: ${day['activityCompletions']}\n',
                              style: TextStyle(
                                color: AppColors.primary(context),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: 'Total: ${day['totalCompletions']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= _weeklyCompletion.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _weeklyCompletion[value.toInt()]['dayName'],
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: List.generate(
                    _weeklyCompletion.length,
                    (index) {
                      final day = _weeklyCompletion[index];
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: day['totalCompletions'].toDouble(),
                            width: 18,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            rodStackItems: [
                              BarChartRodStackItem(
                                0,
                                day['taskCompletions'].toDouble(),
                                Colors.blue,
                              ),
                              BarChartRodStackItem(
                                day['taskCompletions'].toDouble(),
                                day['totalCompletions'].toDouble(),
                                AppColors.primary(context),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  color: Colors.blue,
                  label: 'Tasks',
                ),
                const SizedBox(width: 24),
                _buildLegendItem(
                  color: AppColors.primary(context),
                  label: 'Activities',
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Weekly completion heatmap
            Text(
              'Completion Timeline',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            _buildWeeklyCompletionHeatmap(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTab() {
    if (_monthlyCompletion.isEmpty) {
      return const Center(child: Text('No data available for this month'));
    }
    
    return RefreshIndicator(
      onRefresh: _loadAllStatistics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat('MMMM yyyy').format(DateTime.now())} Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            
            // Month summary statistics
            _buildMonthSummaryStatistics(),
            
            const SizedBox(height: 24),
            
            Text(
              'Monthly Completion Timeline',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            
            // Month completion heatmap
            _buildMonthlyCompletionHeatmap(),
            
            const SizedBox(height: 24),
            
            // Monthly trend line chart
            Text(
              'Monthly Trend',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildMonthlyTrendChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionRateCard() {
    final completionRate = _combinedStatistics['completionRate'] as double? ?? 0.0;
    final completionPercentage = (completionRate * 100).toStringAsFixed(0);
    final taskCompletionRate = _combinedStatistics['taskCompletionRate'] as double? ?? 0.0;
    final activityCompletionRate = _combinedStatistics['activityCompletionRate'] as double? ?? 0.0;
    
    final itemsDueToday = _combinedStatistics['itemsDueToday'] as int? ?? 0;
    final itemsCompletedToday = _combinedStatistics['itemsCompletedToday'] as int? ?? 0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Completion',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$completionPercentage%',
                    style: TextStyle(
                      color: AppColors.primary(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: completionRate,
                backgroundColor: Colors.grey[200],
                color: AppColors.primary(context),
                minHeight: 20,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Done: $itemsCompletedToday',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Text(
                  'Total: $itemsDueToday',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        value: taskCompletionRate,
                        backgroundColor: AppColors.surface(context).withOpacity(0.2),
                        color: Colors.blue,
                        strokeWidth: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tasks',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        '${(taskCompletionRate * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        value: activityCompletionRate,
                        backgroundColor: AppColors.surface(context).withOpacity(0.2),
                        color: AppColors.primary(context),
                        strokeWidth: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Activities',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        '${(activityCompletionRate * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: AppColors.primary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskStatisticsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatisticCard(
            icon: Icons.task_alt,
            title: 'Total',
            value: '${_taskStatistics['totalTasks'] ?? 0}',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatisticCard(
            icon: Icons.check_circle_outline,
            title: 'Completed',
            value: '${_taskStatistics['completedTasks'] ?? 0}',
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityStatisticsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatisticCard(
            icon: Icons.loop,
            title: 'Total',
            value: '${_activityStatistics['totalActivities'] ?? 0}',
            color: AppColors.primary(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatisticCard(
            icon: Icons.done_all,
            title: 'Completions',
            value: '${_activityStatistics['totalCompletions'] ?? 0}',
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 24,
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyCompletionHeatmap() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final day = _weeklyCompletion[index];
              return _buildCompletionBlock(
                day: day['dayName'],
                taskCount: day['taskCompletions'],
                activityCount: day['activityCompletions'],
                isToday: index == 6,
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                color: Colors.blue,
                label: 'Tasks',
                
              ),
              const SizedBox(width: 24),
              _buildLegendItem(
                color: AppColors.primary(context),
                label: 'Activities',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionBlock({
    required String day,
    required int taskCount,
    required int activityCount,
    bool isToday = false,
  }) {
    final totalCount = taskCount + activityCount;
    final hasCompletions = totalCount > 0;
    
    // Calculate heights based on completion counts
    final double taskHeight = taskCount > 0 ? 20.0 * taskCount : 0.0;
    final double activityHeight = activityCount > 0 ? 20.0 * activityCount : 0.0;
    final double minBlockHeight = hasCompletions ? 0.0 : 20.0;
    
    return Column(
      children: [
        Container(
          width: 40,
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.surface(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: AppColors.primary(context), width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (activityHeight > 0)
                Container(
                  width: 40,
                  height: activityHeight,
                  decoration: BoxDecoration(
                    color: AppColors.primary(context),
                    borderRadius: taskHeight > 0
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          )
                        : const BorderRadius.vertical(
                            top: Radius.circular(8),
                            bottom: Radius.circular(0),
                          ),
                  ),
                ),
              if (taskHeight > 0)
                Container(
                  width: 40,
                  height: taskHeight,
                  decoration: BoxDecoration(
                    color: AppColors.secondary(context),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                ),
              if (!hasCompletions)
                Container(
                  width: 40,
                  height: minBlockHeight,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? AppColors.primary(context) : AppColors.textSecondary(context),
          ),
        ),
        Text(
          totalCount.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: hasCompletions
                ? (isToday ? AppColors.primary(context) : AppColors.textPrimary(context))
                : AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSummaryStatistics() {
    final totalTaskCompletions = _monthlyCompletion.fold<int>(
      0, (sum, day) => sum + (day['taskCompletions'] as int));
    
    final totalActivityCompletions = _monthlyCompletion.fold<int>(
      0, (sum, day) => sum + (day['activityCompletions'] as int));
    
    final totalCompletionDays = _monthlyCompletion
      .where((day) => (day['totalCompletions'] as int) > 0)
      .length;
    
    final totalDaysTracked = _monthlyCompletion.length;
      
    final completionRate = totalDaysTracked > 0
        ? totalCompletionDays / totalDaysTracked
        : 0.0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Month Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$totalTaskCompletions',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'Tasks Completed',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$totalActivityCompletions',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary(context),
                        ),
                      ),
                      Text(
                        'Activity Completions',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$totalCompletionDays',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      Text(
                        'Active Days / $totalDaysTracked',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${(completionRate * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        'Completion Rate',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyCompletionHeatmap() {
    final weeks = <List<Map<String, dynamic>>>[];
    final daysInMonth = _monthlyCompletion.length;
    
    // Find the first day of the month
    final firstDay = _monthlyCompletion.first['date'] as DateTime;
    final firstDayOfWeek = firstDay.weekday;
    
    // Create weeks with padding for days before the first of the month
    var currentWeek = <Map<String, dynamic>>[];
    
    // Add empty days before the first day of the month
    for (int i = 1; i < firstDayOfWeek; i++) {
      currentWeek.add({
        'isEmpty': true,
        'dayNumber': 0,
        'taskCompletions': 0,
        'activityCompletions': 0,
        'totalCompletions': 0,
      });
    }
    
    // Add all days of the month
    for (int i = 0; i < daysInMonth; i++) {
      final day = _monthlyCompletion[i];
      currentWeek.add(day);
      
      // Start a new week if we've reached Sunday or the end of the month
      if ((firstDayOfWeek + i) % 7 == 0 || i == daysInMonth - 1) {
        // Pad the last week with empty days if needed
        while (currentWeek.length < 7) {
          currentWeek.add({
            'isEmpty': true,
            'dayNumber': 0,
            'taskCompletions': 0,
            'activityCompletions': 0,
            'totalCompletions': 0,
          });
        }
        
        weeks.add(List.from(currentWeek));
        currentWeek = <Map<String, dynamic>>[];
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Day headers (M-S)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('M', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
              Text('T', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
              Text('W', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
              Text('T', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
              Text('F', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
              Text('S', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
              Text('S', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary(context))),
            ],
          ),
          const SizedBox(height: 8),
          
          // Calendar grid
          Column(
            children: weeks.map((week) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: week.map((day) {
                    if (day['isEmpty'] == true) {
                      return const SizedBox(width: 40, height: 40);
                    }
                    
                    final dayNumber = day['dayNumber'];
                    final taskCount = day['taskCompletions'] as int;
                    final activityCount = day['activityCompletions'] as int;
                    final totalCount = day['totalCompletions'] as int;
                    
                    final today = DateTime.now();
                    final dayDate = day['date'] as DateTime;
                    final isToday = dayDate.year == today.year && 
                                  dayDate.month == today.month && 
                                  dayDate.day == today.day;
                    
                    // Calculate intensity based on completion count
                    Color color;
                    if (totalCount == 0) {
                      color = AppColors.surface(context).withOpacity(0.1);
                    } else if (totalCount <= 2) {
                      color = AppColors.success(context).withOpacity(0.3);
                    } else if (totalCount <= 5) {
                      color = AppColors.success(context).withOpacity(0.5);
                    } else if (totalCount <= 8) {
                      color = AppColors.success(context).withOpacity(0.7);
                    } else {
                      color = AppColors.success(context);
                    }
                    
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: isToday
                            ? Border.all(color: AppColors.primary(context), width: 2)
                            : totalCount == 0
                                ? Border.all(color: AppColors.textSecondary(context).withOpacity(0.3), width: 1)
                                : null,
                      ),
                      child: Tooltip(
                        message: 'Tasks: $taskCount\nActivities: $activityCount\nTotal: $totalCount',
                        child: Center(
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                              color: totalCount >= 5 ? Colors.white : AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildColorLegendItem(color: AppColors.surface(context).withOpacity(0.1), label: 'No completions'),
              const SizedBox(width: 8),
              _buildColorLegendItem(color: AppColors.success(context).withOpacity(0.3), label: '1-2'),
              const SizedBox(width: 8),
              _buildColorLegendItem(color: AppColors.success(context).withOpacity(0.5), label: '3-5'),
              const SizedBox(width: 8),
              _buildColorLegendItem(color: AppColors.success(context).withOpacity(0.7), label: '6-8'),
              const SizedBox(width: 8),
              _buildColorLegendItem(color: AppColors.success(context), label: '9+'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrendChart() {
    if (_monthlyCompletion.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Group completions by week for the trend line
    final List<List<Map<String, dynamic>>> weeks = [];
    List<Map<String, dynamic>> currentWeek = [];
    
    // Initialize with the first week
    int currentWeekNumber = 0;
    
    for (final day in _monthlyCompletion) {
      final date = day['date'] as DateTime;
      final weekOfMonth = ((date.day - 1) / 7).floor();
      
      if (weekOfMonth != currentWeekNumber) {
        if (currentWeek.isNotEmpty) {
          weeks.add(List.from(currentWeek));
          currentWeek = [];
        }
        currentWeekNumber = weekOfMonth;
      }
      
      currentWeek.add(day);
    }
    
    // Add the last week if not empty
    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek);
    }
    
    // Calculate weekly totals for the trend
    final weeklyTotals = weeks.map((week) {
      final taskSum = week.fold<int>(
        0, (sum, day) => sum + (day['taskCompletions'] as int));
      final activitySum = week.fold<int>(
        0, (sum, day) => sum + (day['activityCompletions'] as int));
      
      return {
        'week': weeks.indexOf(week) + 1,
        'taskCompletions': taskSum,
        'activityCompletions': activitySum,
        'totalCompletions': taskSum + activitySum,
      };
    }).toList();
    
    // Find maximum value for Y-axis scaling
    final maxCompletion = weeklyTotals.fold<int>(
      0,
      (max, data) {
        final total = data['totalCompletions'] ?? 0;
        return total > max ? total : max;
      },
    ).toDouble();
    
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: weeklyTotals.length < 2
          ? Center(
              child: Text(
                'Not enough data for trend analysis',
                style: TextStyle(color: AppColors.textSecondary(context)),
              ),
            )
          : LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300],
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false, // Hide bottom titles completely
                      reservedSize: 0,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 2 != 0) return const SizedBox.shrink();
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 12,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: weeklyTotals.length - 1.0,
                minY: 0,
                maxY: maxCompletion + 5,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final index = barSpot.x.toInt();
                        final data = weeklyTotals[index];
                        
                        if (barSpot.barIndex == 0) { // Tasks
                          return LineTooltipItem(
                            'Tasks: ${data["taskCompletions"]}',
                            TextStyle(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else if (barSpot.barIndex == 1) { // Activities
                          return LineTooltipItem(
                            'Activities: ${data["activityCompletions"]}',
                            TextStyle(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else { // Total
                          return LineTooltipItem(
                            'Total: ${data["totalCompletions"]}',
                            TextStyle(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  // Tasks line
                  LineChartBarData(
                    spots: List.generate(weeklyTotals.length, (index) {
                      return FlSpot(
                        index.toDouble(),
                        (weeklyTotals[index]['taskCompletions'] ?? 0).toDouble(),
                      );
                    }),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                  
                  // Activities line
                  LineChartBarData(
                    spots: List.generate(weeklyTotals.length, (index) {
                      return FlSpot(
                        index.toDouble(),
                        (weeklyTotals[index]['activityCompletions'] ?? 0).toDouble(),
                      );
                    }),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                  
                  // Total line
                  LineChartBarData(
                    spots: List.generate(weeklyTotals.length, (index) {
                      return FlSpot(
                        index.toDouble(),
                        (weeklyTotals[index]['totalCompletions'] ?? 0).toDouble(),
                      );
                    }),
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.orange.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    String? value,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value != null ? '$label: $value' : label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildColorLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox (width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}
