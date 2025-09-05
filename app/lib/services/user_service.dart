import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all users
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          try {
            return snapshot.docs
                .map((doc) {
                  try {
                    return UserModel.fromMap(doc.data(), doc.id);
                  } catch (e) {
                    debugPrint('Error creating UserModel from doc ${doc.id}: $e');
                    return null;
                  }
                })
                .where((user) => user != null)
                .cast<UserModel>()
                .toList();
          } catch (e) {
            debugPrint('Error processing users snapshot: $e');
            return <UserModel>[];
          }
        });
  }

  // Get users by role
  Stream<List<UserModel>> getUsersByRole(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              try {
                return UserModel.fromMap(doc.data(), doc.id);
              } catch (e) {
                // Skip invalid user documents
                return null;
              }
            })
            .where((user) => user != null)
            .cast<UserModel>()
            .toList());
  }

  // Get active users
  Stream<List<UserModel>> getActiveUsers() {
    return _firestore
        .collection('users')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              try {
                return UserModel.fromMap(doc.data(), doc.id);
              } catch (e) {
                // Skip invalid user documents
                return null;
              }
            })
            .where((user) => user != null)
            .cast<UserModel>()
            .toList());
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Create new user
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Toggle user active status
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to toggle user status: $e');
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      final permissions = _getDefaultPermissions(newRole);
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
        'permissions': permissions,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  // Search users
  Stream<List<UserModel>> searchUsers(String query) {
    return _firestore
        .collection('users')
        .orderBy('name')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              try {
                return UserModel.fromMap(doc.data(), doc.id);
              } catch (e) {
                // Skip invalid user documents
                return null;
              }
            })
            .where((user) => user != null)
            .cast<UserModel>()
            .toList());
  }

  // Get user statistics
  Future<Map<String, int>> getUserStatistics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final users = usersSnapshot.docs
          .map((doc) {
            try {
              return UserModel.fromMap(doc.data(), doc.id);
            } catch (e) {
              // Skip invalid user documents
              return null;
            }
          })
          .where((user) => user != null)
          .cast<UserModel>()
          .toList();

      int totalUsers = users.length;
      int activeUsers = users.where((user) => user.isActive).length;
      int adminUsers = users.where((user) => user.role == 'admin').length;
      int staffUsers = users.where((user) => user.role == 'staff').length;
      int studentUsers = users.where((user) => user.role == 'student').length;

      return {
        'total': totalUsers,
        'active': activeUsers,
        'admin': adminUsers,
        'staff': staffUsers,
        'student': studentUsers,
      };
    } catch (e) {
      throw Exception('Failed to get user statistics: $e');
    }
  }

  // Get default permissions based on role
  Map<String, dynamic> _getDefaultPermissions(String role) {
    switch (role) {
      case 'admin':
        return {
          'canManageUsers': true,
          'canManageFeedback': true,
          'canViewReports': true,
          'canManageSettings': true,
        };
      case 'staff':
        return {
          'canManageUsers': false,
          'canManageFeedback': true,
          'canViewReports': true,
          'canManageSettings': false,
        };
      case 'student':
        return {
          'canManageUsers': false,
          'canManageFeedback': false,
          'canViewReports': false,
          'canManageSettings': false,
        };
      default:
        return {};
    }
  }
}
