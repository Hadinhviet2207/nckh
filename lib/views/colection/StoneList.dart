import 'package:flutter/material.dart';
import 'package:stonelens/models/rock_model.dart';
import 'package:stonelens/views/home/StoneDetailScreen.dart';
import 'package:stonelens/views/home/bottom_nav_bar.dart';
import 'package:stonelens/views/colection/chitiet_colection.dart';
import 'package:stonelens/services/delete_stone_service.dart';

class StoneList extends StatefulWidget {
  final List<Map<String, dynamic>> stones;
  final String tabName;
  final RockModel? rock;

  const StoneList({
    Key? key,
    required this.stones,
    this.rock,
    required this.tabName,
  }) : super(key: key);

  @override
  State<StoneList> createState() => _StoneListState();
}

class _StoneListState extends State<StoneList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.stones.length,
      itemBuilder: (context, index) {
        final stone = widget.stones[index];

        return GestureDetector(
          onTap: () {
            if (widget.tabName == "Bộ Sưu Tập") {
              final collectionId = stone['collectionId'];

              // Kiểm tra kỹ ID có tồn tại và hợp lệ không
              if (collectionId != null &&
                  collectionId.toString().trim().isNotEmpty) {
                print('✅ collectionId hợp lệ: $collectionId');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CollectionScreen(collectionId: collectionId),
                  ),
                );
              } else {
                // Log rõ ràng lỗi và toàn bộ dữ liệu đá
                print('⚠️ collectionId bị thiếu hoặc rỗng trong stone!');
                debugPrint('➡️ stone object:\n${stone.toString()}');

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Không tìm thấy collectionId của đá này.'),
                  ),
                );
              }
            } else if (widget.tabName == "Yêu Thích" ||
                widget.tabName == "Lịch Sử") {
              try {
                final rockModel = RockModel.fromJson(stone);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StoneDetailScreen(rock: rockModel),
                  ),
                );
              } catch (e) {
                print('❌ Không thể tạo RockModel từ stone: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Dữ liệu đá không hợp lệ.'),
                  ),
                );
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: stone['hinhAnh']?.isNotEmpty == true
                      ? Image.network(
                          stone['hinhAnh'][0],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.broken_image, size: 70),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stone['tenDa'] ?? 'Không có tên',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Loại đá: ${stone['loaiDa'] ?? 'Không rõ'}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Thời gian: ${stone['time'] ?? 'Không có thời gian'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    popupMenuTheme: PopupMenuThemeData(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.black),
                    offset: const Offset(0, 40),
                    onSelected: (value) {
                      if (value == 'delete') {
                        DeleteStoneService.deleteStoneByTab(
                          context: context,
                          stone: stone,
                          tabName: widget.tabName,
                          onDelete: () {
                            setState(() {
                              widget.stones.remove(stone);
                            });
                          },
                        );
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(
                          'Xóa',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
