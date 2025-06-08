import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stonelens/models/rock_model.dart';

class FrequentlyAskedQuestions extends StatefulWidget {
  final RockModel? rock;
  final String? stoneData;
  final bool fromAI;

  const FrequentlyAskedQuestions({
    Key? key,
    this.rock,
    this.stoneData,
    required this.fromAI,
  }) : super(key: key);

  @override
  _FrequentlyAskedQuestionsState createState() =>
      _FrequentlyAskedQuestionsState();
}

class _FrequentlyAskedQuestionsState extends State<FrequentlyAskedQuestions> {
  late List<bool> _isExpandedList;
  List<dynamic> _questions = [];
  List<dynamic> _answers = [];

  @override
  void initState() {
    super.initState();

    Map<String, dynamic> data = {};
    if (widget.fromAI && widget.stoneData != null) {
      try {
        data = jsonDecode(widget.stoneData!);
      } catch (e) {
        debugPrint('Lỗi giải mã JSON FAQ: $e');
      }
    }

    _questions =
        widget.fromAI ? (data['cauHoi'] ?? []) : (widget.rock?.cauHoi ?? []);

    _answers =
        widget.fromAI ? (data['traLoi'] ?? []) : (widget.rock?.traLoi ?? []);

    _isExpandedList = List.generate(_questions.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
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
            // Tiêu đề
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

            // Hiển thị danh sách hoặc thông báo
            if (_questions.isEmpty)
              Text(
                "Chưa có câu hỏi nào.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
            else
              ...List.generate(_questions.length, (i) {
                final question = _questions[i].toString();
                final answer = i < _answers.length
                    ? _answers[i].toString()
                    : "Chưa có câu trả lời.";
                return _buildQuestionAnswer(question, answer, i);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionAnswer(String question, String answer, int index) {
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
      onExpansionChanged: (expanded) {
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
