import 'package:flutter/material.dart';
import 'package:stonelens/services/RockImageDialog.dart';
import 'package:stonelens/services/local_auth_service.dart';
import 'package:stonelens/views/home/account_screen.dart';
import 'package:stonelens/views/home/app_introduction_screen.dart';
import 'package:stonelens/views/intro/intro_home_screen.dart';
import 'package:stonelens/views/home/RockImageDialog_result.dart';

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
                          margin: const EdgeInsets.only(
                              right: 20), // Lùi ra từ lề trái
                          width: 70,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF303A53),
                            borderRadius: BorderRadius.circular(12),
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
                    showComingSoonDialog(context);
                  }),

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
                    showComingSoonDialog(context);
                  }),
              SettingsButton(
                  icon: Icons.view_in_ar,
                  title: 'Điều khoản sử dụng',
                  onTap: () {
                    showComingSoonDialog(context);
                  }),
              SettingsButton(
                  icon: Icons.share,
                  title: 'Chia sẻ',
                  onTap: () {
                    showComingSoonDialog(context);
                  }),
              SettingsButton(
                  icon: Icons.favorite,
                  title: 'Ủng hộ',
                  onTap: () {
                    showComingSoonDialog(context);
                  }),
              SettingsButton(
                  icon: Icons.language,
                  title: 'Thay đổi ngôn ngữ',
                  onTap: () {
                    showComingSoonDialog(context);
                  }),
              SettingsButton(
                  icon: Icons.contact_support,
                  title: 'Giới Thiệu',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppIntroductionScreen(),
                      ),
                    );
                  }),

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
