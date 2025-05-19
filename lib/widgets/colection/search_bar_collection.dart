import 'package:flutter/material.dart';

class SearchBarCollection extends StatelessWidget {
  final VoidCallback? onFilterPressed;

  const SearchBarCollection({super.key, this.onFilterPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Search box chiếm 80% chiều ngang
          Expanded(
            flex: 8,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),

            ),
          ),
          const SizedBox(width: 12),
          // Icon chức năng bên cạnh
          IconButton(
            onPressed: () {
              // TODO: xử lý chức năng khi nhấn
            },
            icon: const Icon(Icons.tune), // ví dụ icon lọc
            tooltip: 'Bộ lọc nâng cao',
          ),
        ],
      ),
    );
  }
}

