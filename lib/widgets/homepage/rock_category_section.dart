import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nckh/services/favorite_service.dart';
import 'package:nckh/views/home/StoneDetailScreen.dart';
import 'package:nckh/models/rock_model.dart'; // Đường dẫn này tùy thuộc vị trí file RockModel

class RockCategorySection extends StatefulWidget {
  @override
  _RockCategorySectionState createState() => _RockCategorySectionState();
}

class _RockCategorySectionState extends State<RockCategorySection> {
  String selectedCategory = "Tất cả";
  List<String> categories = ["Tất cả"];
  List<RockModel> allRocks = [];

  @override
  void initState() {
    super.initState();
    fetchRockData();
  }

  Future<void> fetchRockData() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('_rocks').get();

    final rocks = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return RockModel.fromJson(data);
    }).toList();

    final types = rocks
        .map((rock) => rock.nhomDa)
        .toSet()
        .where((type) => type.isNotEmpty)
        .toList();

    setState(() {
      allRocks = rocks;
      categories = ['Tất cả', ...types];
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredRocks = selectedCategory == "Tất cả"
        ? allRocks
        : allRocks.where((rock) => rock.nhomDa == selectedCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "Các nhóm đá chính",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 40,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory == category;
              return GestureDetector(
                onTap: () => setState(() => selectedCategory = category),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF303A53) : Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: filteredRocks.length,
            itemBuilder: (context, index) {
              final rock = filteredRocks[index];
              return RockCard(rock: rock);
            },
          ),
        ),
      ],
    );
  }
}

class RockCard extends StatelessWidget {
  final RockModel rock;
  final FavoriteService _favoriteService = FavoriteService();

  RockCard({super.key, required this.rock});

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoneDetailScreen(rock: rock),
      ),
    );
  }

  void _toggleFavorite(bool isFavorite) {
    _favoriteService.toggleFavorite(rock.id, !isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        rock.hinhAnh.isNotEmpty && rock.hinhAnh[0].toString().isNotEmpty;
    final imageUrl = hasImage ? rock.hinhAnh[0] : 'assets/placeholder.jpg';

    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
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
                  child: imageUrl.startsWith('http')
                      ? Image.network(
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
                        )
                      : Image.asset(
                          'assets/placeholder.jpg',
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rock.tenDa,
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
                              rock.nhomDa,
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
                stream: _favoriteService.rockFavoriteStatusStream(rock.id),
                builder: (context, snapshot) {
                  final isFavorite = snapshot.data ?? false;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4)
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => _toggleFavorite(isFavorite),
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
  }
}
