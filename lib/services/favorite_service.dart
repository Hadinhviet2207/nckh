import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream kiểm tra một rock có đang được yêu thích hay không
  Stream<bool> rockFavoriteStatusStream(String rockId) {
    final user = _auth.currentUser;
    if (user == null || rockId.isEmpty) {
      return Stream.value(false);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(rockId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Toggle trạng thái yêu thích (thêm/xóa) một rock
  Future<void> toggleFavorite(String rockId, bool isFavorite) async {
    final user = _auth.currentUser;
    if (user == null || rockId.isEmpty) return;

    final ref = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(rockId);

    if (isFavorite) {
      final now = DateTime.now().toUtc().add(const Duration(hours: 7));
      final formattedTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} - "
          "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

      await ref.set({
        'rock_id': rockId,
        'favoritedAt': FieldValue.serverTimestamp(),
        'time': formattedTime,
      });
    } else {
      await ref.delete();
    }
  }

  /// Realtime: Stream danh sách tất cả các rockId đã yêu thích
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
