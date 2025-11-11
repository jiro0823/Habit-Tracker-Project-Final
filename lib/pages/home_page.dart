import 'dart:math';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:vibration/vibration.dart';
import 'weekly_habits_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  DateTime _selectedDate = DateTime.now();

  final Map<String, List<Map<String, dynamic>>> _habitData = {};
  final List<String> _quotes = const [
    "Small steps every day lead to big results.",
    "Discipline beats motivation.",
    "Your habits define your future.",
    "Focus on progress, not perfection.",
    "Be consistent, even when it’s hard.",
  ];

  // ===== Confetti & Celebration Tracking =====
  late ConfettiController _confettiController;
  Map<String, bool> _celebratedDates = {}; // Track celebration per day

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _signUserOut() async {
    await FirebaseAuth.instance.signOut();
  }

  String _keyFor(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _ensureDateHasHabits(DateTime date) {
    final k = _keyFor(date);
    if (!_habitData.containsKey(k)) {
      _habitData[k] = [
        {'title': 'Exercise 20 mins', 'done': false},
        {'title': 'Read 15 mins', 'done': false},
      ];
    }
  }

  double _calculateProgress() {
    final k = _keyFor(_selectedDate);
    if (!_habitData.containsKey(k) || _habitData[k]!.isEmpty) return 0;
    final list = _habitData[k]!;
    final doneCount = list.where((h) => h['done'] == true).length;
    return doneCount / list.length;
  }

  void _toggleHabit(int index) async {
    final k = _keyFor(_selectedDate);
    final list = _habitData[k]!;
    setState(() => list[index]['done'] = !(list[index]['done'] as bool));

    final progress = _calculateProgress();

    if (progress == 1 && !(_celebratedDates[k] ?? false)) {
      _celebratedDates[k] = true; // Mark today as celebrated

      _confettiController.play();

      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 300);
      }

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Center(
            child: Text(
              "🎉 Congratulations! 🎉",
              style: TextStyle(color: Colors.white),
            ),
          ),
          content: const Text(
            "You completed all your habits for today!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "Awesome!",
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _addHabitDialog() async {
    final ctrl = TextEditingController();
    final res = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add habit'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Habit title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (res != null && res.isNotEmpty) {
      final k = _keyFor(_selectedDate);
      setState(() {
        _ensureDateHasHabits(_selectedDate);
        _habitData[k]!.add({'title': res, 'done': false});
      });
    }
  }

  void _deleteHabit(int index) {
    final k = _keyFor(_selectedDate);
    setState(() => _habitData[k]!.removeAt(index));
  }

  List<DateTime> _getWeekDates(DateTime current) {
    final startOfWeek = current.subtract(Duration(days: current.weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'User';
    _ensureDateHasHabits(_selectedDate);
    final habits = _habitData[_keyFor(_selectedDate)]!;
    final progress = _calculateProgress();
    final randomQuote = _quotes[Random().nextInt(_quotes.length)];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FB),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom:
                    kBottomNavigationBarHeight +
                    MediaQuery.of(context).padding.bottom +
                    8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== HEADER =====
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.purple.shade200,
                              backgroundImage: const AssetImage(
                                'assets/images/sylver01.jpg',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Hello,\n${email.split('@')[0]}",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          tooltip: 'Sign out',
                          icon: const Icon(Icons.logout, color: Colors.purple),
                          onPressed: _signUserOut,
                        ),
                      ],
                    ),
                  ),

                  // ===== MOTIVATION CARD =====
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            randomQuote,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== WEEKLY CALENDAR =====
                  Container(
                    height: 95,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        final weekDates = _getWeekDates(DateTime.now());
                        final date = weekDates[index];
                        final isSelected =
                            _selectedDate.day == date.day &&
                            _selectedDate.month == date.month;

                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedDate = date;
                            _ensureDateHasHabits(date);
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.all(12),
                            width: 65,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  [
                                    "Mon",
                                    "Tue",
                                    "Wed",
                                    "Thu",
                                    "Fri",
                                    "Sat",
                                    "Sun",
                                  ][date.weekday - 1],
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date.day.toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ===== PROGRESS TRACKER =====
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Progress Today",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.purple,
                          backgroundColor: Colors.purple.shade100,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${(progress * 100).toStringAsFixed(0)}% completed",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== HABITS LIST =====
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Habits — ${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _addHabitDialog,
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),

                  ...habits.asMap().entries.map((entry) {
                    final index = entry.key;
                    final habit = entry.value;
                    final done = habit['done'] as bool;

                    return Slidable(
                      key: ValueKey(index),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.25,
                        children: [
                          SlidableAction(
                            onPressed: (_) => _deleteHabit(index),
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () => _toggleHabit(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: done ? Colors.green.shade100 : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(
                              done
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: done ? Colors.green : Colors.purple,
                            ),
                            title: Text(
                              habit['title'],
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: done ? Colors.grey : Colors.black,
                                decoration: done
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // ===== Confetti Layer =====
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.purple,
                Colors.deepPurple,
                Colors.green,
                Colors.yellow,
                Colors.blue,
              ],
              gravity: 0.3,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 20,
              minBlastForce: 10,
            ),
          ),
        ],
      ),

      // ===== BOTTOM NAV =====
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.deepPurple.shade300,
        buttonBackgroundColor: Colors.deepPurple,
        animationDuration: const Duration(milliseconds: 300),
        index: _currentIndex,
        items: const [
          Icon(Icons.home_outlined, size: 30, color: Colors.white),
          Icon(Icons.list_alt, size: 30, color: Colors.white),
          Icon(Icons.add, size: 30, color: Colors.white),
          Icon(Icons.person_outline, size: 30, color: Colors.white),
          Icon(Icons.settings_outlined, size: 30, color: Colors.white),
        ],
        onTap: (index) async {
          setState(() => _currentIndex = index);
          if (index == 2) {
            await _addHabitDialog();
          } else if (index == 1) {
            // Navigate to WeeklyHabitsPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WeeklyHabitsPage(habitData: _habitData),
              ),
            );
          }
        },
      ),
    );
  }
}
