import 'package:flutter/material.dart';
import 'package:nckh/models/rock_model.dart'; // Import RockModel

class StructureAndComposition extends StatelessWidget {
  final RockModel rock; // Sử dụng RockModel để lấy dữ liệu đá

  StructureAndComposition({required this.rock});

  // Hàm xây dựng phần tiêu đề và nội dung
  Widget _buildInfoRow(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.circle, // Biểu tượng chấm tròn
                size: 8,
                color: color, // Màu sắc của chấm tròn
              ),
              SizedBox(width: 8), // Khoảng cách giữa icon và tiêu đề
              Text(
                title, // Tiêu đề thông tin
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.orange),
              ),
            ],
          ),
          Text(
            description, // Mô tả thông tin
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16), // Padding ngoài cùng cho container
      child: Container(
        padding: EdgeInsets.all(16), // Padding bên trong container
        decoration: BoxDecoration(
          color: Colors.white, // Màu nền của container
          borderRadius:
              BorderRadius.circular(14), // Bo tròn các góc của container
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Tạo bóng mờ cho container
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề chính "Kết cấu và Cấu tạo"
            Row(
              children: [
                // Thêm icon tùy chỉnh
                Image.asset(
                  'assets/connection.png', // Đường dẫn đến tệp icon của bạn
                  width: 30,
                  height: 30,
                ),
                SizedBox(width: 8), // Khoảng cách giữa icon và tiêu đề
                Text(
                  "Kết cấu và Cấu tạo", // Tiêu đề chính
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF303A53), // Màu tiêu đề
                  ),
                ),
              ],
            ),
            SizedBox(height: 16), // Khoảng cách giữa tiêu đề và các thông tin

            // Các thông tin về kết cấu và cấu tạo từ RockModel
            _buildInfoRow('Về Kiến trúc', rock.kienTruc, Colors.orange),
            _buildInfoRow('Về Cấu tạo', rock.cauTao, Colors.orange),
          ],
        ),
      ),
    );
  }
}
