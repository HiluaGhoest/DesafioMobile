import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/util/theme_provider.dart';

class DaySelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DaySelector({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current date
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Create a list of the last 2 days, today, and the next 4 days (7 days total)
    final days = List.generate(
      7,
      (index) => today.subtract(Duration(days: 2 - index)),
    );
    
    // Get the month name of the selected date
    final String currentMonth = DateFormat('MMMM').format(selectedDate);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month display header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            currentMonth,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeProvider.primaryButton,
            ),
          ),
        ),
        Container(
          height: 90,
          margin: const EdgeInsets.only(top: 8, bottom: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              final day = days[index];
              
              // Check if this day is selected
              final isSelected = day.year == selectedDate.year &&
                  day.month == selectedDate.month &&
                  day.day == selectedDate.day;
              
              // Check if this day is in the past
              final isPast = day.isBefore(today);
              
              // Check if this is today
              final isToday = day.year == today.year &&
                  day.month == today.month &&
                  day.day == today.day;
          
              return GestureDetector(
                onTap: () {
                  // Don't allow selecting days in the past unless it's today
                  if (!isPast || isToday) {
                    onDateSelected(day);
                  }
                },
                child: Container(
                  width: 65,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ThemeProvider.primaryButton
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                    border: isToday && !isSelected
                        ? Border.all(color: ThemeProvider.primaryButton, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [                  
                      Text(
                        DateFormat('EEE').format(day).toUpperCase(), // Using EEE for more complete day abbreviation
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : isPast && !isToday
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM').format(day), // Show month name
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : isPast && !isToday
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday && !isSelected
                              ? ThemeProvider.primaryButton.withOpacity(0.15)
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            day.day.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isToday || isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : isPast && !isToday
                                      ? Colors.grey.shade400
                                      : isToday
                                          ? ThemeProvider.primaryButton
                                          : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
