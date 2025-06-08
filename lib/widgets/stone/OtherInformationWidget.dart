import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stonelens/models/rock_model.dart';

class OtherInformationWidget extends StatelessWidget {
  final RockModel? rock;
  final String? stoneData; // Giờ là JSON string nếu fromAI = true
  final bool fromAI;

  const OtherInformationWidget({
    this.rock,
    this.stoneData,
    required this.fromAI,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> parsedData = {};

    if (fromAI && stoneData != null) {
      try {
        parsedData = jsonDecode(stoneData!);
      } catch (e) {
        debugPrint('❌ Lỗi khi giải mã JSON trong OtherInformation: $e');
      }
    }

    // Hàm lấy dữ liệu theo key
    String getData(String key) {
      if (fromAI) {
        return parsedData[key]?.toString() ?? 'Chưa có dữ liệu';
      } else {
        switch (key) {
          case 'thanhPhanKhoangSan':
            return rock?.thanhPhanKhoangSan ?? 'Chưa có dữ liệu';
          case 'congDung':
            return rock?.congDung ?? 'Chưa có dữ liệu';
          case 'noiPhanBo':
            return rock?.noiPhanBo ?? 'Chưa có dữ liệu';
          case 'motSoKhoangSanLienQuan':
            return rock?.motSoKhoangSanLienQuan ?? 'Chưa có dữ liệu';
          default:
            return 'Chưa có dữ liệu';
        }
      }
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
            // Tiêu đề
            Row(
              children: [
                Image.asset(
                  'assets/icon_ttk.png',
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Một số thông tin khác',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF303A53),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Các thông tin
            _buildItem(
              title: '• Thành phần khoáng sản:',
              value: getData('thanhPhanKhoangSan'),
            ),
            const SizedBox(height: 12),
            _buildItem(
              title: '• Công dụng của khoáng sản:',
              value: getData('congDung'),
            ),
            const SizedBox(height: 12),
            _buildItem(
              title: '• Nơi phân bố:',
              value: getData('noiPhanBo'),
            ),
            const SizedBox(height: 12),
            _buildItem(
              title: '• Một số khoáng sản liên quan:',
              value: getData('motSoKhoangSanLienQuan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                color: Color(0xFF303A53),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
