import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();
    // System UI customization
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _blurAnimation = Tween<double>(begin: 25.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Navigate to /home after animation completes
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        context.go('/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E11),
      body: Stack(
        children: [
          // Background subtle ambient gradients
          Positioned(
            top: -size.height * 0.2,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.2,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF59E0B).withOpacity(0.08),
              ),
            ),
          ),
          // Main Content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glowing Animated Icon Container
                    Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFF59E0B), // Gold
                                Color(0xFF10B981), // Emerald Green
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withOpacity(0.3),
                                blurRadius: _blurAnimation.value * 2,
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: const Color(0xFF10B981).withOpacity(0.2),
                                blurRadius: _blurAnimation.value * 3,
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 104,
                              height: 104,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E2026),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.diamond_rounded,
                                size: 54,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Title
                    Opacity(
                      opacity: _textOpacityAnimation.value,
                      child: Column(
                        children: [
                          Text(
                            'TRILLIONAIRE LIFE',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6.0,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Subtitle/Tagline
                          Text(
                            'DESIGN YOUR WEALTH VELOCITY',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.5,
                              color: const Color(0xFF10B981).withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
