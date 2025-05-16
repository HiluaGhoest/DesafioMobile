import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/data_models/activity.dart';
import 'package:task_manager/util/theme_provider.dart';
import 'package:task_manager/util/colors/app_colors.dart';

class ActivityDialog extends StatefulWidget {
  final Activity? activity;
  final Function(Activity) onSave;

  const ActivityDialog({
    Key? key,
    this.activity,
    required this.onSave,
  }) : super(key: key);

  @override
  ActivityDialogState createState() => ActivityDialogState();
}

class ActivityDialogState extends State<ActivityDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late DateTime _selectedStartDate;
  late TimeOfDay _selectedTime;
  late RecurrenceType _recurrenceType;
  int? _customIntervalDays;
  List<int> _selectedDaysOfWeek = [];
  int? _selectedDayOfMonth;

  @override
  void initState() {
    super.initState();
    // Initialize with existing activity values or defaults
    _nameController = TextEditingController(text: widget.activity?.name ?? '');
    _descriptionController = TextEditingController(text: widget.activity?.description ?? '');
    _selectedStartDate = widget.activity?.startDate ?? DateTime.now();
    _selectedTime = widget.activity?.time ?? TimeOfDay.now();
    _recurrenceType = widget.activity?.recurrenceType ?? RecurrenceType.daily;
    _customIntervalDays = widget.activity?.customIntervalDays;
    _selectedDaysOfWeek = widget.activity?.selectedDaysOfWeek ?? [];
    _selectedDayOfMonth = widget.activity?.selectedDayOfMonth;
    
    // If recurrence type is weekly and no days are selected, use the start date's weekday
    if (_recurrenceType == RecurrenceType.weekly && _selectedDaysOfWeek.isEmpty) {
      _selectedDaysOfWeek = [_selectedStartDate.weekday];
    }
    
    // If recurrence type is monthly and no day is selected, use the start date's day
    if (_recurrenceType == RecurrenceType.monthly && _selectedDayOfMonth == null) {
      _selectedDayOfMonth = _selectedStartDate.day;
    }
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
      initialDate: _selectedStartDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary(context),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
        
        // Update selected day of month if in monthly recurrence
        if (_recurrenceType == RecurrenceType.monthly) {
          _selectedDayOfMonth = picked.day;
        }
        
        // Update selected day of week if in weekly recurrence
        if (_recurrenceType == RecurrenceType.weekly && _selectedDaysOfWeek.isEmpty) {
          _selectedDaysOfWeek = [picked.weekday];
        }
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
              backgroundColor: Colors.white,
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
  
  // Build the recurrence type selector
  Widget _buildRecurrenceTypeSelector() {
    final types = [
      {'type': RecurrenceType.daily, 'label': 'Daily'},
      {'type': RecurrenceType.weekly, 'label': 'Weekly'},
      {'type': RecurrenceType.monthly, 'label': 'Monthly'},
      {'type': RecurrenceType.custom, 'label': 'Custom'},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: types.map((item) {
            final type = item['type'] as RecurrenceType;
            final label = item['label'] as String;
            final isSelected = _recurrenceType == type;
            
            return FilterChip(
              selected: isSelected,
              label: Text(label),
              onSelected: (selected) {
                setState(() {
                  _recurrenceType = type;
                });
              },
              backgroundColor: AppColors.surface(context).withOpacity(0.1),
              selectedColor: AppColors.primary(context).withOpacity(0.2),
              checkmarkColor: AppColors.primary(context),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary(context) : AppColors.textPrimary(context),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        if (_recurrenceType == RecurrenceType.weekly)
          _buildWeeklySelector(),
        if (_recurrenceType == RecurrenceType.monthly)
          _buildMonthlySelector(),
        if (_recurrenceType == RecurrenceType.custom)
          _buildCustomSelector(),
      ],
    );
  }
  
  // Build weekly day selector
  Widget _buildWeeklySelector() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Days of Week',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(7, (index) {
            final weekday = index + 1; // 1-7 for Monday-Sunday
            final isSelected = _selectedDaysOfWeek.contains(weekday);
            
            return FilterChip(
              selected: isSelected,
              label: Text(days[index]),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDaysOfWeek.add(weekday);
                  } else {
                    _selectedDaysOfWeek.remove(weekday);
                  }
                });
              },
              backgroundColor: AppColors.surface(context).withOpacity(0.1),
              selectedColor: AppColors.primary(context).withOpacity(0.2),
              checkmarkColor: AppColors.primary(context),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary(context) : AppColors.textPrimary(context),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }),
        ),
      ],
    );
  }
  
  // Build monthly day selector
  Widget _buildMonthlySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Day of Month',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(31, (index) {
            final day = index + 1;
            final isSelected = _selectedDayOfMonth == day;
            
            return FilterChip(
              selected: isSelected,
              label: Text(day.toString()),
              onSelected: (selected) {
                setState(() {
                  _selectedDayOfMonth = selected ? day : null;
                });
              },
              backgroundColor: AppColors.surface(context).withOpacity(0.1),
              selectedColor: AppColors.primary(context).withOpacity(0.2),
              checkmarkColor: AppColors.primary(context),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary(context) : AppColors.textPrimary(context),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }),
        ),
      ],
    );
  }
  
  // Build custom interval selector
  Widget _buildCustomSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repeat every (days)',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: _customIntervalDays?.toString() ?? '1',
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter number of days',
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a number';
            }
            final number = int.tryParse(value);
            if (number == null || number < 1) {
              return 'Please enter a valid number greater than 0';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _customIntervalDays = int.tryParse(value) ?? 1;
            });
          },
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.activity != null;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing ? 'Edit Activity' : 'Create Recurring Activity',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Activity Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an activity name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(DateFormat('MMM d, yyyy').format(_selectedStartDate)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(_selectedTime.format(context)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Recurrence pattern selection
                _buildRecurrenceTypeSelector(),
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Validate based on recurrence type
                          if (_recurrenceType == RecurrenceType.weekly && _selectedDaysOfWeek.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select at least one day of the week')),
                            );
                            return;
                          }
                          
                          // Create activity object
                          final activity = Activity(
                            id: widget.activity?.id,
                            name: _nameController.text.trim(),
                            description: _descriptionController.text.trim().isEmpty
                                ? null
                                : _descriptionController.text.trim(),
                            startDate: _selectedStartDate,
                            time: _selectedTime,
                            recurrenceType: _recurrenceType,
                            customIntervalDays: _recurrenceType == RecurrenceType.custom 
                                ? _customIntervalDays 
                                : null,
                            selectedDaysOfWeek: _recurrenceType == RecurrenceType.weekly 
                                ? _selectedDaysOfWeek 
                                : null,
                            selectedDayOfMonth: _recurrenceType == RecurrenceType.monthly 
                                ? _selectedDayOfMonth 
                                : null,
                            isActive: widget.activity?.isActive ?? true,
                            completionCount: widget.activity?.completionCount ?? 0,
                            lastCompletionDate: widget.activity?.lastCompletionDate,
                          );
                          
                          widget.onSave(activity);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(isEditing ? 'Save' : 'Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
