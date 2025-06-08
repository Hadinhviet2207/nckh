import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stonelens/views/home/rock_comparison_result_screen.dart';

class RockSecondSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> firstStone;

  const RockSecondSelectionScreen({super.key, required this.firstStone});

  @override
  State<RockSecondSelectionScreen> createState() =>
      _RockSecondSelectionScreenState();
}

class _RockSecondSelectionScreenState extends State<RockSecondSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> stones = [];
  Map<String, dynamic>? secondStone;

  @override
  void initState() {
    super.initState();
    _fetchStones();
  }

  Future<void> _fetchStones() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('_rocks').get();

    final List<Map<String, dynamic>> fetched = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();

      // Bỏ đá đầu tiên ra khỏi danh sách dựa vào tên (hoặc thay bằng ID nếu có)
      if (data['tenDa'] != widget.firstStone['tenDa']) {
        fetched.add(data); // Giữ nguyên fields gốc từ Firestore
      }
    }

    setState(() {
      stones = fetched;
    });
  }

  String _getFirstImage(dynamic imageField) {
    if (imageField is List && imageField.isNotEmpty) {
      return imageField[0];
    } else if (imageField is String) {
      return imageField;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStones = stones.where((stone) {
      final query = _searchController.text.toLowerCase();
      final name = (stone['tenDa'] ?? '').toLowerCase();
      final type = (stone['loaiDa'] ?? '').toLowerCase();
      return name.contains(query) || type.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              "Mẫu đá thứ nhất đã chọn",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStoneCard(widget.firstStone, highlight: true),
            const SizedBox(height: 24),
            const Text(
              "Chọn mẫu đá thứ hai",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filteredStones.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredStones.length,
                      itemBuilder: (context, index) {
                        final stone = filteredStones[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              secondStone = stone;
                            });
                          },
                          child: _buildStoneCard(
                            stone,
                            highlight: secondStone?['tenDa'] == stone['tenDa'],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            if (secondStone != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RockComparisonResultScreen(
                          firstStone: widget.firstStone,
                          secondStone: secondStone!, // truyền nguyên bản
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "So sánh",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      title: _buildSearchBar(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.black.withOpacity(0.7), width: 1.5),
              ),
              child: const Icon(Icons.close, color: Colors.black, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: Colors.black54),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: "Tìm kiếm đá hoặc khoáng sản...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black54),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStoneCard(Map<String, dynamic> stone, {bool highlight = false}) {
    final name = stone['tenDa'] ?? 'Không rõ';
    final type = stone['loaiDa'] ?? 'Không rõ';
    final imageField = stone['hinhAnh'];
    final image = (imageField is List && imageField.isNotEmpty)
        ? imageField[0]
        : (imageField is String ? imageField : '');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image.isNotEmpty
                ? Image.network(
                    image,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 70),
                  )
                : const Icon(Icons.broken_image, size: 70),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Loại đá: $type',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
