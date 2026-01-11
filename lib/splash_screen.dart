import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _buttonController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _buttonSlideAnimation;
  late Animation<double> _buttonOpacityAnimation;

  static const Color primaryTeal = Color(0xFF2DB5A5);
  static const Color darkTeal = Color(0xFF1A8B7F);
  static const Color lightTeal = Color(0xFF4DD0C0);
  static const Color accentTeal = Color(0xFF7FDED6);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _buttonController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _buttonSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOutBack),
    );

    _buttonOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeIn),
    );
  }

  void _startAnimationSequence() async {
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    await _buttonController.forward();

    // بعد الأنيميشن كله، تحقق من حالة الدخول
    await Future.delayed(const Duration(milliseconds: 1000));
    _checkLoginState();
  }

  void _checkLoginState() {
    final user = FirebaseAuth.instance.currentUser;
    if (mounted) {
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF0FDFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Opacity(
                          opacity: _logoOpacityAnimation.value,
                          child: _buildLogo(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _textFadeAnimation,
                        child: _buildAppName(),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _textFadeAnimation,
                        child: _buildSlogan(),
                      );
                    },
                  ),

                  const Spacer(flex: 2),

                  AnimatedBuilder(
                    animation: _buttonController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _buttonSlideAnimation.value),
                        child: Opacity(
                          opacity: _buttonOpacityAnimation.value,
                          child: _buildEnterButton(), // اختياري لو المستخدم عايز يتقدم يدوي
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: primaryTeal.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: primaryTeal,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                size: 100,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppName() {
    return Column(
      children: [
        Text(
          'Safe Space',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: primaryTeal,
            letterSpacing: 2.0,
            shadows: [
              Shadow(
                color: primaryTeal.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryTeal, lightTeal],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildSlogan() {
    return Column(
      children: [
        Text(
          'Your safe space for mental health',
          style: TextStyle(
            fontSize: 18,
            color: darkTeal,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: accentTeal.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentTeal.withOpacity(0.5)),
          ),
          child: Text(
            'We are with you every step of the way',
            style: TextStyle(
              fontSize: 16,
              color: darkTeal,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnterButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: _checkLoginState,
        icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        label: const Text(
          'Start Your Journey',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}
