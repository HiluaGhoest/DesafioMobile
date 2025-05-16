import 'package:flutter/material.dart';
import 'package:task_manager/data_models/activity.dart';
import 'package:task_manager/services/activity_service.dart';
import 'package:task_manager/util/colors/app_colors.dart';
import 'package:task_manager/util/theme_provider.dart';
import 'package:task_manager/widgets/activity_dialog.dart';
import 'package:task_manager/widgets/activity_card.dart';
import 'package:task_manager/screens/statistics_screen.dart';
import 'package:provider/provider.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({Key? key}) : super(key: key);

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> with SingleTickerProviderStateMixin {
  final ActivityService _activityService = ActivityService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddActivityDialog() {
    showDialog(
      context: context,
      builder: (context) => ActivityDialog(
        onSave: (activity) {
          _activityService.addActivity(activity);
        },
      ),
    );
  }

  void _showEditActivityDialog(Activity activity) {
    showDialog(
      context: context,
      builder: (context) => ActivityDialog(
        activity: activity,
        onSave: (updatedActivity) {
          _activityService.updateActivity(updatedActivity);
        },
      ),
    );
  }

  void _deleteActivity(String activityId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text('Are you sure you want to delete this recurring activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _activityService.deleteActivity(activityId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _markActivityCompleted(Activity activity) async {
    try {
      await _activityService.markActivityCompleted(activity.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${activity.name} marked as completed!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing activity: ${e.toString()}')),
      );
    }
  }

  void _toggleActivityStatus(Activity activity, bool isActive) async {
    try {
      await _activityService.toggleActivityStatus(activity.id!, isActive);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling activity status: ${e.toString()}')),
      );
    }
  }

  // Widget for activity list view
  Widget _buildActivityListView(Stream<List<Activity>> activitiesStream) {
    return StreamBuilder<List<Activity>>(
      stream: activitiesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final activities = snapshot.data ?? [];
        
        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_note,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No activities found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showAddActivityDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Activity'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: activities.length,
          padding: const EdgeInsets.only(bottom: 80),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return ActivityCard(
              activity: activity,
              onEditPressed: () => _showEditActivityDialog(activity),
              onDeletePressed: () => _deleteActivity(activity.id!),
              onCompletePressed: () => _markActivityCompleted(activity),
              onToggleStatus: (isActive) => _toggleActivityStatus(activity, isActive),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Activities',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        actions: [
          // Add a button to view statistics
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsScreen()),
              );
            },
            tooltip: 'View Statistics',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: Provider.of<ThemeProvider>(context).backgroundGradient,
        ),
        child: Column(
          children: [
            // Tabs for filtering activities
            Container(
              color: AppColors.background(context),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All Activities'),
                  Tab(text: 'Active Only'),
                ],
                labelColor: AppColors.primary(context),
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: AppColors.primary(context),
              ),
            ),
            
            // Main content area
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildActivityListView(_activityService.getActivities()),
                  _buildActivityListView(_activityService.getActivities().map(
                    (activities) => activities.where((a) => a.isActive).toList()
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddActivityDialog,
        backgroundColor: AppColors.primary(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
