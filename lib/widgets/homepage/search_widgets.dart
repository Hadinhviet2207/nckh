import 'package:flutter/material.dart';
import 'package:stonelens/models/rock_model.dart';
import 'package:stonelens/services/favorite_service.dart';
import 'package:stonelens/views/home/StoneDetailScreen.dart';

Widget buildSearchBar(TextEditingController controller) {
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
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Tìm kiếm bằng tên, loại đá, thành phần hóa học...",
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                // Logic được xử lý trong SearchScreenLogic
              }
            },
          ),
        ),
      ],
    ),
  );
}

Widget buildInlineSuggestions(
  BuildContext context,
  List<Map<String, dynamic>> searchResults,
  TextEditingController controller,
  Future<void> Function(String) searchRocks,
) {
  return Container(
    constraints: const BoxConstraints(maxHeight: 100),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Gợi ý cho bạn",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: searchResults.length > 5 ? 5 : searchResults.length,
            itemBuilder: (context, index) {
              final result = searchResults[index];
              final rock = result['rock'] as RockModel;
              final matchedValue = result['matchedValue'] as String;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                title: Text(
                  '$matchedValue',
                  style: const TextStyle(fontSize: 16),
                ),
                onTap: () {
                  controller.text = matchedValue;
                  searchRocks(matchedValue);
                  FocusScope.of(context).unfocus();
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}

Widget buildSuggestions(
  BuildContext context,
  double maxHeight,
  List<RockModel> suggestions,
) {
  final screenWidth = MediaQuery.of(context).size.width;
  final itemWidth = screenWidth * 0.35;
  final itemHeight = maxHeight * 0.20;
  final imageHeight = itemHeight * 0.55;

  return SizedBox(
    height: itemHeight.clamp(120, 180),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final rock = suggestions[index];
        return Container(
          width: itemWidth.clamp(100, 160),
          margin: const EdgeInsets.only(right: 8),
          child: buildRockItem(
            context,
            rock,
            isSuggestion: true,
            imageHeight: imageHeight,
          ),
        );
      },
    ),
  );
}

Widget buildSearchResults(
  BuildContext context,
  List<Map<String, dynamic>> searchResults,
) {
  if (searchResults.isEmpty) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          "Không tìm thấy kết quả",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
  return ListView.builder(
    itemCount: searchResults.length,
    itemBuilder: (context, index) {
      final result = searchResults[index];
      final rock = result['rock'] as RockModel;
      final matchedField = result['matchedField'] as String;
      final matchedValue = result['matchedValue'] as String;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoneDetailScreen(rock: rock),
              ),
            );
          },
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (rock.hinhAnh != null && rock.hinhAnh.isNotEmpty)
                          ? Image.network(
                              rock.hinhAnh.first,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/placeholder.jpg',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/placeholder.jpg',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rock.tenDa ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (matchedField == 'Tên đá')
                            Text(
                              'Loại đá: ${rock.loaiDa ?? 'Unknown'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          else
                            Text(
                              '$matchedField: $matchedValue',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget buildRockItem(
  BuildContext context,
  RockModel rock, {
  required bool isSuggestion,
  double? imageHeight,
}) {
  if (isSuggestion) {
    final favoriteService = FavoriteService();

    void toggleFavorite(bool currentStatus) async {
      print('Nhấn nút yêu thích cho rockId: ${rock.id}');
      try {
        await favoriteService.toggleFavorite(rock.id, !currentStatus);
        print(
            'Thay đổi trạng thái yêu thích thành công: ${!currentStatus ? 'Thêm' : 'Xóa'} yêu thích cho ${rock.id}');
      } catch (e) {
        print('Lỗi khi thay đổi trạng thái yêu thích: $e');
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoneDetailScreen(rock: rock),
          ),
        );
      },
      child: ClipRect(
        child: Card(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (rock.hinhAnh != null && rock.hinhAnh.isNotEmpty)
                          ? Image.network(
                              rock.hinhAnh.first,
                              width: double.infinity,
                              height: imageHeight ?? 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/placeholder.jpg',
                                width: double.infinity,
                                height: imageHeight ?? 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              'assets/placeholder.jpg',
                              width: double.infinity,
                              height: imageHeight ?? 80,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(right: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rock.tenDa ?? 'Unknown',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.category,
                                  size: 12, color: Colors.black54),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  rock.loaiDa ?? 'Unknown',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: StreamBuilder<bool>(
                    stream: favoriteService.rockFavoriteStatusStream(rock.id),
                    initialData: false,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(strokeWidth: 2);
                      }
                      bool isFavorite = snapshot.data ?? false;
                      print('Trạng thái yêu thích của ${rock.id}: $isFavorite');
                      return IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: rock.id.isEmpty
                            ? null
                            : () => toggleFavorite(isFavorite),
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            key: ValueKey<bool>(isFavorite),
                            color: isFavorite
                                ? Colors.red
                                : rock.id.isEmpty
                                    ? Colors.grey
                                    : Colors.grey,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } else {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoneDetailScreen(rock: rock),
          ),
        );
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (rock.hinhAnh != null && rock.hinhAnh.isNotEmpty)
                      ? Image.network(
                          rock.hinhAnh.first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            'assets/placeholder.jpg',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/placeholder.jpg',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rock.tenDa ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rock.loaiDa ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
