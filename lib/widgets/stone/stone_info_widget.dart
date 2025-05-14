import 'package:flutter/material.dart';
import 'package:nckh/services/RockImageDialog.dart';
import 'package:nckh/models/rock_model.dart'; // Import RockModel

class StoneInfoWidget extends StatelessWidget {
  final RockModel rock; // Thêm tham số rock
  final bool isFavorite;
  final Function onFavoriteToggle;

  StoneInfoWidget({
    required this.rock,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16), // Đặt padding cho tất cả các cạnh
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 8,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          color: Color(0xFF303A53),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Đảm bảo các widget con căn chỉnh đều
          children: [
            // Column for image display
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageRow(context, rock.hinhAnh[1], rock.hinhAnh[2]),
                SizedBox(height: 12), // Tạo khoảng cách giữa các hàng ảnh
                _buildImageRow(context, rock.hinhAnh[3], rock.hinhAnh[4]),
              ],
            ),
            SizedBox(width: 16), // Điều chỉnh khoảng cách giữa ảnh và thông tin

            // Information Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoText('Công thức hóa học', rock.thanhPhanHoaHoc),
                  SizedBox(height: 18), // Tạo khoảng cách giữa các thông tin
                  _buildInfoText('Độ cứng', rock.doCung.toString()),
                  SizedBox(height: 18),
                  _buildInfoText('Màu sắc', rock.mauSac),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => RockImageDialog(imagePath: imagePath),
    );
  }

  // Widget to display row of two images
  Widget _buildImageRow(BuildContext context, String image1, String image2) {
    return Row(
      children: [
        _buildImage(context, image1),
        SizedBox(width: 8),
        _buildImage(context, image2),
      ],
    );
  }

  // Widget to display image and handle tap event
  Widget _buildImage(BuildContext context, String imagePath) {
    return GestureDetector(
      onTap: () {
        _showImageDialog(context, imagePath);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          // Sử dụng Image.network nếu bạn có URL
          imagePath,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFFE57C3B),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
