import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Durée totale du splash screen (4 secondes)
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      context.go('/'); // Navigue vers l'écran principal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou icône (optionnel)
            const Icon(
              Icons.travel_explore,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 40),
            
            // Animation de texte
            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 45.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Touris',
                    speed: const Duration(milliseconds: 200),
                  ),
                ],
                totalRepeatCount: 1,
                pause: const Duration(milliseconds: 500),
              ),
            ),
            const SizedBox(height: 20),
            
            // Sous-titre avec animation fade
            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 18.0,
                color: Colors.white70,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  FadeAnimatedText(
                    'Discover Haiti',
                    duration: const Duration(seconds: 2),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
