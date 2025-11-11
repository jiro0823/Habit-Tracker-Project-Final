import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
//import 'package:my_app/pages/login_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // purple gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  children: const [
                    OnboardPage(
                      image: 'assets/images/intro1.png',
                      title: 'Track Your Habits',
                      description:
                          'Every check-in brings you one step closer to the best version of yourself',
                    ),
                    OnboardPage(
                      image: 'assets/images/intro2.png',
                      title: 'Stay Consistent',
                      description:
                          'Track your daily habits, stay consistent, and watch your progress grow.',
                      showButton: true,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: 2,
                  effect: const ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 8,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardPage extends StatelessWidget {
  final String image, title, description;
  final bool showButton;

  const OnboardPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    this.showButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Image.asset(image, height: 280),
          const SizedBox(height: 30),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 40),
          if (showButton)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6A0DAD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
              ),
              onPressed: () {
                // Navigate to LoginPage
                Navigator.pushReplacementNamed(context, '/auth');
              },
              child: Text(
                "Proceed",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
