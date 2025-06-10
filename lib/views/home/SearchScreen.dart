import 'package:flutter/material.dart';
import 'package:stonelens/viewmodels/search_screen_logic.dart';
import 'package:stonelens/widgets/homepage/search_widgets.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final SearchScreenLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = SearchScreenLogic(
      context: context,
      setState: setState,
      onSearchChanged: () => setState(() {}),
    );
    _logic.init();
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: buildSearchBar(_logic.searchController),
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
                if (_logic.searchController.text.isNotEmpty &&
                    _logic.searchResults.isNotEmpty)
                  buildInlineSuggestions(
                    context,
                    _logic.searchResults,
                    _logic.searchController,
                    _logic.searchRocks,
                  ),
                const SizedBox(height: 12),
                if (_logic.searchController.text.isEmpty) ...[
                  const Text(
                    "Một số gợi ý dành cho bạn",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_logic.loading)
                    const Center(child: CircularProgressIndicator())
                  else
                    buildSuggestions(
                      context,
                      constraints.maxHeight,
                      _logic.suggestions,
                    ),
                ],
                if (_logic.searchController.text.isNotEmpty) ...[
                  const Text(
                    "Kết quả tìm kiếm",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (_logic.searchLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Expanded(
                        child:
                            buildSearchResults(context, _logic.searchResults)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
