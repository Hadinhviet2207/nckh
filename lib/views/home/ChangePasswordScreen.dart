import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stonelens/views/home/RockImageDialog_result.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool oldObscure = true;
  bool newObscure = true;
  bool confirmObscure = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void _changePassword() async {
    String oldPassword = _oldPassController.text.trim();
    String newPassword = _newPassController.text.trim();
    String confirmPassword = _confirmPassController.text.trim();

    if (newPassword != confirmPassword) {
      showCustomSnackbar(
        context: context,
        message: "Mật khẩu mới không khớp.",
        icon: Icons.error,
        backgroundColor: Colors.red,
      );
      return;
    }

    if (newPassword.length < 6) {
      showCustomSnackbar(
        context: context,
        message: "Mật khẩu mới phải từ 6 ký tự trở lên.",
        icon: Icons.error,
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      final user = _auth.currentUser;
      final email = user?.email;
      if (user != null && email != null) {
        // Re-authenticate
        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: oldPassword);

        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(newPassword);

        // Optional: cập nhật mật khẩu mới (đã mã hóa) lên Firestore
        String hashed = sha256.convert(utf8.encode(newPassword)).toString();
        await _firestore.collection('users').doc(user.uid).update({
          'password': hashed,
        });

        showCustomSnackbar(
          context: context,
          message: "Đổi mật khẩu thành công.",
          icon: Icons.check_circle,
          backgroundColor: Colors.green,
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      // In ra thông tin lỗi chi tiết từ FirebaseAuthException
      print("Firebase Error Code: ${e.code}"); // Lỗi Firebase
      print("Error Message: ${e.message}"); // Thông báo lỗi từ Firebase

      if (e.code == 'wrong-password') {
        showCustomSnackbar(
          context: context,
          message: "Mật khẩu cũ không đúng.",
          icon: Icons.error,
          backgroundColor: Colors.red,
        );
      } else if (e.code == 'invalid-credential') {
        showCustomSnackbar(
          context: context,
          message: "Thông tin xác thực không hợp lệ.",
          icon: Icons.error,
          backgroundColor: Colors.red,
        );
      } else {
        showCustomSnackbar(
          context: context,
          message: "Lỗi: ${e.message}",
          icon: Icons.error,
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print("Unexpected Error: $e"); // Lỗi không xác định
      showCustomSnackbar(
        context: context,
        message: "Lỗi không xác định: $e",
        icon: Icons.error,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Thay đổi mật khẩu',
          style: TextStyle(
              fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Huỷ',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PhysicalModel(
              color: Colors.white,
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              shadowColor: Colors.black.withOpacity(0.2),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildPasswordField(
                      'Mật khẩu cũ',
                      oldObscure,
                      _oldPassController,
                      (value) => setState(() => oldObscure = !oldObscure),
                    ),
                    const SizedBox(height: 12),
                    _buildPasswordField(
                      'Mật khẩu mới',
                      newObscure,
                      _newPassController,
                      (value) => setState(() => newObscure = !newObscure),
                    ),
                    const SizedBox(height: 12),
                    _buildPasswordField(
                      'Nhập lại mật khẩu',
                      confirmObscure,
                      _confirmPassController,
                      (value) =>
                          setState(() => confirmObscure = !confirmObscure),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    bool isObscure,
    TextEditingController controller,
    void Function(bool) onToggle,
  ) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade200,
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => onToggle(isObscure),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
