import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/feedback_model.dart';
import '../services/auth_service.dart';
import '../services/feedback_service.dart';

class StudentViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FeedbackService _feedbackService = FeedbackService();

  // State variables
  UserModel? _currentUser;
  List<FeedbackModel> _myFeedbacks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  List<FeedbackModel> get myFeedbacks => _myFeedbacks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize the view model
  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();
      
      // Get current user data
      await _loadCurrentUser();
      
      // Load user's feedback
      if (_currentUser != null) {
        await _loadMyFeedback();
      }
      
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
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
    }
  }

  // Load user's feedback
  Future<void> _loadMyFeedback() async {
    try {
      if (_currentUser != null) {
        _feedbackService.getFeedbackByUser(_currentUser!.id).listen(
          (feedbacks) {
            try {
              if (feedbacks is List<FeedbackModel>) {
                _myFeedbacks = feedbacks;
                notifyListeners();
              } else {
                debugPrint('Invalid feedback data type: ${feedbacks.runtimeType}');
                _myFeedbacks = [];
                notifyListeners();
              }
            } catch (e) {
              debugPrint('Error processing feedback data: $e');
              _myFeedbacks = [];
              notifyListeners();
            }
          },
          onError: (e) {
            debugPrint('Failed to load feedback: $e');
            _myFeedbacks = [];
            notifyListeners();
          },
        );
      }
    } catch (e) {
      debugPrint('Failed to load feedback: $e');
      _myFeedbacks = [];
      notifyListeners();
    }
  }

  // Submit new feedback
  Future<bool> submitFeedback({
    required String title,
    required String content,
    required String courseId,
    required String courseName,
    required String type,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentUser == null) {
        throw Exception('User not authenticated');
      }

      final feedback = FeedbackModel(
        id: '', // Will be set by Firestore
        userId: _currentUser!.id,
        userName: _currentUser!.name,
        courseId: courseId,
        courseName: courseName,
        title: title,
        content: content,
        type: type,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await _feedbackService.createFeedback(feedback);
      return true;
    } catch (e) {
      _setError('Failed to submit feedback: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String name,
    required String email,
    String? studentId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (_currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Update local user data
      _currentUser = _currentUser!.copyWith(
        name: name,
        email: email,
        studentId: studentId,
      );

      // Update in Firestore (you'll need to implement this in UserService)
      // await _userService.updateUser(_currentUser!.id, {
      //   'name': name,
      //   'email': email,
      //   'studentId': studentId,
      // });

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update feedback
  Future<bool> updateFeedback({
    required String feedbackId,
    required String title,
    required String content,
    required String type,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      await _feedbackService.updateFeedback(feedbackId, {
        'title': title,
        'content': content,
        'type': type,
      });

      return true;
    } catch (e) {
      _setError('Failed to update feedback: $e');
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

  // Get feedback by ID
  Future<FeedbackModel?> getFeedbackById(String feedbackId) async {
    try {
      return await _feedbackService.getFeedbackById(feedbackId);
    } catch (e) {
      _setError('Failed to get feedback: $e');
      return null;
    }
  }

  // Search feedback
  Future<List<FeedbackModel>> searchMyFeedback(String query) async {
    try {
      if (_currentUser == null) return [];

      // Get all user feedback and filter locally for now
      // In a real app, you might want to implement server-side search
      final allFeedback = await _feedbackService.getFeedbackByUser(_currentUser!.id).first;
      return allFeedback.where((feedback) =>
        feedback.title.toLowerCase().contains(query.toLowerCase()) ||
        feedback.content.toLowerCase().contains(query.toLowerCase()) ||
        feedback.courseName.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      _setError('Failed to search feedback: $e');
      return [];
    }
  }

  // Get feedback statistics
  Map<String, int> getFeedbackStatistics() {
    if (_myFeedbacks.isEmpty) {
      return {
        'total': 0,
        'pending': 0,
        'in_progress': 0,
        'resolved': 0,
        'suggestions': 0,
        'complaints': 0,
        'general': 0,
      };
    }

    int totalFeedback = _myFeedbacks.length;
    int pendingFeedback = _myFeedbacks.where((f) => f.status == 'pending').length;
    int inProgressFeedback = _myFeedbacks.where((f) => f.status == 'in_progress').length;
    int resolvedFeedback = _myFeedbacks.where((f) => f.status == 'resolved').length;

    // Count by type
    int suggestions = _myFeedbacks.where((f) => f.type == 'suggestion').length;
    int complaints = _myFeedbacks.where((f) => f.type == 'complaint').length;
    int general = _myFeedbacks.where((f) => f.type == 'general').length;

    return {
      'total': totalFeedback,
      'pending': pendingFeedback,
      'in_progress': inProgressFeedback,
      'resolved': resolvedFeedback,
      'suggestions': suggestions,
      'complaints': complaints,
      'general': general,
    };
  }

  // Get feedback by status
  List<FeedbackModel> getFeedbackByStatus(String status) {
    if (status == 'all') return _myFeedbacks;
    return _myFeedbacks.where((f) => f.status == status).toList();
  }

  // Get feedback by type
  List<FeedbackModel> getFeedbackByType(String type) {
    if (type == 'all') return _myFeedbacks;
    return _myFeedbacks.where((f) => f.type == type).toList();
  }

  // Get recent feedback
  List<FeedbackModel> getRecentFeedback({int limit = 5}) {
    final sortedFeedback = List<FeedbackModel>.from(_myFeedbacks)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return sortedFeedback.take(limit).toList();
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _myFeedbacks.clear();
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out: $e');
    }
  }

  // Refresh data
  Future<void> refresh() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _loadCurrentUser();
      if (_currentUser != null) {
        await _loadMyFeedback();
      }
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
