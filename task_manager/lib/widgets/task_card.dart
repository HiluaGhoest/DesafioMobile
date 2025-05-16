import 'package:flutter/material.dart';
import 'package:task_manager/data_models/task.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/util/theme_provider.dart';
import 'package:task_manager/util/colors/app_colors.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final Function(bool) onCompletionToggled;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.onCompletionToggled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary(context).withOpacity(task.isCompleted ? 0.03 : 0.1),
            blurRadius: task.isCompleted ? 3 : 5,
            offset: Offset(0, task.isCompleted ? 1 : 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0, // We're handling shadows with the container
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: task.isCompleted 
            ? BorderSide(color: AppColors.primary(context).withOpacity(0.5), width: 1)
            : BorderSide.none,
        ),
        color: task.isCompleted 
            ? AppColors.primary(context).withOpacity(0.1)
            : AppColors.surface(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status indicator dot
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted 
                          ? AppColors.success(context)
                          : AppColors.primary(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Task Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted ? AppColors.textSecondary(context) : AppColors.textPrimary(context),
                          ),
                        ),
                        if (task.description != null && task.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              task.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: task.isCompleted ? AppColors.textSecondary(context) : AppColors.textPrimary(context).withOpacity(0.7),
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: task.isCompleted ? AppColors.textSecondary(context) : AppColors.textPrimary(context).withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.time.format(context),
                              style: TextStyle(
                                fontSize: 13,
                                color: task.isCompleted ? AppColors.textSecondary(context) : AppColors.textPrimary(context).withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: task.isCompleted ? AppColors.textSecondary(context) : AppColors.textPrimary(context).withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM d, yyyy').format(task.date),
                              style: TextStyle(
                                fontSize: 13,
                                color: task.isCompleted ? AppColors.textSecondary(context) : AppColors.textPrimary(context).withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Menu Button
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: task.isCompleted ? AppColors.textSecondary(context) : AppColors.textPrimary(context).withOpacity(0.6),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEditPressed();
                      } else if (value == 'delete') {
                        onDeletePressed();
                      } else if (value == 'toggle') {
                        onCompletionToggled(!task.isCompleted);
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
                              task.isCompleted ? Icons.restart_alt : Icons.check_circle_outline,
                              size: 18,
                              color: task.isCompleted ? AppColors.success(context) : AppColors.textPrimary(context),
                            ),
                            const SizedBox(width: 8),
                            Text(task.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 18,
                              color: AppColors.error(context),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(color: AppColors.error(context)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Completion toggle button
              if (!task.isCompleted)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => onCompletionToggled(true),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Mark Complete'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Completed status indicator
              if (task.isCompleted)
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
                        'Completed',
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
