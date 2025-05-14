import 'package:flutter/material.dart';
import 'package:nckh/services/RockImageDialog.dart';
import 'package:nckh/services/upload_service.dart';

import 'package:nckh/services/user_service.dart';
import 'package:nckh/views/home/edit_profile_screen.dart';
import 'package:nckh/widgets/Result/RockImageDialog_result.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late Future<Map<String, dynamic>?> _userInfoFuture;

  @override
  void initState() {
    super.initState();
    _userInfoFuture = UserService().getCurrentUserInfo();
  }

  Future<void> _uploadAvatar(BuildContext context) async {
    final downloadUrl = await UploadService.uploadAvatar();

    if (downloadUrl != null) {
      setState(() {
        _userInfoFuture = UserService().getCurrentUserInfo();
      });

      showCustomSnackbar(
        context: context,
        message: 'Tải ảnh lên thành công!',
        icon: Icons.cloud_done_rounded,
        backgroundColor: Colors.green.shade600,
      );
    } else {
      showCustomSnackbar(
        context: context,
        message: 'Lỗi khi tải ảnh lên!',
        icon: Icons.error_outline,
        backgroundColor: Colors.red.shade600,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Nút đóng
          Align(
            alignment: Alignment.topRight,
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade600,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            'Tài Khoản',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Hiển thị Avatar từ Firestore
          FutureBuilder<Map<String, dynamic>?>(
            future: _userInfoFuture,
            builder: (context, snapshot) {
              final avatarUrl = snapshot.data?['avatar'];

              return Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? const Icon(Icons.person,
                            size: 36, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _uploadAvatar(context),
                    child: Text(
                      'Tải ảnh lên',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Nút chỉnh sửa thông tin cá nhân
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4D35E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade800,
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              title: const Text(
                'Sửa thông tin cá nhân',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Nút xóa tài khoản (placeholder)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showComingSoonDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Xóa tài khoản',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
