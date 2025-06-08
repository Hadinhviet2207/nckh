import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  final String title;
  final String imagePath;

  const PostScreen({super.key, required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 4,
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5A55CA), // Màu tím sapphire
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('04/05/2025', style: TextStyle(color: Colors.grey)),
                SizedBox(width: 16),
                Icon(Icons.person, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('Admin', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Đá được hình thành qua ba quá trình chính của tự nhiên: đá magma hình thành khi dung nham nguội đi và kết tinh, đá trầm tích hình thành từ sự tích tụ và nén ép các mảnh vụn tự nhiên như cát, bùn, vỏ sinh vật, còn đá biến chất là kết quả của sự biến đổi đá gốc dưới tác động của nhiệt độ và áp suất cao. Mỗi loại đá mang trong mình một hành trình riêng – từ lửa cháy sâu trong lòng đất, đến những dòng sông mang phù sa, cho đến sự tái sinh mạnh mẽ dưới áp lực thời gian. Đá không chỉ là vật chất, mà là ký ức hóa thạch của Trái Đất qua hàng triệu năm chuyển mình.',
              style: TextStyle(fontSize: 16, height: 1.6),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 500), // để test việc scroll
          ],
        ),
      ),
    );
  }
}
