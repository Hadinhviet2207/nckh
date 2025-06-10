import 'package:flutter/material.dart';
import 'package:stonelens/ScannerScreen.dart';
import 'package:stonelens/services/mohinh_service.dart';
import 'package:stonelens/views/home/StoneDetailScreen.dart';
import 'package:stonelens/widgets/search/image_thumb.dart';
import 'package:stonelens/widgets/search/result_grid.dart';
import 'package:stonelens/widgets/search/search_box.dart';

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
  final RockDataService _rockDataService = RockDataService();

  @override
  void initState() {
    super.initState();
    _rockDataService
        .fetchRockData(widget.topIndices, widget.rockIds)
        .then((results) {
      setState(() {
        _searchResults = results;
      });
    }).catchError((e) {
      print('Error fetching initial data: $e');
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim();
    });
    _rockDataService
        .performSearch(query, widget.topIndices, widget.rockIds)
        .then((results) {
      setState(() {
        _searchResults = results;
      });
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
                            child: const ImageThumb(icon: Icons.add_a_photo),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SearchBox(onChanged: _onSearchChanged),
                      const SizedBox(height: 5),
                      ResultGrid(searchResults: _searchResults),
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
}
