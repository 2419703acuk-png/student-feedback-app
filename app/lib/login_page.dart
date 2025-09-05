import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showCredentialFeedback = false;
  late AnimationController _animationController;
  late AnimationController _formAnimationController;
  late AnimationController _successController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _formScaleAnimation;
  late Animation<double> _formFadeAnimation;
  
  // Confetti controller for successful login
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    
    // Initialize confetti controller
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    // Main animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Form animation controller
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Success animation controller
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _formScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeIn,
    ));
    
    // Start animations
    _animationController.forward();
    
    // Start form animation after a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _formAnimationController.forward();
    });
    
    // Pre-fill demo credentials
    _emailController.text = 'admin@university.edu';
    _passwordController.text = 'admin123';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    _formAnimationController.dispose();
    _successController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Add a small delay to prevent rapid auth calls
      await Future.delayed(const Duration(milliseconds: 100));
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Play success animation
        _successController.forward();
        _confettiController.play();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Login successful!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Check if user is admin or student based on email domain or user data
        final user = userCredential.user;
        if (user != null) {
          try {
            // Get user data from Firestore to check role
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();
            
            if (!mounted) return; // Check if still mounted after async operation
            
            String route;
            if (userDoc.exists) {
              final userData = userDoc.data()!;
              final role = userData['role'] ?? 'student';
              final email = user.email?.toLowerCase() ?? '';
              
              debugPrint('Login - User document exists: role=$role, email=$email');
              
              // Determine navigation based on role or email
              if (role == 'admin' || email.contains('admin') || email.contains('@admin')) {
                route = '/admin';
                debugPrint('Login - Navigating to admin route');
              } else {
                route = '/student';
                debugPrint('Login - Navigating to student route');
              }
            } else {
              // User document doesn't exist, use email-based logic
              final email = user.email?.toLowerCase() ?? '';
              debugPrint('Login - No user document, using email logic: $email');
              
              if (email.contains('admin') || email.contains('@admin')) {
                route = '/admin';
                debugPrint('Login - Navigating to admin route (email logic)');
              } else {
                route = '/student';
                debugPrint('Login - Navigating to student route (email logic)');
              }
            }
            
            // Add delay for animation to complete
            await Future.delayed(const Duration(milliseconds: 1500));
            if (mounted) {
              Navigator.pushReplacementNamed(context, route);
            }
          } catch (e) {
            if (!mounted) return; // Check if still mounted after async operation
            
            // If there's an error getting user data, use email-based logic
            final email = user.email?.toLowerCase() ?? '';
            if (email.contains('admin') || email.contains('@admin')) {
              Navigator.pushReplacementNamed(context, '/admin');
            } else {
              Navigator.pushReplacementNamed(context, '/student');
            }
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred during sign in.';
      
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email address.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Please try again later.';
          break;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if (mounted) {
        String errorMessage = 'An unexpected error occurred during login.';
        
        // Handle specific Firebase Auth errors
        if (e.toString().contains('PigeonUserDetails')) {
          // Try to get current user and proceed with login
          final currentUser = _auth.currentUser;
          if (currentUser != null) {
            // User is already logged in, proceed with navigation
            try {
              final userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .get();
              
              if (!mounted) return; // Check if still mounted after async operation
              
              String route;
              if (userDoc.exists) {
                final userData = userDoc.data()!;
                final role = userData['role'] ?? 'student';
                final email = currentUser.email?.toLowerCase() ?? '';
                
                if (role == 'admin' || email.contains('admin') || email.contains('@admin')) {
                  route = '/admin';
                } else {
                  route = '/student';
                }
              } else {
                final email = currentUser.email?.toLowerCase() ?? '';
                if (email.contains('admin') || email.contains('@admin')) {
                  route = '/admin';
                } else {
                  route = '/student';
                }
              }
              
              Navigator.pushReplacementNamed(context, route);
              return; // Exit early
            } catch (navError) {
              debugPrint('Navigation error: $navError');
              errorMessage = 'Login successful but navigation failed. Please try again.';
            }
          } else {
            errorMessage = 'Authentication service error. Please try again.';
          }
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Request timeout. Please try again.';
        } else {
          errorMessage = 'An unexpected error occurred: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E3C72),
                  Color(0xFF2A5298),
                  Color(0xFF4A90E2),
                  Color(0xFF7BB3F0),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ).animate().fadeIn(duration: 1000.ms),
          
          // Confetti for success
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Enhanced Animated Education Logo
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.9),
                                Colors.blue.withValues(alpha: 0.1),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.6),
                                blurRadius: 40,
                                spreadRadius: 15,
                              ),
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.4),
                                blurRadius: 60,
                                spreadRadius: 25,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Rotating outer ring
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 3,
                                  ),
                                ),
                              ).animate(onPlay: (controller) => controller.repeat())
                                .rotate(duration: 8000.ms, curve: Curves.linear),
                              
                              // Main education icon
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.95),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.school,
                                  size: 50,
                                  color: Colors.blue.shade700,
                                ),
                              ).animate()
                                .scale(duration: 1000.ms, curve: Curves.elasticOut)
                                .then()
                                .animate(onPlay: (controller) => controller.repeat())
                                .shimmer(duration: 2000.ms, delay: 2000.ms),
                              
                              // Floating particles
                              ...List.generate(6, (index) {
                                return Positioned(
                                  left: 20 + (index * 20),
                                  top: 20 + (index * 15),
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue.withValues(alpha: 0.6),
                                    ),
                                  ).animate(onPlay: (controller) => controller.repeat())
                                    .fadeIn(delay: (index * 200).ms)
                                    .then()
                                    .fadeOut(delay: 1000.ms)
                                    .then()
                                    .scale(delay: 500.ms),
                                );
                              }),
                            ],
                          ),
                        ).animate()
                          .fadeIn(duration: 800.ms)
                          .scale(duration: 1200.ms, curve: Curves.elasticOut)
                          .then()
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(duration: 3000.ms, delay: 3000.ms),
                        
                        const SizedBox(height: 40),
                        
                        // Animated Title
                        AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'Welcome Back',
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
                          'Sign in to your account',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn(delay: 1500.ms).slideY(begin: 0.3),
                        
                        const SizedBox(height: 60),
                        
                        // Enhanced Login Form
                        FadeTransition(
                          opacity: _formFadeAnimation,
                          child: ScaleTransition(
                            scale: _formScaleAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    blurRadius: 50,
                                    offset: const Offset(0, 25),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Enhanced Email Field
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        hintText: 'Enter your email',
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: _showCredentialFeedback ? Colors.green.shade600 : Colors.grey.shade600,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                            color: _showCredentialFeedback ? Colors.green.shade400 : Colors.grey.shade300,
                                            width: _showCredentialFeedback ? 2.0 : 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                            color: _showCredentialFeedback ? Colors.green.shade600 : const Color(0xFF4A90E2),
                                            width: 2.5,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: _showCredentialFeedback ? Colors.green.shade50 : Colors.grey.shade50,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ).animate().fadeIn(delay: 2000.ms).slideX(begin: -0.3),
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Enhanced Password Field
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        hintText: 'Enter your password',
                                        prefixIcon: Icon(
                                          Icons.lock_outlined,
                                          color: _showCredentialFeedback ? Colors.green.shade600 : Colors.grey.shade600,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                            color: _showCredentialFeedback ? Colors.green.shade600 : Colors.grey.shade600,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                            color: _showCredentialFeedback ? Colors.green.shade400 : Colors.grey.shade300,
                                            width: _showCredentialFeedback ? 2.0 : 1.5,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                            color: _showCredentialFeedback ? Colors.green.shade600 : const Color(0xFF4A90E2),
                                            width: 2.5,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: _showCredentialFeedback ? Colors.green.shade50 : Colors.grey.shade50,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ).animate().fadeIn(delay: 2200.ms).slideX(begin: 0.3),
                                    
                                    const SizedBox(height: 40),
                                    
                                    // Enhanced Sign In Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _signIn,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF4A90E2),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          elevation: 4,
                                          shadowColor: const Color(0xFF4A90E2).withValues(alpha: 0.3),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                ),
                                              )
                                            : const Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ).animate().fadeIn(delay: 2400.ms).scale(begin: const Offset(0.8, 0.8)),
                                    
                                    const SizedBox(height: 32),
                                    
                                    // Enhanced Demo Credentials
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.blue.shade50,
                                            Colors.blue.shade100,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Colors.blue.shade700,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Demo Credentials',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue.shade800,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          _buildCredentialRow('Admin', 'admin@university.edu', 'admin123'),
                                          const SizedBox(height: 8),
                                          _buildCredentialRow('Student', 'student@university.edu', 'student123'),
                                        ],
                                      ),
                                    ).animate().fadeIn(delay: 2600.ms).slideY(begin: 0.3),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Amazing Test Buttons
                                    Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        Text(
                                          'Quick Credential Fill',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ).animate().fadeIn(delay: 2800.ms),
                                        const SizedBox(height: 16),
                                        Column(
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.orange.shade400,
                                                    Colors.orange.shade600,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.orange.withValues(alpha: 0.4),
                                                    blurRadius: 15,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () async {
                                                    debugPrint('Test: Pre-filling admin credentials');
                                                    _confettiController.play();
                                                    
                                                    // Fill credentials with visual feedback
                                                    setState(() {
                                                      _emailController.text = 'admin@university.edu';
                                                      _passwordController.text = 'admin123';
                                                      _showCredentialFeedback = true;
                                                    });
                                                    
                                                    // Add a small delay to ensure setState completes
                                                    await Future.delayed(const Duration(milliseconds: 100));
                                                    
                                                    // Show a message that credentials are filled
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Row(
                                                            children: [
                                                              const Icon(Icons.check_circle, color: Colors.white),
                                                              const SizedBox(width: 8),
                                                              const Expanded(
                                                                child: Text(
                                                                  'Admin credentials filled! Click Sign In to continue.',
                                                                  style: TextStyle(fontWeight: FontWeight.w500),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          backgroundColor: Colors.orange.shade600,
                                                          behavior: SnackBarBehavior.floating,
                                                          duration: const Duration(seconds: 4),
                                                          margin: const EdgeInsets.all(16),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    
                                                    // Remove visual feedback after 2 seconds
                                                    Future.delayed(const Duration(seconds: 2), () {
                                                      if (mounted) {
                                                        setState(() {
                                                          _showCredentialFeedback = false;
                                                        });
                                                      }
                                                    });
                                                  },
                                                  borderRadius: BorderRadius.circular(16),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          Icons.admin_panel_settings,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          'Fill Admin Credentials',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ).animate()
                                              .fadeIn(delay: 3000.ms)
                                              .slideY(begin: -0.3, duration: 400.ms, curve: Curves.easeOutBack)
                                              .then()
                                              .animate(onPlay: (controller) => controller.repeat())
                                              .shimmer(duration: 2000.ms, delay: 4000.ms),
                                            const SizedBox(height: 12),
                                            Container(
                                              width: double.infinity,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.green.shade400,
                                                    Colors.green.shade600,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.green.withValues(alpha: 0.4),
                                                    blurRadius: 15,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () async {
                                                    debugPrint('Test: Pre-filling student credentials');
                                                    _confettiController.play();
                                                    
                                                    // Fill credentials with visual feedback
                                                    setState(() {
                                                      _emailController.text = 'student@university.edu';
                                                      _passwordController.text = 'student123';
                                                      _showCredentialFeedback = true;
                                                    });
                                                    
                                                    // Add a small delay to ensure setState completes
                                                    await Future.delayed(const Duration(milliseconds: 100));
                                                    
                                                    // Show a message that credentials are filled
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Row(
                                                            children: [
                                                              const Icon(Icons.check_circle, color: Colors.white),
                                                              const SizedBox(width: 8),
                                                              const Expanded(
                                                                child: Text(
                                                                  'Student credentials filled! Click Sign In to continue.',
                                                                  style: TextStyle(fontWeight: FontWeight.w500),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          backgroundColor: Colors.green.shade600,
                                                          behavior: SnackBarBehavior.floating,
                                                          duration: const Duration(seconds: 4),
                                                          margin: const EdgeInsets.all(16),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    
                                                    // Remove visual feedback after 2 seconds
                                                    Future.delayed(const Duration(seconds: 2), () {
                                                      if (mounted) {
                                                        setState(() {
                                                          _showCredentialFeedback = false;
                                                        });
                                                      }
                                                    });
                                                  },
                                                  borderRadius: BorderRadius.circular(16),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          Icons.school,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          'Fill Student Credentials',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ).animate()
                                              .fadeIn(delay: 3200.ms)
                                              .slideY(begin: -0.3, duration: 400.ms, curve: Curves.easeOutBack)
                                              .then()
                                              .animate(onPlay: (controller) => controller.repeat())
                                              .shimmer(duration: 2000.ms, delay: 4500.ms),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String role, String email, String password) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: role == 'Admin' ? Colors.orange.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              role,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: role == 'Admin' ? Colors.orange.shade800 : Colors.green.shade800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  password,
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
