import 'package:flutter/material.dart';
import 'package:task_manager/data_models/task.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/util/theme_provider.dart';
import 'package:task_manager/util/colors/app_colors.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final Function(Task) onSave;

  const TaskDialog({
    Key? key,
    this.task,
    required this.onSave,
  }) : super(key: key);

  @override
  TaskDialogState createState() => TaskDialogState();
}

class TaskDialogState extends State<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    // Initialize with existing task values or defaults
    _nameController = TextEditingController(text: widget.task?.name ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _selectedDate = widget.task?.date ?? DateTime.now();
    _selectedTime = widget.task?.time ?? TimeOfDay.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow tasks from the past year
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),   // Allow tasks up to 5 years in the future
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary(context),
              onPrimary: AppColors.surface(context),
              onSurface: AppColors.textPrimary(context),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.surface(context),
              hourMinuteTextColor: AppColors.primary(context),
              dayPeriodTextColor: AppColors.primary(context),
              dialHandColor: AppColors.primary(context),
              dialBackgroundColor: AppColors.primary(context).withOpacity(0.1),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary(context),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                isEditing ? 'Edit Task' : 'Create Task',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primary(context),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.primary(context),
                    ),
                  ),
                ),
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primary(context),
                            ),
                          ),
                        ),
                        child: Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Time',
                          border: const OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primary(context),
                            ),
                          ),
                        ),
                        child: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary(context),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final task = Task(
                          id: widget.task?.id,
                          name: _nameController.text,
                          description: _descriptionController.text.isEmpty
                              ? null
                              : _descriptionController.text,
                          date: _selectedDate,
                          time: _selectedTime,
                          isCompleted: widget.task?.isCompleted ?? false,
                        );
                        widget.onSave(task);
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      foregroundColor: AppColors.surface(context),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(isEditing ? 'Save' : 'Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
