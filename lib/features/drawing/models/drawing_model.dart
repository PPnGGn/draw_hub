import 'package:cloud_firestore/cloud_firestore.dart';

class DrawingModel {
  final String id;
  final String title;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final String imageUrl; // URL в Firebase Storage или base64
  final String? thumbnailUrl; // Превью для быстрой загрузки

  DrawingModel({
    required this.id,
    required this.title,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.imageUrl,
    this.thumbnailUrl,
  });

  factory DrawingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DrawingModel(
      id: doc.id,
      title: data['title'] ?? 'Без названия',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Нет имени',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}
