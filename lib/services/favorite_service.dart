import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Realtime: Kiểm tra đá có đang được yêu thích không
  Stream<bool> rockFavoriteStatusStream(String rockId) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(false); // Trả về false nếu chưa đăng nhập
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(rockId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Bật/tắt yêu thích
  Future<void> toggleFavorite(String rockId, bool isFavorite) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(rockId);

    if (isFavorite) {
      await ref.set({
        'rockId': rockId,
        'favoritedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.delete();
    }
  }

  /// Realtime: Stream danh sách tất cả rockId đã yêu thích
  Stream<List<String>> favoriteRockIdsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
