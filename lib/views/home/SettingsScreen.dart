import 'package:flutter/material.dart';
import 'package:nckh/services/local_auth_service.dart';
import 'package:nckh/views/home/account_screen.dart';
import 'package:nckh/views/intro/intro_home_screen.dart';
import 'package:nckh/widgets/Result/RockImageDialog_result.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 80,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF303A53),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Cài đặt',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Text(
                'Tài khoản',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Thông tin cá nhân - có điều hướng
              SettingsButton(
                icon: Icons.person,
                title: 'Thông tin cá nhân',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // Cho phép điều chỉnh chiều cao
                    backgroundColor: Colors
                        .transparent, // Để có thể sử dụng hiệu ứng đẹp hơn
                    builder: (BuildContext context) {
                      return const AccountScreen();
                    },
                  );
                },
              ),

              // Các nút còn lại
              SettingsButton(
                icon: Icons.dark_mode,
                title: 'Chế độ sáng / tối',
                onTap: () {
                  // TODO: Toggle theme
                },
              ),

              const SizedBox(height: 16),
              const Text(
                'Cài Đặt',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              SettingsButton(
                icon: Icons.book,
                title: 'Chính sách bảo mật',
                onTap: () {
                  // TODO
                },
              ),
              SettingsButton(
                icon: Icons.view_in_ar,
                title: 'Điều khoản sử dụng',
                onTap: () {
                  // TODO
                },
              ),
              SettingsButton(
                icon: Icons.share,
                title: 'Chia sẻ',
                onTap: () {
                  // TODO
                },
              ),
              SettingsButton(
                icon: Icons.favorite,
                title: 'Ủng hộ',
                onTap: () {
                  // TODO
                },
              ),
              SettingsButton(
                icon: Icons.contact_support,
                title: 'Liên hệ',
                onTap: () {
                  // TODO
                },
              ),
              SettingsButton(
                icon: Icons.language,
                title: 'Thay đổi ngôn ngữ',
                onTap: () {
                  // TODO
                },
              ),

              const SizedBox(height: 24),
              const Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showLogoutConfirmationDialog(context, () async {
                      await LocalAuthService.logout();

                      // Quay về màn hình intro ban đầu
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => Intro_HomeScreen()),
                        (route) => false,
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const SettingsButton({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4D35E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade800,
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
