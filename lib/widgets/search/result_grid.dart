import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:stonelens/views/home/StoneDetailScreen.dart';
import 'package:stonelens/services/favorite_service.dart';

class ResultGrid extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;

  const ResultGrid({super.key, required this.searchResults});

  @override
  Widget build(BuildContext context) {
    if (searchResults.isEmpty) {
      return const Center(
        child: Text(
          'Không có dữ liệu để hiển thị',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final rock = searchResults[index];
        final imageUrl = (rock['hinhAnh'] is List && rock['hinhAnh'].isNotEmpty)
            ? rock['hinhAnh'].first
            : 'https://via.placeholder.com/150';
        final rockName = rock['tenDa']?.toString() ?? 'Đá không tên';
        final rockType = rock['loaiDa']?.toString() ?? 'Không xác định';

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StoneDetailScreen(stoneData: jsonEncode(rock)),
            ),
          ),
          child: Card(
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 4,
            shadowColor: Colors.black26,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/placeholder.jpg',
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rockName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.share,
                                  size: 14, color: Colors.black),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  rockType,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
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
                  top: 100,
                  right: 10,
                  child: StreamBuilder<bool>(
                    stream: rock['id'] != null
                        ? FavoriteService().rockFavoriteStatusStream(rock['id'])
                        : Stream.value(false),
                    builder: (context, snapshot) {
                      final isFavorite = snapshot.data ?? false;
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4)
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (rock['id'] != null) {
                              FavoriteService()
                                  .toggleFavorite(rock['id'], !isFavorite);
                            }
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                            size: 22,
                          ),
                        ),
                      );
                    },
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
