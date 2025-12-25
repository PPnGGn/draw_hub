
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draw_hub/core/providers/auth_providers.dart';
import 'package:draw_hub/features/gallery/models/drawing_model.dart';
import 'package:draw_hub/services/image_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для Firestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});
// Провайдер для imagePickeer
final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});



// StreamProvider для списка рисунков текущего пользователя
final userDrawingsProvider = StreamProvider<List<DrawingModel>>((ref) {
  final authUser = ref.watch(authUserProvider).value;

  if (authUser == null) {
    return Stream.value([]);
  }

  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('drawings')
      .where('authorId', isEqualTo: authUser.id)
      .orderBy('createdAt', descending: true) 
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => DrawingModel.fromFirestore(doc))
            .toList();
      });
});



