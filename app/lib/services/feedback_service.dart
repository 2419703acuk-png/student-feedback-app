import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/feedback_model.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all feedback
  Stream<List<FeedbackModel>> getAllFeedback() {
    return _firestore
        .collection('feedback')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) {
                  try {
                    return FeedbackModel.fromMap(doc.data(), doc.id);
                  } catch (e) {
                    debugPrint('Error creating FeedbackModel from doc ${doc.id}: $e');
                    return null;
                  }
                })
                .where((feedback) => feedback != null)
                .cast<FeedbackModel>()
                .toList();
          } catch (e) {
            debugPrint('Error processing feedback snapshot: $e');
            return <FeedbackModel>[];
          }
        });
  }

  // Get feedback by status
  Stream<List<FeedbackModel>> getFeedbackByStatus(String status) {
    return _firestore
        .collection('feedback')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromMap(doc.data(), doc.id))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  // Get feedback by type
  Stream<List<FeedbackModel>> getFeedbackByType(String type) {
    return _firestore
        .collection('feedback')
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromMap(doc.data(), doc.id))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  // Get feedback by course
  Stream<List<FeedbackModel>> getFeedbackByCourse(String courseId) {
    return _firestore
        .collection('feedback')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromMap(doc.data(), doc.id))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  // Get feedback by user
  Stream<List<FeedbackModel>> getFeedbackByUser(String userId) {
    return _firestore
        .collection('feedback')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromMap(doc.data(), doc.id))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  // Get feedback by ID
  Future<FeedbackModel?> getFeedbackById(String feedbackId) async {
    try {
      final doc = await _firestore.collection('feedback').doc(feedbackId).get();
      if (doc.exists) {
        return FeedbackModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get feedback: $e');
    }
  }

  // Create new feedback
  Future<String> createFeedback(FeedbackModel feedback) async {
    try {
      final docRef = await _firestore.collection('feedback').add(feedback.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create feedback: $e');
    }
  }

  // Update feedback
  Future<void> updateFeedback(String feedbackId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('feedback').doc(feedbackId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update feedback: $e');
    }
  }

  // Delete feedback
  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _firestore.collection('feedback').doc(feedbackId).delete();
    } catch (e) {
      throw Exception('Failed to delete feedback: $e');
    }
  }

  // Update feedback status
  Future<void> updateFeedbackStatus(String feedbackId, String newStatus) async {
    try {
      await _firestore.collection('feedback').doc(feedbackId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update feedback status: $e');
    }
  }

  // Search feedback
  Stream<List<FeedbackModel>> searchFeedback(String query) {
    return _firestore
        .collection('feedback')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromMap(doc.data(), doc.id))
            .where((feedback) => 
                feedback.title.toLowerCase().contains(query.toLowerCase()) ||
                feedback.content.toLowerCase().contains(query.toLowerCase()))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  // Get feedback statistics
  Future<Map<String, int>> getFeedbackStatistics() async {
    try {
      final feedbackSnapshot = await _firestore.collection('feedback').get();
      final feedbacks = feedbackSnapshot.docs
          .map((doc) {
            try {
              return FeedbackModel.fromMap(doc.data(), doc.id);
            } catch (e) {
              // Skip invalid feedback documents
              return null;
            }
          })
          .where((feedback) => feedback != null)
          .cast<FeedbackModel>()
          .toList();

      int totalFeedback = feedbacks.length;
      int pendingFeedback = feedbacks.where((f) => f.status == 'pending').length;
      int resolvedFeedback = feedbacks.where((f) => f.status == 'resolved').length;
      int inProgressFeedback = feedbacks.where((f) => f.status == 'in_progress').length;

      // Count by type
      int suggestions = feedbacks.where((f) => f.type == 'suggestion').length;
      int complaints = feedbacks.where((f) => f.type == 'complaint').length;
      int general = feedbacks.where((f) => f.type == 'general').length;

      return {
        'total': totalFeedback,
        'pending': pendingFeedback,
        'resolved': resolvedFeedback,
        'inProgress': inProgressFeedback,
        'suggestions': suggestions,
        'complaints': complaints,
        'general': general,
      };
    } catch (e) {
      throw Exception('Failed to get feedback statistics: $e');
    }
  }

  // Get feedback by date range
  Stream<List<FeedbackModel>> getFeedbackByDateRange(DateTime startDate, DateTime endDate) {
    return _firestore
        .collection('feedback')
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .where('createdAt', isLessThanOrEqualTo: endDate)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromMap(doc.data(), doc.id))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }
}
