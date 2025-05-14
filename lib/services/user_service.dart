import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy thông tin người dùng hiện tại (dữ liệu 1 lần)
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }

  /// Lấy dữ liệu người dùng realtime (theo dõi mọi thay đổi)
  Stream<Map<String, dynamic>?> getCurrentUserStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore.collection('users').doc(user.uid).snapshots().map(
          (doc) => doc.data(),
        );
  }

  /// Trả về email người dùng hiện tại
  String? getUserEmail() => _auth.currentUser?.email;

  /// Trả về UID người dùng hiện tại
  String? getUserId() => _auth.currentUser?.uid;

  /// Cập nhật thông tin người dùng
  Future<void> updateUserData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update(data);
    }
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mã hóa mật khẩu bằng SHA256
  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Đăng ký người dùng bằng email và mật khẩu
  Future<UserModel?> registerWithEmail(String email, String password) async {
    try {
      // Đăng ký người dùng với Firebase Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // Mã hóa mật khẩu trước khi lưu
        String hashedPassword = hashPassword(password);

        // Tạo đối tượng UserModel
        UserModel userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          password: hashedPassword,
          role: 'user',
          createdAt: DateTime.now(),
        );

        // Lưu thông tin người dùng vào Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());

        return userModel;
      }
    } on FirebaseAuthException catch (_) {
      rethrow;
    } on FirebaseException catch (_) {
      rethrow;
    } catch (e) {
      rethrow;
    }
    return null;
  }
}
