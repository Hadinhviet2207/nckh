import 'package:flutter/material.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

// CustomClipper tạo đường cong nhẹ ở dưới ảnh
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - 10,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _CollectionScreenState extends State<CollectionScreen> {
  int _selectedIndex = 0;

  Widget buildCurvedImageWithPattern() {
    return ClipPath(
      clipper: BottomCurveClipper(),
      child: Stack(
        children: [
          Image.asset(
            'assets/baiviet2.jpg',
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),

          // 🔧 Icon chỉnh sửa góc trên phải
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () {
                // TODO: Xử lý khi nhấn nút chỉnh sửa
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bạn đã nhấn nút chỉnh sửa')),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  'assets/edit.png',
                  width: 20,
                  height: 20,
                  color: Colors
                      .white, // giữ màu trắng nếu ảnh là icon dạng đơn sắc
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 10,
            right: 155,
            child: Container(
              width: 36, // hoặc tùy kích thước bạn muốn
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF2F3546),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '1/2',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = 0;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _selectedIndex == 0
                                      ? const Color(0xFFE87D34)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Nhãn',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: _selectedIndex == 0
                                    ? const Color(0xFFE87D34)
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = 1;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _selectedIndex == 1
                                      ? const Color(0xFFE87D34)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Thông tin',
                              style: TextStyle(
                                fontWeight: _selectedIndex == 1
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 20,
                                color: _selectedIndex == 1
                                    ? const Color(0xFFE87D34)
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          buildCurvedImageWithPattern(),
                          const SizedBox(height: 20),
                          const Text(
                            'Bộ sưu tập của tôi',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'No.4',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                          const SizedBox(height: 20),
                          Image.asset(
                            'assets/rock.png',
                            width: 130,
                            height: 130,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Chỉnh sửa bộ sưu tập của mình',
                            style: TextStyle(
                                color: Color(0xFFE87D34), fontSize: 16),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.download,
                                size: 18, color: Colors.white),
                            label: const Text(
                              'Tải xuống',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE87D34),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.share,
                                size: 18, color: Colors.white),
                            label: const Text(
                              'Chia sẻ',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE87D34),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
