import 'package:flutter/material.dart';
import 'package:nckh/models/rock_model.dart'; // Import RockModel

class FrequentlyAskedQuestions extends StatefulWidget {
  final RockModel rock; // Sử dụng RockModel để lấy dữ liệu câu hỏi

  FrequentlyAskedQuestions({
    required this.rock,
  });

  @override
  _FrequentlyAskedQuestionsState createState() =>
      _FrequentlyAskedQuestionsState();
}

class _FrequentlyAskedQuestionsState extends State<FrequentlyAskedQuestions> {
  // List lưu trữ trạng thái mở rộng của mỗi câu hỏi
  late List<bool> _isExpandedList;

  @override
  void initState() {
    super.initState();
    // Khởi tạo trạng thái mở rộng của mỗi câu hỏi từ dữ liệu ban đầu
    _isExpandedList =
        List.generate(widget.rock.cauHoi.length, (index) => false);
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
              BorderRadius.circular(12), // Bo tròn các góc của container
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
            Row(
              children: [
                Image.asset(
                  'assets/icon_qes.png',
                  width: 30,
                  height: 30,
                ),
                SizedBox(width: 10), // Khoảng cách giữa icon và tiêu đề
                Text(
                  "Một số câu hỏi phổ biến", // Tiêu đề câu hỏi
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF303A53), // Màu tiêu đề
                  ),
                ),
              ],
            ),
            SizedBox(height: 16), // Khoảng cách giữa tiêu đề và câu hỏi

            // Các câu hỏi phổ biến
            for (int i = 0; i < widget.rock.cauHoi.length; i++)
              _buildQuestionAnswer(
                  widget.rock.cauHoi[i], widget.rock.traLoi[i], i),
          ],
        ),
      ),
    );
  }

  // Mỗi câu hỏi và câu trả lời với ExpansionTile
  Widget _buildQuestionAnswer(String question, String answer, int index) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF303A53), // Màu chữ câu hỏi
        ),
      ),
      // Thay đổi biểu tượng chỉ khi câu hỏi đó mở rộng
      trailing: AnimatedRotation(
        duration: Duration(milliseconds: 200),
        turns: _isExpandedList[index]
            ? 0.5
            : 0.0, // Quay biểu tượng chỉ khi mở rộng
        child: Icon(
          Icons.expand_more, // Biểu tượng cho "mở rộng"
          color: Color(0xFF303A53),
        ),
      ),
      // Lắng nghe sự thay đổi trạng thái mở rộng của ExpansionTile
      onExpansionChanged: (bool expanded) {
        setState(() {
          _isExpandedList[index] =
              expanded; // Cập nhật trạng thái mở rộng cho câu hỏi cụ thể
        });
      },
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100], // Màu nền cho câu trả lời khi mở rộng
              borderRadius:
                  BorderRadius.circular(8), // Bo tròn các góc của câu trả lời
            ),
            child: Text(
              answer, // Sử dụng câu trả lời tương ứng từ RockModel
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}
