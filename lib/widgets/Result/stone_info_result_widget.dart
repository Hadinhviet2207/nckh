import 'package:flutter/material.dart';
import 'package:nckh/services/RockImageDialog.dart';

class StoneInfoWidget extends StatelessWidget {
  final bool isFavorite;
  final Function onFavoriteToggle;
  final Map<String, dynamic> stoneData;

  const StoneInfoWidget({
    Key? key,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.stoneData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<dynamic> images = stoneData['hinhAnh'] ?? [];

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
            // Image Column
            Column(
              children: [
                _buildImageRow(context, images, 1, 2),
                const SizedBox(height: 12),
                _buildImageRow(context, images, 3, 4),
              ],
            ),

            const SizedBox(width: 16),

            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoText(
                    'Thành phần hóa học',
                    stoneData['thanhPhanHoaHoc'] ?? 'Chưa có thông tin',
                  ),
                  const SizedBox(height: 18),
                  _buildInfoText(
                    'Độ cứng',
                    stoneData['doCung'] ?? 'Chưa có thông tin',
                  ),
                  const SizedBox(height: 18),
                  _buildInfoText(
                    'Màu sắc',
                    stoneData['mauSac'] ?? 'Chưa có thông tin',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageRow(
      BuildContext context, List<dynamic> images, int index1, int index2) {
    return Row(
      children: [
        if (images.length > index1) _buildImage(context, images[index1]),
        const SizedBox(width: 8),
        if (images.length > index2) _buildImage(context, images[index2]),
      ],
    );
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => RockImageDialog(imagePath: imagePath),
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
          errorBuilder: (context, error, stackTrace) =>
              Container(width: 80, height: 80, color: Colors.grey),
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
