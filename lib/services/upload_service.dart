// lib/services/upload_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadService {
  /// Upload ảnh avatar và lưu URL vào Firestore
  static Future<String?> uploadAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return null;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final file = File(pickedFile.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('avatars/${user.uid}_$timestamp.jpg');

    try {
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();

      // Cập nhật URL avatar trong Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'avatar': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      print('Lỗi upload avatar: $e');
      return null;
    }
  }
}
