import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/data_models/activity.dart';
import 'package:task_manager/util/theme_provider.dart';
import 'package:task_manager/util/colors/app_colors.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onCompletePressed;
  final Function(bool) onToggleStatus;

  const ActivityCard({
    Key? key,
    required this.activity,
    required this.onEditPressed,
    required this.onDeletePressed,
    this.onCompletePressed,
    required this.onToggleStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool canBeCompletedToday = activity.isDueToday();
    
    // Check if already completed today
    bool completedToday = false;
    if (activity.lastCompletionDate != null) {
      final now = DateTime.now();
      final lastCompletion = activity.lastCompletionDate!;
      completedToday = lastCompletion.year == now.year &&
          lastCompletion.month == now.month &&
          lastCompletion.day == now.day;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withOpacity(!activity.isActive || completedToday ? 0.03 : 0.1),
            blurRadius: !activity.isActive || completedToday ? 3 : 5,
            offset: Offset(0, !activity.isActive || completedToday ? 1 : 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0, // We're handling shadows with the container
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: !activity.isActive 
            ? BorderSide(color: AppColors.surface(context).withOpacity(0.7), width: 1)
            : (completedToday 
                ? BorderSide(color: AppColors.primary(context).withOpacity(0.5), width: 1)
                : BorderSide.none),
        ),
        color: !activity.isActive
            ? AppColors.surface(context).withOpacity(0.7)
            : (completedToday
                ? AppColors.primary(context).withOpacity(0.1)
                : AppColors.surface(context)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity Status Indicator
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !activity.isActive
                          ? AppColors.textSecondary(context)
                          : (completedToday
                              ? AppColors.success(context)
                              : (canBeCompletedToday ? AppColors.warning(context) : AppColors.primary(context))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Activity Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: !activity.isActive ? AppColors.textSecondary(context) : AppColors.textPrimary(context),
                            decoration: completedToday ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (activity.description != null && activity.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              activity.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: !activity.isActive ? AppColors.textSecondary(context) : AppColors.textPrimary(context).withOpacity(0.7),
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.repeat,
                              size: 16,
                              color: !activity.isActive ? AppColors.textSecondary(context) : AppColors.primary(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              activity.getRecurrenceDescription(),
                              style: TextStyle(
                                fontSize: 13,
                                color: !activity.isActive ? AppColors.textSecondary(context) : AppColors.textPrimary(context).withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: !activity.isActive ? AppColors.textSecondary(context) : AppColors.textPrimary(context).withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              activity.time.format(context),
                              style: TextStyle(
                                fontSize: 13,
                                color: !activity.isActive ? AppColors.textSecondary(context) : AppColors.textPrimary(context).withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: !activity.isActive ? AppColors.textSecondary(context) : AppColors.textPrimary(context).withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Started ${DateFormat('MMM d, y').format(activity.startDate)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: !activity.isActive ? AppColors.textSecondary(context) : AppColors.textPrimary(context).withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        if (activity.completionCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.done_all,
                                  size: 16,
                                  color: !activity.isActive ? AppColors.textSecondary(context) : AppColors.success(context),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Completed ${activity.completionCount} ${activity.completionCount == 1 ? 'time' : 'times'}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: !activity.isActive ? AppColors.textSecondary(context) : AppColors.success(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Menu Button
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: !activity.isActive ? AppColors.textSecondary(context) : AppColors.textPrimary(context).withOpacity(0.6),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEditPressed();
                      } else if (value == 'delete') {
                        onDeletePressed();
                      } else if (value == 'toggle') {
                        onToggleStatus(!activity.isActive);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              activity.isActive ? Icons.pause : Icons.play_arrow,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(activity.isActive ? 'Pause' : 'Activate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Mark Complete Button (only for activities due today and not completed)
              if (activity.isActive && canBeCompletedToday && !completedToday && onCompletePressed != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: onCompletePressed,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Mark Complete'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Already Completed Indicator
              if (completedToday)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Completed Today',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.success(context),
                          fontStyle: FontStyle.italic,
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
}
