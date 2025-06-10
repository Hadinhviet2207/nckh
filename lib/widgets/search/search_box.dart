import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final Function(String) onChanged;

  const SearchBox({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bằng màu sắc, cấu tạo, thành phần, đặc điểm',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
