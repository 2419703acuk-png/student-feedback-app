import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/feedback_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/feedback_service.dart';

class AdminViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final FeedbackService _feedbackService = FeedbackService();

  // State variables
  UserModel? _currentUser;
  List<UserModel> _users = [];
  List<FeedbackModel> _feedbacks = [];
  Map<String, int> _userStats = {};
  Map<String, int> _feedbackStats = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  List<UserModel> get users => _users;
  List<FeedbackModel> get feedbacks => _feedbacks;
  Map<String, int> get userStats => _userStats;
  Map<String, int> get feedbackStats => _feedbackStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize the view model
  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Get current user data
      await _loadCurrentUser();
      
      // Load initial data with timeout
      await Future.wait([
        _loadUserStatistics(),
        _loadFeedbackStatistics(),
      ]).timeout(const Duration(seconds: 10));
      
      // Start listening to real-time updates
      _startListening();
      
      // Keep loading until we have some data
      _setLoading(false);
      
    } catch (e) {
      _setError('Failed to initialize: $e');
      _setLoading(false);
    }
  }

  // Load current user data
  Future<void> _loadCurrentUser() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        _currentUser = await _authService.getUserData(user.uid);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load user data: $e');
      // Don't set error for user data loading failure, just log it
      // This prevents the app from crashing if user data is not available
    }
  }

  // Start listening to real-time updates
  void _startListening() {
    // Listen to users
    _userService.getAllUsers().listen(
      (users) {
        try {
          if (users is List<UserModel>) {
            _users = users;
            notifyListeners();
          } else {
            debugPrint('Invalid users data type: ${users.runtimeType}');
            _users = [];
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Error processing users data: $e');
          _users = [];
          notifyListeners();
        }
      },
      onError: (e) {
        debugPrint('Failed to load users: $e');
        _users = [];
        notifyListeners();
      },
    );

    // Listen to feedback
    _feedbackService.getAllFeedback().listen(
      (feedbacks) {
        try {
          if (feedbacks is List<FeedbackModel>) {
            _feedbacks = feedbacks;
            notifyListeners();
          } else {
            debugPrint('Invalid feedback data type: ${feedbacks.runtimeType}');
            _feedbacks = [];
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Error processing feedback data: $e');
          _feedbacks = [];
          notifyListeners();
        }
      },
      onError: (e) {
        debugPrint('Failed to load feedback: $e');
        _feedbacks = [];
        notifyListeners();
      },
    );
  }

  // Load user statistics
  Future<void> _loadUserStatistics() async {
    try {
      _userStats = await _userService.getUserStatistics();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load user statistics: $e');
      // Set default stats if loading fails
      _userStats = {'total': 0, 'active': 0, 'inactive': 0};
      notifyListeners();
    }
  }

  // Load feedback statistics
  Future<void> _loadFeedbackStatistics() async {
    try {
      _feedbackStats = await _feedbackService.getFeedbackStatistics();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load feedback statistics: $e');
      // Set default stats if loading fails
      _feedbackStats = {'total': 0, 'pending': 0, 'resolved': 0};
      notifyListeners();
    }
  }

  // Create new user
  Future<bool> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.createUserWithEmailAndPassword(
        email,
        password,
        name,
        role,
      );

      return true;
    } catch (e) {
      _setError('Failed to create user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user role
  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      _setLoading(true);
      _clearError();

      await _userService.updateUserRole(userId, newRole);
      return true;
    } catch (e) {
      _setError('Failed to update user role: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Toggle user status
  Future<bool> toggleUserStatus(String userId, bool isActive) async {
    try {
      _setLoading(true);
      _clearError();

      await _userService.toggleUserStatus(userId, isActive);
      return true;
    } catch (e) {
      _setError('Failed to toggle user status: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update feedback status
  Future<bool> updateFeedbackStatus(String feedbackId, String newStatus) async {
    try {
      _setLoading(true);
      _clearError();

      await _feedbackService.updateFeedbackStatus(feedbackId, newStatus);
      return true;
    } catch (e) {
      _setError('Failed to update feedback status: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      await _userService.deleteUser(userId);
      return true;
    } catch (e) {
      _setError('Failed to delete user: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete feedback
  Future<bool> deleteFeedback(String feedbackId) async {
    try {
      _setLoading(true);
      _clearError();

      await _feedbackService.deleteFeedback(feedbackId);
      return true;
    } catch (e) {
      _setError('Failed to delete feedback: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _users.clear();
      _feedbacks.clear();
      _userStats.clear();
      _feedbackStats.clear();
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out: $e');
    }
  }

  // Check if user has permission
  bool hasPermission(String permission) {
    if (_currentUser == null) return false;
    return _currentUser!.permissions[permission] == true;
  }

  // Refresh data
  Future<void> refresh() async {
    try {
      _setLoading(true);
      _clearError();
      
      await Future.wait([
        _loadUserStatistics(),
        _loadFeedbackStatistics(),
      ]);
    } catch (e) {
      _setError('Failed to refresh: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // No custom disposal needed
}
