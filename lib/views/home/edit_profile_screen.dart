import 'package:flutter/material.dart';
import 'package:stonelens/views/home/ChangePasswordScreen.dart';
import 'package:stonelens/services/user_service.dart';
import 'package:stonelens/views/home/RockImageDialog_result.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isEditingName = false;
  bool _isEditingAddress = false;

  late UserService _userService;
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await _userService.getCurrentUserInfo();
    if (userInfo != null) {
      setState(() {
        _userInfo = userInfo;
        _nameController.text = userInfo['fullname'] ?? 'Chưa cập nhật';
        _addressController.text = userInfo['address'] ?? 'Chưa cập nhật';
        _emailController.text = userInfo['email'] ?? 'Chưa có thông tin';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    await _userService.updateUserData({
      'fullname': _nameController.text,
      'address': _addressController.text,
    });
    showCustomSnackbar(
      context: context,
      message: 'Cập nhật thành công!',
      icon: Icons.check_circle_outline,
      backgroundColor: Colors.green.shade600,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Sửa thông tin cá nhân',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text(
              'Lưu',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhysicalModel(
              color: Colors.white,
              elevation: 4,
              borderRadius: BorderRadius.circular(15),
              shadowColor: Colors.black.withOpacity(0.2),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow(
                      'Ảnh đại diện',
                      CircleAvatar(
                        radius: 26,
                        backgroundImage:
                            _userInfo != null && _userInfo!['avatar'] != null
                                ? NetworkImage(_userInfo!['avatar'])
                                : null,
                        child: _userInfo == null || _userInfo!['avatar'] == null
                            ? const Icon(Icons.person, size: 26)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildEditableRow(
                      'Họ và tên',
                      _nameController,
                      _isEditingName,
                      () {
                        setState(() {
                          _isEditingName = !_isEditingName;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildEditableRow(
                      'Địa chỉ',
                      _addressController,
                      _isEditingAddress,
                      () {
                        setState(() {
                          _isEditingAddress = !_isEditingAddress;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            PhysicalModel(
              color: Colors.white,
              elevation: 4,
              borderRadius: BorderRadius.circular(15),
              shadowColor: Colors.black.withOpacity(0.2),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEditableRow(
                      'Địa chỉ Email',
                      _emailController,
                      false,
                      null,
                      enabled: false,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mật khẩu',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const ChangePasswordScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin =
                                      Offset(1.0, 0.0); // Bắt đầu từ trái
                                  const end =
                                      Offset.zero; // Kết thúc ở giữa màn hình
                                  const curve = Curves.easeInOut;

                                  final tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  final offsetAnimation =
                                      animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Thay đổi mật khẩu'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        value,
      ],
    );
  }

  Widget _buildEditableRow(String label, TextEditingController controller,
      bool isEditing, VoidCallback? onTap,
      {bool enabled = true}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isEditing && enabled
                  ? TextField(
                      key: ValueKey('field_$label'),
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onSubmitted: (_) {
                        if (onTap != null) onTap();
                      },
                    )
                  : Padding(
                      key: ValueKey('text_${controller.text}'),
                      padding: const EdgeInsets.only(left: 70),
                      child: Text(
                        controller.text,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                        softWrap: true,
                        maxLines: null,
                        textAlign: TextAlign.right,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
