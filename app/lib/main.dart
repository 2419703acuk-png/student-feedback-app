import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'login_page.dart';
import 'views/admin/admin_panel_new.dart';
import 'views/admin/admin_dashboard.dart';
import 'views/admin/admin_users_page.dart';
import 'views/admin/admin_feedback_page.dart';
import 'views/admin/admin_reports_page.dart';
import 'views/admin/admin_settings_page.dart';
import 'views/student/student_dashboard.dart';
import 'views/student/submit_feedback_page.dart';
import 'views/student/feedback_history_page.dart';
import 'views/student/student_profile_page.dart';
import 'viewmodels/admin_viewmodel.dart';
import 'viewmodels/student_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
        ChangeNotifierProvider(create: (_) => StudentViewModel()),
      ],
      child: MaterialApp(
        title: 'Student Feedback App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        routes: {
          // Login route
          '/login': (context) => const LoginPage(),
          
          // Admin routes
          '/admin': (context) => const AdminPanelNew(),
          '/admin-dashboard': (context) => const AdminDashboard(),
          '/admin-users': (context) => const AdminUsersPage(),
          '/admin-feedback': (context) => const AdminFeedbackPage(),
          
          // Student routes
          '/student': (context) => const StudentDashboard(),
          
          // Admin section routes
          '/admin-notifications': (context) => const AdminNotificationsPage(),
          '/admin-reports': (context) => const AdminReportsPage(),
          '/admin-settings': (context) => const AdminSettingsPage(),
          
          // Student section routes
          '/submit-feedback': (context) => const SubmitFeedbackPage(),
          '/feedback-history': (context) => const FeedbackHistoryPage(),
          '/student-profile': (context) => const StudentProfilePage(),
        },
        onUnknownRoute: (settings) {
          // Fallback for unknown routes
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Page Not Found'),
                backgroundColor: Colors.red.shade900,
                foregroundColor: Colors.white,
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    const Text('Page Not Found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Route: ${settings.name}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('Go to Login'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Placeholder page for notifications (to be implemented)
class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Notifications Page - Coming Soon'),
      ),
    );
  }
}


