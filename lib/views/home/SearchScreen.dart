import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stonelens/models/rock_model.dart';
import 'package:stonelens/services/favorite_service.dart';
import 'package:stonelens/views/home/StoneDetailScreen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<RockModel> _suggestions = [];
  List<RockModel> _searchResults = [];
  bool _loading = true;
  bool _searchLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRandomRocks();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRandomRocks() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('_rocks').get();
      final allRocks = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        final rock = RockModel.fromJson(data);
        print(
            'Document ID: ${doc.id}, Rock ID: ${rock.id}, Name: ${rock.tenDa}');
        return rock;
      }).toList();

      allRocks.shuffle();
      final random3 = allRocks.length > 3 ? allRocks.sublist(0, 3) : allRocks;

      setState(() {
        _suggestions = random3;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print('Lỗi khi tải đá: $e');
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _searchRocks(query);
    } else {
      setState(() {
        _searchResults = [];
        _searchLoading = false;
      });
    }
  }

  Future<void> _searchRocks(String query) async {
    setState(() {
      _searchLoading = true;
    });

    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('_rocks').get();
      final results = querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return RockModel.fromJson(data);
          })
          .where((rock) =>
              (rock.tenDa?.toLowerCase() ?? '').contains(query.toLowerCase()) ||
              (rock.loaiDa?.toLowerCase() ?? '').contains(query.toLowerCase()))
          .toList();

      setState(() {
        _searchResults = results;
        _searchLoading = false;
      });
    } catch (e) {
      print('Lỗi khi tìm kiếm đá: $e');
      setState(() {
        _searchLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: _buildSearchBar(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withOpacity(0.7),
                    width: 1.5,
                  ),
                ),
                child: const Icon(Icons.close, color: Colors.black, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                if (_searchController.text.isEmpty) ...[
                  const Text(
                    "Một số gợi ý dành cho bạn",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    _buildSuggestions(context, constraints.maxHeight),
                ],
                if (_searchController.text.isNotEmpty) ...[
                  const Text(
                    "Kết quả tìm kiếm",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_searchLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Expanded(child: _buildSearchResults()),
                ],
              ],
            ),
          );
        },
      ),
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
              decoration: const InputDecoration(
                hintText: "Tìm kiếm bằng đá và khoáng sản...",
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, double maxHeight) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Tính toán kích thước động dựa trên màn hình
    final itemWidth = screenWidth * 0.35; // 35% chiều rộng màn hình
    final itemHeight = maxHeight * 0.20; // 20% chiều cao màn hình, tối đa 180
    final imageHeight = itemHeight * 0.55; // Hình ảnh chiếm 55% chiều cao mục

    return SizedBox(
      height: itemHeight.clamp(120, 180), // Giới hạn chiều cao từ 120 đến 180
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final rock = _suggestions[index];
          return Container(
            width:
                itemWidth.clamp(100, 160), // Giới hạn chiều rộng từ 100 đến 160
            margin: const EdgeInsets.only(right: 8), // Giảm margin để gọn hơn
            child: _buildRockItem(rock,
                isSuggestion: true, imageHeight: imageHeight),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
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
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final rock = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildRockItem(rock, isSuggestion: false),
        );
      },
    );
  }

  Widget _buildRockItem(RockModel rock,
      {required bool isSuggestion, double? imageHeight}) {
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
              padding: const EdgeInsets.all(6), // Giảm padding để gọn hơn
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
                                height:
                                    imageHeight ?? 80, // Sử dụng chiều cao động
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: double.infinity,
                                  height: imageHeight ?? 80,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported,
                                      size: 30),
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                height: imageHeight ?? 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported,
                                    size: 30),
                              ),
                      ),
                      const SizedBox(height: 6), // Giảm khoảng cách
                      Text(
                        rock.tenDa ?? 'Unknown',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14), // Giảm font
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.category,
                              size: 12,
                              color: Colors.black54), // Giảm kích thước icon
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              rock.loaiDa ?? 'Unknown',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54), // Giảm font
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator(
                              strokeWidth: 2);
                        }
                        bool isFavorite = snapshot.data ?? false;
                        print(
                            'Trạng thái yêu thích của ${rock.id}: $isFavorite');
                        return IconButton(
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
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              key: ValueKey<bool>(isFavorite),
                              color: isFavorite
                                  ? Colors.red
                                  : rock.id.isEmpty
                                      ? Colors.grey
                                      : Colors.grey,
                              size: 24, // Giảm kích thước icon
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
                                Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported,
                                  size: 40),
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child:
                                const Icon(Icons.image_not_supported, size: 40),
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
}
