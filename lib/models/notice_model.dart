import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;
  final DateTime? expiryDate;
  final String? imageUrl;
  final bool isEmergency;

  NoticeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    this.expiryDate,
    this.imageUrl,
    this.isEmergency = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'imageUrl': imageUrl,
      'isEmergency': isEmergency,
    };
  }

  factory NoticeModel.fromMap(Map<String, dynamic> map, String id) {
    return NoticeModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      expiryDate: map['expiryDate'] != null
          ? (map['expiryDate'] as Timestamp).toDate()
          : null,
      imageUrl: map['imageUrl'],
      isEmergency: map['isEmergency'] ?? false,
    );
  }
}
