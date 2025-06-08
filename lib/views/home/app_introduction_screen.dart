import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppIntroductionScreen extends StatelessWidget {
  const AppIntroductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Giới Thiệu Ứng Dụng',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildIntroCard(),
            const SizedBox(height: 24),
            _buildSection(
              icon: Icons.apps_rounded,
              title: 'Mô tả Ứng dụng',
              children: [
                _buildPoint(
                    "🔍 Tìm kiếm đá theo tên từ 29 loại đá trong sách 'Thạch Học'."),
                _buildPoint(
                    "📷 Chụp ảnh đá để AI nhận dạng tự động (hỗ trợ 5 loại)."),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              icon: Icons.auto_awesome_mosaic,
              title: 'Các loại đá được hỗ trợ AI',
              children: _buildStoneList(),
            ),
            const SizedBox(height: 20),
            _buildSection(
              icon: Icons.stars_rounded,
              title: 'Tính năng mở rộng',
              children: [
                _buildPoint("📖 Đọc bài viết chuyên sâu về đá."),
                _buildPoint(
                    "❤️ Yêu thích & lưu trữ đá vào bộ sưu tập cá nhân."),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              icon: Icons.person_2_outlined,
              title: 'Quản lý người dùng',
              children: [
                _buildPoint("🖼️ Cập nhật ảnh đại diện."),
                _buildPoint("✏️ Chỉnh sửa thông tin cá nhân."),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  '🚀 Bắt đầu khám phá',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      '🪨 Ứng Dụng Nhận Dạng Đá',
      style: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        '📚 Sản phẩm nghiên cứu khoa học sinh viên Trường Đại học Mỏ Địa Chất (2025–2026).\n\n'
        '👨‍🏫 Hướng dẫn: PGS.TS Lê Hồng Anh\n'
        '👥 Thành viên: Hà Đình Việt, Mai Văn Thuyên, Trần Ngọc Anh, Nguyễn Hải Nam, Nguyễn Xuân Đức.',
        style: GoogleFonts.inter(
            fontSize: 15.2, height: 1.6, color: Colors.black87),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.black87),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(" ",
              style: TextStyle(fontSize: 20, color: Colors.black87)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15.5,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStoneList() {
    const stones = ["Basalt", "Coal", "Granite", "Marble", "Sandstone"];
    return stones.map((stone) => _buildPoint("🔹 $stone")).toList();
  }
}
