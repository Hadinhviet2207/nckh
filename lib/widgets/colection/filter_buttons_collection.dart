import 'package:flutter/material.dart';

class FilterButtonsCollection extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onFilterSelected;

  const FilterButtonsCollection({
    Key? key,
    required this.selectedIndex,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildButton("Bộ sưu tập", 0)),
          const SizedBox(width: 8),
          Expanded(child: _buildButton("Yêu thích", 1)),
          const SizedBox(width: 8),
          Expanded(child: _buildButton("Lịch sử", 2)),
        ],
      ),
    );
  }


  Widget _buildButton(String text, int index) {
    final isSelected = index == selectedIndex;
    return ElevatedButton(
      onPressed: () => onFilterSelected(index),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(text),
    );
  }
}
