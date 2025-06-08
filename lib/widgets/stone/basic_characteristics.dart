import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stonelens/models/rock_model.dart';

class BasicCharacteristics extends StatelessWidget {
  final RockModel? rock;
  final String? stoneData;
  final bool fromAI;

  const BasicCharacteristics({
    Key? key,
    this.rock,
    this.stoneData,
    required this.fromAI,
  }) : super(key: key);

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 140,
                child: Text(
                  '$title:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade300, thickness: 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Parse JSON nếu đến từ AI
    Map<String, dynamic> data = {};
    if (fromAI && stoneData != null) {
      try {
        data = jsonDecode(stoneData!);
      } catch (e) {
        debugPrint('Lỗi parse stoneData: $e');
      }
    }

    // Lấy dữ liệu từ nguồn phù hợp
    final String congThucHoaHoc = fromAI
        ? (data['thanhPhanHoaHoc'] ?? 'Chưa có dữ liệu')
        : (rock?.thanhPhanHoaHoc ?? 'Chưa có dữ liệu');

    final String doCung = fromAI
        ? (data['doCung']?.toString() ?? 'Chưa có dữ liệu')
        : (rock?.doCung?.toString() ?? 'Chưa có dữ liệu');

    final String mauSac = fromAI
        ? (data['mauSac'] ?? 'Chưa có dữ liệu')
        : (rock?.mauSac ?? 'Chưa có dữ liệu');

    final String matDo = fromAI
        ? (data['matDo']?.toString() ?? 'Chưa có dữ liệu')
        : (rock?.matDo?.toString() ?? 'Chưa có dữ liệu');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/icon_basic.png',
                  width: 28,
                  height: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  "Đặc điểm cơ bản",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF303A53),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Công thức hóa học', congThucHoaHoc),
            _buildInfoRow('Độ cứng', doCung),
            _buildInfoRow('Màu sắc', mauSac),
            _buildInfoRow('Mật độ', matDo),
          ],
        ),
      ),
    );
  }
}
