import 'package:cloud_firestore/cloud_firestore.dart';

enum ComplaintStatus {
  pending,
  seen,
  assigned,
  inProgress,
  completed,
  rejected,
}

enum ComplaintPriority { low, medium, high, emergency }

class ComplaintModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String area;
  final String? landmark;
  final ComplaintPriority priority;
  final String? imageUrl;
  final String? videoUrl;
  final double? latitude;
  final double? longitude;
  final bool isAnonymous;
  final DateTime createdAt;
  final ComplaintStatus status;
  final String? assignedOfficerId;
  final String? assignedOfficerName;
  final DateTime? expectedCompletionDate;
  final String? adminRemarks;
  final String? officerNotes;
  final String? resolutionImageUrl;
  final double? userRating;
  final String? userFeedback;

  ComplaintModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.area,
    this.landmark,
    required this.priority,
    this.imageUrl,
    this.videoUrl,
    this.latitude,
    this.longitude,
    required this.isAnonymous,
    required this.createdAt,
    required this.status,
    this.assignedOfficerId,
    this.assignedOfficerName,
    this.expectedCompletionDate,
    this.adminRemarks,
    this.officerNotes,
    this.resolutionImageUrl,
    this.userRating,
    this.userFeedback,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category,
      'area': area,
      'landmark': landmark,
      'priority': priority.name,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'isAnonymous': isAnonymous,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
      'assignedOfficerId': assignedOfficerId,
      'assignedOfficerName': assignedOfficerName,
      'expectedCompletionDate': expectedCompletionDate != null
          ? Timestamp.fromDate(expectedCompletionDate!)
          : null,
      'adminRemarks': adminRemarks,
      'officerNotes': officerNotes,
      'resolutionImageUrl': resolutionImageUrl,
      'userRating': userRating,
      'userFeedback': userFeedback,
    };
  }

  factory ComplaintModel.fromMap(Map<String, dynamic> map, String id) {
    return ComplaintModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      area: map['area'] ?? '',
      landmark: map['landmark'],
      priority: ComplaintPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => ComplaintPriority.low,
      ),
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      isAnonymous: map['isAnonymous'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: ComplaintStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ComplaintStatus.pending,
      ),
      assignedOfficerId: map['assignedOfficerId'],
      assignedOfficerName: map['assignedOfficerName'],
      expectedCompletionDate: map['expectedCompletionDate'] != null
          ? (map['expectedCompletionDate'] as Timestamp).toDate()
          : null,
      adminRemarks: map['adminRemarks'],
      officerNotes: map['officerNotes'],
      resolutionImageUrl: map['resolutionImageUrl'],
      userRating: map['userRating']?.toDouble(),
      userFeedback: map['userFeedback'],
    );
  }
}
