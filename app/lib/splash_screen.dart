import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'dart:math';
import 'login_page.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _titleController;
  late AnimationController _particleController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titleScaleAnimation;
  late Animation<double> _particleAnimation;
  
  // Gradient animation controller
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;
  
  // Confetti controller
  late ConfettiController _confettiController;
  
  // Colors for gradient animation
  final List<Color> _gradientColors = [
    const Color(0xFF1E3C72),
    const Color(0xFF2A5298),
    const Color(0xFF4A90E2),
    const Color(0xFF7BB3F0),
    const Color(0xFF1E3C72),
  ];

  // Particle system
  final List<Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    // Initialize confetti controller
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    // Initialize logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    // Initialize title animation controller
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Initialize particle animation controller
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    // Initialize gradient animation controller
    _gradientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    // Setup logo scale animation with bounce effect
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    // Setup title fade and scale animations
    _titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    ));
    
    _titleScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
    ));
    
    // Setup particle animation
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));
    
    // Setup gradient animation
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));
    
    // Generate particles
    _generateParticles();
    
    // Start animations
    _startAnimations();
    
    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      _checkAuthAndNavigate();
    });
  }

  void _generateParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(Particle(
        x: _random.nextDouble() * 400,
        y: _random.nextDouble() * 800,
        size: _random.nextDouble() * 3 + 1,
        speed: _random.nextDouble() * 2 + 0.5,
        opacity: _random.nextDouble() * 0.5 + 0.2,
      ));
    }
  }

  void _startAnimations() {
    // Start logo animation
    _logoController.forward();
    
    // Start title animation after a delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      _titleController.forward();
      _confettiController.play();
    });
    
    // Start particle animation
    _particleController.repeat();
    
    // Start gradient animation
    _gradientController.repeat();
  }

  void _checkAuthAndNavigate() async {
    try {
      // Check Firebase Authentication state
      final user = FirebaseAuth.instance.currentUser;
      
      debugPrint('SplashScreen - Current user: ${user?.email}');
      
      if (mounted) {
        if (user != null) {
          // User is logged in, check their role and navigate accordingly
          try {
            // Get user data from Firestore to check role
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
            
            if (!mounted) return; // Check if still mounted after async operation
            
            if (userDoc.exists) {
              final userData = userDoc.data()!;
              final role = userData['role'] ?? 'student';
              final email = user.email?.toLowerCase() ?? '';
              
              debugPrint('SplashScreen - User role: $role, email: $email');
              
              // Determine navigation based on role or email
              String route;
              if (role == 'admin' || email.contains('admin') || email.contains('@admin')) {
                route = '/admin';
              } else {
                route = '/student';
              }
              
              debugPrint('SplashScreen - Navigating to: $route');
              Navigator.pushReplacementNamed(context, route);
            } else {
              // User document doesn't exist, use email-based logic
              final email = user.email?.toLowerCase() ?? '';
              debugPrint('SplashScreen - No user doc, email: $email');
              
              if (email.contains('admin') || email.contains('@admin')) {
                Navigator.pushReplacementNamed(context, '/admin');
              } else {
                Navigator.pushReplacementNamed(context, '/student');
              }
            }
          } catch (e) {
            debugPrint('SplashScreen - Error getting user data: $e');
            
            if (!mounted) return; // Check if still mounted after async operation
            
            // If there's an error getting user data, use email-based logic
            final email = user.email?.toLowerCase() ?? '';
            if (email.contains('admin') || email.contains('@admin')) {
              Navigator.pushReplacementNamed(context, '/admin');
            } else {
              Navigator.pushReplacementNamed(context, '/student');
            }
          }
        } else {
          // User is not logged in, navigate to LoginPage
          debugPrint('SplashScreen - No user, navigating to login');
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      debugPrint('SplashScreen - Error in auth check: $e');
      
      // Handle any errors and navigate to login page
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _titleController.dispose();
    _particleController.dispose();
    _gradientController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _gradientAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getAnimatedGradientColors(),
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
              );
            },
          ),
          
          // Particle System
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particles, _particleAnimation.value),
                size: Size.infinite,
              );
            },
          ),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
          
          // Main Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // University Logo with Enhanced Animation
                  ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 50,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                      child: Lottie.asset(
                        'assets/uni_logo.json',
                        controller: _logoController,
                        repeat: false,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ).animate().shimmer(duration: 2000.ms, delay: 1000.ms),
                  
                  const SizedBox(height: 50),
                  
                  // Animated Title
                  FadeTransition(
                    opacity: _titleFadeAnimation,
                    child: ScaleTransition(
                      scale: _titleScaleAnimation,
                      child: Column(
                        children: [
                          AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                'Student Feedback App',
                                textStyle: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2, 2),
                                      blurRadius: 4,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                                speed: const Duration(milliseconds: 100),
                              ),
                            ],
                            totalRepeatCount: 1,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'University of Chester',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9),
                              shadows: [
                                Shadow(
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black.withValues(alpha: 0.3),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 1500.ms).slideY(begin: 0.3),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // Enhanced Loading Indicator
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 4,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn(delay: 2000.ms),
                      ],
                    ),
                  ).animate().fadeIn(delay: 1800.ms).scale(begin: const Offset(0.8, 0.8)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getAnimatedGradientColors() {
    final progress = _gradientAnimation.value;
    final colorIndex = (progress * (_gradientColors.length - 1)).floor();
    final nextColorIndex = (colorIndex + 1) % _gradientColors.length;
    final localProgress = (progress * (_gradientColors.length - 1)) - colorIndex;
    
    return [
      Color.lerp(_gradientColors[colorIndex], _gradientColors[nextColorIndex], localProgress)!,
      Color.lerp(_gradientColors[(colorIndex + 1) % _gradientColors.length], 
                 _gradientColors[(colorIndex + 2) % _gradientColors.length], localProgress)!,
      Color.lerp(_gradientColors[(colorIndex + 2) % _gradientColors.length], 
                 _gradientColors[(colorIndex + 3) % _gradientColors.length], localProgress)!,
      Color.lerp(_gradientColors[(colorIndex + 3) % _gradientColors.length], 
                 _gradientColors[(colorIndex + 4) % _gradientColors.length], localProgress)!,
      Color.lerp(_gradientColors[(colorIndex + 4) % _gradientColors.length], 
                 _gradientColors[colorIndex], localProgress)!,
    ];
  }
}

// Particle class for background effects
class Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;
  double angle;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  }) : angle = 0;

  void update(double deltaTime) {
    angle += speed * deltaTime;
    y += speed * deltaTime;
    
    if (y > 800) {
      y = -50;
    }
  }
}

// Custom painter for particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      particle.update(animationValue);
      
      paint.color = Colors.white.withValues(alpha: particle.opacity);
      
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
