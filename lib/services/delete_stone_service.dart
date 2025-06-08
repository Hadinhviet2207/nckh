import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stonelens/views/home/RockImageDialog_result.dart';

class DeleteStoneService {
  static Future<void> deleteStoneByTab({
    required BuildContext context,
    required Map<String, dynamic> stone,
    required String tabName,
    required VoidCallback onDelete,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Người dùng chưa đăng nhập');

      final uid = user.uid;
      final rockId = stone['id'];
      if (rockId == null) throw Exception('Không có ID để xóa');

      String? subCollection;
      switch (tabName) {
        case 'Bộ Sưu Tập':
          subCollection = 'collections';
          break;
        case 'Yêu Thích':
          subCollection = 'favorites';
          break;
        case 'Lịch Sử':
          subCollection = 'history_rocks';
          break;
        default:
          throw Exception('Tab không hợp lệ');
      }

      // Xóa từ Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection(subCollection)
          .where('rock_id', isEqualTo: rockId)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      onDelete();

      showCustomSnackbar(
        context: context,
        message: 'Xóa thành công!',
        icon: Icons.check_circle,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      showCustomSnackbar(
        context: context,
        message: 'Lỗi khi xóa: $e',
        icon: Icons.error_outline,
        backgroundColor: Colors.red,
      );
    }
  }
}
