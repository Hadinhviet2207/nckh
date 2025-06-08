import 'dart:convert'; // cần để parse JSON
import 'package:flutter/material.dart';
import 'package:stonelens/services/RockImageDialog.dart';
import 'package:stonelens/models/rock_model.dart';

class StoneInfoWidget extends StatelessWidget {
  final RockModel? rock;
  final String? stoneData; // JSON string nếu fromAI = true
  final bool fromAI;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  StoneInfoWidget({
    this.rock,
    this.stoneData,
    required this.fromAI,
    required this.isFavorite,
    required this.onFavoriteToggle,
    Key? key,
  })  : assert(rock != null || stoneData != null,
            'Phải truyền ít nhất rock hoặc stoneData'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    // Nếu từ AI thì parse JSON string thành Map
    final Map<String, dynamic> data = fromAI
        ? (stoneData != null ? json.decode(stoneData!) : {})
        : (rock != null
            ? {
                'thanhPhanHoaHoc': rock!.thanhPhanHoaHoc,
                'doCung': rock!.doCung,
                'mauSac': rock!.mauSac,
                'hinhAnh': rock!.hinhAnh,
              }
            : {});

    final hinhAnh = (data['hinhAnh'] as List<dynamic>?)?.cast<String>() ?? [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 8, bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF303A53),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cột ảnh
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hinhAnh.length > 2)
                  _buildImageRow(context, hinhAnh[1], hinhAnh[2]),
                const SizedBox(height: 12),
                if (hinhAnh.length > 4)
                  _buildImageRow(context, hinhAnh[3], hinhAnh[4]),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoText('Công thức hóa học',
                      data['thanhPhanHoaHoc']?.toString() ?? '-'),
                  const SizedBox(height: 18),
                  _buildInfoText('Độ cứng', data['doCung']?.toString() ?? '-'),
                  const SizedBox(height: 18),
                  _buildInfoText('Màu sắc', data['mauSac']?.toString() ?? '-'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => RockImageDialog(imagePath: imagePath),
    );
  }

  Widget _buildImageRow(BuildContext context, String image1, String image2) {
    return Row(
      children: [
        _buildImage(context, image1),
        const SizedBox(width: 8),
        _buildImage(context, image2),
      ],
    );
  }

  Widget _buildImage(BuildContext context, String imagePath) {
    return GestureDetector(
      onTap: () => _showImageDialog(context, imagePath),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imagePath,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 80,
            height: 80,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFE57C3B),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
