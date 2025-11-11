import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeeklyHabitsPage extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> habitData;

  const WeeklyHabitsPage({super.key, required this.habitData});

  List<DateTime> _getWeekDates(DateTime current) {
    final startOfWeek = current.subtract(Duration(days: current.weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  String _keyFor(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final weekDates = _getWeekDates(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Habits"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = weekDates[index];
          final key = _keyFor(date);
          final habits = habitData[key] ?? [];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][date.weekday - 1]} ${date.month}/${date.day}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...habits.map(
                    (h) => ListTile(
                      leading: Icon(
                        h['done']
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: h['done'] ? Colors.green : Colors.deepPurple,
                      ),
                      title: Text(
                        h['title'],
                        style: GoogleFonts.poppins(
                          decoration: h['done']
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                  if (habits.isEmpty)
                    const Text(
                      "No habits for this day",
                      style: TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
