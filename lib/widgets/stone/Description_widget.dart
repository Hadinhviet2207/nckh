import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stonelens/models/rock_model.dart';

class Description extends StatelessWidget {
  final RockModel? rock;
  final String? stoneData;
  final bool fromAI;

  const Description({
    Key? key,
    this.rock,
    this.stoneData,
    required this.fromAI,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse JSON nếu đến từ AI
    Map<String, dynamic> data = {};
    if (fromAI && stoneData != null) {
      try {
        data = jsonDecode(stoneData!);
      } catch (e) {
        debugPrint('Lỗi giải mã JSON mô tả: $e');
      }
    }

    // Lấy mô tả từ nguồn phù hợp
    final String moTa = fromAI
        ? (data['mieuTa'] ?? 'Không có mô tả.')
        : (rock?.mieuTa ?? 'Không có mô tả.');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Row(
              children: [
                Image.asset(
                  'assets/icon_des1.png',
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Mô tả',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF303A53),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nội dung mô tả
            Text(
              moTa,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.75),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
