import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stonelens/ScannerScreen.dart';
import 'package:stonelens/views/home/StoneDetailScreen.dart';
import 'package:stonelens/services/favorite_service.dart';

class ImageSearchCameraScreen extends StatefulWidget {
  final List<int> topIndices;
  final List<String> rockIds;

  const ImageSearchCameraScreen({
    super.key,
    required this.topIndices,
    required this.rockIds,
  });

  @override
  _ImageSearchCameraScreenState createState() =>
      _ImageSearchCameraScreenState();
}

class _ImageSearchCameraScreenState extends State<ImageSearchCameraScreen> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  final FavoriteService _favoriteService = FavoriteService();

  @override
  void initState() {
    super.initState();
    _fetchRockData().then((results) {
      setState(() {
        _searchResults = results;
        print('Initial search results: $results');
      });
    }).catchError((e) {
      print('Error fetching initial data: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          ModalBarrier(
            color: Colors.black.withOpacity(0.4),
            dismissible: true,
            onDismiss: () => Navigator.pop(context),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tìm kiếm bằng hình ảnh',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ScannerScreen()),
                              );
                            },
                            child: _imageThumb(icon: Icons.add_a_photo),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSearchBox(),
                      const SizedBox(height: 5),
                      _searchResults.isEmpty && _searchQuery.isNotEmpty
                          ? const Center(child: Text('Không tìm thấy kết quả'))
                          : _buildResultGrid(),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
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
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim();
            print('Search query: $_searchQuery');
          });
          _performSearch();
        },
      ),
    );
  }

  Widget _buildResultGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final rock = _searchResults[index];
        final imageUrl = (rock['hinhAnh'] as List?)?.first ??
            'https://via.placeholder.com/150';

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
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          'assets/placeholder.jpg',
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rock['tenDa'] ?? 'Đá không tên',
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
                                  rock['loaiDa'] ?? 'Không xác định',
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
                        ? _favoriteService.rockFavoriteStatusStream(rock['id'])
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
                              _favoriteService.toggleFavorite(
                                  rock['id'], !isFavorite);
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

  Widget _imageThumb({IconData? icon}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        height: 64,
        color: Colors.grey[200],
        child: icon != null
            ? Icon(icon, color: Colors.grey[600], size: 24)
            : const Icon(Icons.image, color: Colors.grey, size: 24),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRockData() async {
    print(
        'Fetching rock data with topIndices: ${widget.topIndices}, rockIds: ${widget.rockIds}');
    List<Map<String, dynamic>> rocks = [];
    for (int index in widget.topIndices) {
      if (index >= 0 && index < widget.rockIds.length) {
        final rockId = widget.rockIds[index];
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('_rocks')
              .doc(rockId)
              .get();
          if (snapshot.exists && snapshot.data() != null) {
            final data = snapshot.data()!;
            final rockData = Map<String, dynamic>.from(data);
            rockData['id'] = snapshot.id;
            rocks.add(rockData);
          } else {
            print('No data for rockId: $rockId');
          }
        } catch (e) {
          print('Error fetching rockId $rockId: $e');
        }
      } else {
        print('Invalid index: $index');
      }
    }
    print('Fetched rocks: $rocks');
    return rocks;
  }

  Future<void> _performSearch() async {
    print('Performing search with query: $_searchQuery');
    if (_searchQuery.isEmpty) {
      final initialResults = await _fetchRockData();
      setState(() {
        _searchResults = initialResults;
        print('Search results (empty query): $initialResults');
      });
      return;
    }

    final query = _searchQuery.toLowerCase();
    List<Map<String, dynamic>> results = [];

    try {
      final fields = ['mauSac', 'cauTao', 'thanhPhanHoaHoc', 'dacDiem'];
      final snapshots = await Future.wait(
        fields.map((field) => FirebaseFirestore.instance
            .collection('_rocks')
            .where(field, arrayContains: query)
            .get()),
      );

      final allDocs = <DocumentSnapshot>{};
      for (var snapshot in snapshots) {
        print('Docs found for field: ${snapshot.docs.length}');
        allDocs.addAll(snapshot.docs);
      }

      for (var doc in allDocs) {
        final rockData = Map<String, dynamic>.from(doc.data() as Map);
        rockData['id'] = doc.id;
        results.add(rockData);
      }
    } catch (e) {
      print('Error performing search: $e');
    }

    setState(() {
      _searchResults = results;
      print('Search results: $results');
    });
  }
}
