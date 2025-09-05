import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String userId;
  final String userName;
  final String courseId;
  final String courseName;
  final String title;
  final String content;
  final String type;
  final String category;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? rating;
  final String? adminResponse;
  final Map<String, dynamic> metadata;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.courseId,
    required this.courseName,
    required this.title,
    required this.content,
    required this.type,
    this.category = 'General',
    this.status = 'pending',
    required this.createdAt,
    this.updatedAt,
    this.rating,
    this.adminResponse,
    this.metadata = const {},
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map, String id) {
    return FeedbackModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      type: map['type'] ?? 'general',
      category: map['category'] ?? 'General',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      rating: map['rating'] != null ? (map['rating'] as num).toInt() : null,
      adminResponse: map['adminResponse'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'courseId': courseId,
      'courseName': courseName,
      'title': title,
      'content': content,
      'type': type,
      'category': category,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'rating': rating,
      'adminResponse': adminResponse,
      'metadata': metadata,
    };
  }

  // Getter for timestamp compatibility
  DateTime get timestamp => createdAt;

  FeedbackModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? courseId,
    String? courseName,
    String? title,
    String? content,
    String? type,
    String? category,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? rating,
    String? adminResponse,
    Map<String, dynamic>? metadata,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      adminResponse: adminResponse ?? this.adminResponse,
      metadata: metadata ?? this.metadata,
    );
  }
}
