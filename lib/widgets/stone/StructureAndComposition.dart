import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stonelens/models/rock_model.dart';

class StructureAndComposition extends StatelessWidget {
  final RockModel? rock;
  final String? stoneData; // JSON string nếu fromAI = true
  final bool fromAI;

  StructureAndComposition({
    this.rock,
    this.stoneData,
    required this.fromAI,
    Key? key,
  })  : assert(rock != null || stoneData != null,
            'Phải truyền ít nhất rock hoặc stoneData'),
        super(key: key);

  Widget _buildInfoRow(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: 8, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          Text(
            description.isNotEmpty ? description : '-',
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = {};

    if (fromAI) {
      if (stoneData != null) {
        try {
          data = json.decode(stoneData!) as Map<String, dynamic>;
        } catch (e) {
          // Nếu parse lỗi thì data rỗng
          data = {};
        }
      }
    } else {
      data = {
        'kienTruc': rock?.kienTruc ?? '',
        'cauTao': rock?.cauTao ?? '',
      };
    }

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
            Row(
              children: [
                Image.asset(
                  'assets/connection.png',
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Kết cấu và Cấu tạo",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF303A53),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Về Kiến trúc', data['kienTruc']?.toString() ?? '-',
                Colors.orange),
            _buildInfoRow(
                'Về Cấu tạo', data['cauTao']?.toString() ?? '-', Colors.orange),
          ],
        ),
      ),
    );
  }
}
