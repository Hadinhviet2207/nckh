import 'package:flutter/material.dart';

class FrequentlyAskedQuestions extends StatefulWidget {
  final Map<String, dynamic> stoneData;

  const FrequentlyAskedQuestions({Key? key, required this.stoneData})
      : super(key: key);

  @override
  _FrequentlyAskedQuestionsState createState() =>
      _FrequentlyAskedQuestionsState();
}

class _FrequentlyAskedQuestionsState extends State<FrequentlyAskedQuestions> {
  late List<bool> _isExpandedList;

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách trạng thái mở rộng bằng độ dài số câu hỏi (tối đa 4)
    int length = (widget.stoneData['cauHoi'] as List?)?.length ?? 0;
    _isExpandedList = List.generate(length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> questions = widget.stoneData['cauHoi'] ?? [];
    List<dynamic> answers = widget.stoneData['traLoi'] ?? [];

    return Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                SizedBox(width: 10),
                Text(
                  "Một số câu hỏi phổ biến",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF303A53),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Hiển thị danh sách câu hỏi và trả lời
            for (int i = 0; i < questions.length && i < 4; i++)
              _buildQuestionAnswer(
                question: questions[i] ?? 'Chưa có câu hỏi',
                answer: i < answers.length
                    ? answers[i] ?? 'Chưa có trả lời'
                    : 'Chưa có trả lời',
                index: i,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionAnswer({
    required String question,
    required String answer,
    required int index,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF303A53),
        ),
      ),
      trailing: AnimatedRotation(
        duration: Duration(milliseconds: 200),
        turns: _isExpandedList[index] ? 0.5 : 0.0,
        child: Icon(
          Icons.expand_more,
          color: Color(0xFF303A53),
        ),
      ),
      onExpansionChanged: (bool expanded) {
        setState(() {
          _isExpandedList[index] = expanded;
        });
      },
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              answer,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}
