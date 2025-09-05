import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      // Add a small delay to prevent rapid auth calls
      await Future.delayed(const Duration(milliseconds: 100));
      
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login only if user exists
      if (credential.user != null) {
        try {
          await _updateLastLogin(credential.user!.uid);
        } catch (e) {
          debugPrint('Failed to update last login: $e');
          // Don't throw error for this, just log it
        }
      }
      
      return credential;
    } catch (e) {
      debugPrint('Sign in error: $e');
      throw _handleAuthError(e);
    }
  }

  // Sign up with email and password
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
    String role,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _createUserDocument(
        credential.user!.uid,
        email,
        name,
        role,
      );

      return credential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(
    String uid,
    String email,
    String name,
    String role,
  ) async {
    try {
      final userData = {
        'email': email,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
        'permissions': _getDefaultPermissions(role),
      };

      await _firestore.collection('users').doc(uid).set(userData);
    } catch (e) {
      throw Exception('Failed to create user document: $e');
    }
  }

  // Update last login
  Future<void> _updateLastLogin(String uid) async {
    try {
      // Check if user document exists first
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        await _firestore.collection('users').doc(uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      } else {
        // Create a basic user document if it doesn't exist
        final user = _auth.currentUser;
        if (user != null) {
          await _createUserDocument(
            uid,
            user.email ?? '',
            user.displayName ?? 'Unknown User',
            'student', // Default role
          );
        }
      }
    } catch (e) {
      // Don't throw error for this, just log
      debugPrint('Failed to update last login: $e');
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        try {
          return UserModel.fromMap(doc.data()!, doc.id);
        } catch (e) {
          debugPrint('Error creating UserModel from Firestore data: $e');
          return null;
        }
      } else {
        // Create a basic user document if it doesn't exist
        final user = _auth.currentUser;
        if (user != null) {
          try {
            await _createUserDocument(
              uid,
              user.email ?? '',
              user.displayName ?? 'Unknown User',
              'student', // Default role
            );
            // Return the newly created user data
            final newDoc = await _firestore.collection('users').doc(uid).get();
            if (newDoc.exists) {
              try {
                return UserModel.fromMap(newDoc.data()!, newDoc.id);
              } catch (e) {
                debugPrint('Error creating UserModel from newly created data: $e');
                return null;
              }
            }
          } catch (e) {
            debugPrint('Error creating user document: $e');
            return null;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get user data: $e');
      return null; // Return null instead of throwing
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

  // Handle authentication errors
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return 'Authentication failed: ${error.message}';
      }
    }
    return 'An unexpected error occurred.';
  }
}
