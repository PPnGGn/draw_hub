import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draw_hub/features/auth/ui/providers/auth_providers.dart';
import 'package:draw_hub/features/drawing/models/drawing_model.dart';
import 'package:draw_hub/core/services/firebase_storage_service.dart';
import 'package:draw_hub/core/services/image_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Провайдер для Firestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Провайдер для Image Service
final imageServiceProvider = Provider<ImageService>((ref) {
  return ImageService();
});

// Провайдер для Firebase Storage Service
final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});

// StreamProvider для списка рисунков текущего пользователя
final userDrawingsProvider = StreamProvider<List<DrawingModel>>((ref) {
  try {
    final authAsync = ref.watch(authUserProvider);

    return authAsync.when(
      data: (user) {
        if (user == null) {
          return Stream.value([]);
        }
        final firestore = ref.watch(firestoreProvider);

        return firestore
            .collection('drawings')
            .where('authorId', isEqualTo: user.id)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snapshot) {
              return snapshot.docs
                  .map((doc) => DrawingModel.fromFirestore(doc))
                  .toList();
            })
            .handleError((error) {
              throw error;
            });
      },
      loading: () {
        return Stream.value([]);
      },
      error: (error, stack) {
        return Stream.value([]);
      },
    );
  } catch (e) {
    return Stream.value([]);
  }
});

// // Провайдер для Firebase Storage Service
// final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
//   return FirebaseStorageService();
// });
