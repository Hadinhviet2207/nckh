import 'package:flutter/material.dart';
import 'package:nckh/models/rock_model.dart'; // Import RockModel

class Description extends StatelessWidget {
  final RockModel rock; // Thêm tham số rock để sử dụng dữ liệu từ RockModel

  Description({
    required this.rock,
  });

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
            // Tiêu đề mô tả
            Row(
              children: [
                Image.asset(
                  'assets/icon_des1.png', // Đường dẫn tới file ảnh icon của bạn
                  width: 30,
                  height: 30,
                ),
                SizedBox(width: 8),
                Text(
                  'Mô tả', // Tiêu đề phần mô tả
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF303A53), // Màu tiêu đề
                  ),
                ),
              ],
            ),
            SizedBox(height: 12), // Khoảng cách giữa tiêu đề và mô tả

            // Nội dung mô tả
            Text(
              rock.mieuTa, // Mô tả từ đối tượng rock
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
