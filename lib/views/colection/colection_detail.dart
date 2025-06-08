import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stonelens/views/colection/StoneList.dart';

class ColectionDetailScreen extends StatefulWidget {
  const ColectionDetailScreen({super.key});

  @override
  State<ColectionDetailScreen> createState() => _ColectionDetailScreenState();
}

class _ColectionDetailScreenState extends State<ColectionDetailScreen> {
  String selectedTab = "Bộ Sưu Tập Đá";
  String searchText = "";
  String userFullName = "User name";
  String avatarUrl = "";

  final Map<String, String> tabKeyMap = {
    "Bộ Sưu Tập Đá": "Bộ Sưu Tập",
    "Đá Đã Yêu Thích": "Yêu Thích",
    "Lịch Sử Xem Đá": "Lịch Sử",
  };

  final Map<String, List<Map<String, dynamic>>> fakeData = {
    "Bộ Sưu Tập": [],
    "Yêu Thích": [],
    "Lịch Sử": [],
  };

  bool _isDisposed = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    _fetchDataForAllTabs();
  }

  Future<void> _fetchDataForAllTabs() async {
    await Future.wait([
      fetchCollectionStones(),
      fetchFavoriteStones(),
      fetchHistoryStones(),
    ]);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounce?.cancel();
    super.dispose();
  }

  void safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  void onTabChanged(String newTab) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      safeSetState(() {
        selectedTab = newTab;
        searchText = "";
      });
      // Nếu bạn muốn fetch lại dữ liệu mỗi lần đổi tab, gọi fetch tại đây
    });
  }

  Future<void> fetchUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        safeSetState(() {
          userFullName = data?['fullname'] ?? "User name";
          avatarUrl = data?['avatar'] ?? "";
        });
      }
    } catch (e) {
      print("Error fetching user info: $e");
    }
  }

  Future<void> fetchCollectionStones() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final collectionSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('collections')
          .get();

      final List<Map<String, dynamic>> data = [];

      for (var doc in collectionSnapshot.docs) {
        final rockId = doc['rock_id'] as String?;
        final collectionName = doc['tenDa'] as String?;
        final images = List<String>.from(doc['hinhAnh'] ?? []);
        final timeString = doc['time'] as String? ?? 'No time';

        if (rockId == null || rockId.isEmpty) continue;

        final rockDoc = await FirebaseFirestore.instance
            .collection('_rocks')
            .doc(rockId)
            .get();

        if (rockDoc.exists) {
          final rock = Map<String, dynamic>.from(rockDoc.data()!);
          rock['id'] = rockDoc.id;
          rock['tenDa'] = collectionName ?? rock['tenDa'] ?? 'No name';
          rock['time'] = timeString;

          // Thêm collectionId để tránh lỗi khi mở CollectionScreen
          rock['collectionId'] = doc.id;

          // Ưu tiên ảnh thứ [1] nếu có
          if (images.length > 1) {
            rock['hinhAnh'] = [
              images[1],
              ...images.where((img) => img != images[1])
            ];
          } else {
            rock['hinhAnh'] = images;
          }

          data.add(rock);
        }
      }

      safeSetState(() {
        fakeData["Bộ Sưu Tập"] = data;
      });
    } catch (e) {
      print("Error fetching collection stones: $e");
    }
  }

  Future<void> fetchFavoriteStones() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      if (snapshot.docs.isEmpty) {
        safeSetState(() {
          fakeData["Yêu Thích"] = [];
        });
        return;
      }

      // Tạo map chứa rock_id -> time
      final rockTimeMap = {
        for (var doc in snapshot.docs)
          doc['rock_id']: doc['time'] ?? '', // fallback nếu không có time
      };

      final rockIds = rockTimeMap.keys.toList();

      final rocksSnapshot = await FirebaseFirestore.instance
          .collection('_rocks')
          .where(FieldPath.documentId, whereIn: rockIds)
          .get();

      final data = rocksSnapshot.docs.map((doc) {
        final rock = Map<String, dynamic>.from(doc.data());
        final rockId = doc.id;
        rock['id'] = rockId;
        rock['time'] = rockTimeMap[rockId]; // gán thêm time từ favorites
        return rock;
      }).toList();

      safeSetState(() {
        fakeData["Yêu Thích"] = data;
      });
    } catch (e) {
      print("Error fetching favorite stones: $e");
    }
  }

  Future<void> fetchHistoryStones() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history_rocks')
          .get();

      if (snapshot.docs.isEmpty) {
        safeSetState(() {
          fakeData["Lịch Sử"] = [];
        });
        return;
      }

      // Map chứa rock_id -> time từ history_rocks
      final rockTimeMap = {
        for (var doc in snapshot.docs) doc['rock_id']: doc['time'] ?? '',
      };

      final rockIds = rockTimeMap.keys.toList();

      final rocksSnapshot = await FirebaseFirestore.instance
          .collection('_rocks')
          .where(FieldPath.documentId, whereIn: rockIds)
          .get();

      final data = rocksSnapshot.docs.map((doc) {
        final rock = Map<String, dynamic>.from(doc.data());
        final rockId = doc.id;
        rock['id'] = rockId;
        rock['time'] = rockTimeMap[rockId]; // gán time từ history_rocks
        return rock;
      }).toList();

      safeSetState(() {
        fakeData["Lịch Sử"] = data;
      });
    } catch (e) {
      print("Error fetching history stones: $e");
    }
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF303A53),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          avatarUrl.isNotEmpty
              ? CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(avatarUrl),
                )
              : const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 34),
                ),
          const SizedBox(height: 12),
          Text(
            userFullName,
            style: const TextStyle(color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatColumn(
                    title: "Bộ Sưu Tập",
                    count: fakeData["Bộ Sưu Tập"]!.length.toString()),
                const VerticalDivider(color: Colors.white, thickness: 1),
                _StatColumn(
                    title: "Yêu Thích",
                    count: fakeData["Yêu Thích"]!.length.toString()),
                const VerticalDivider(color: Colors.white, thickness: 1),
                _StatColumn(
                  title: "Lịch Sử",
                  count: fakeData["Lịch Sử"]!.length.toString(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSort() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                const Icon(Icons.search, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    onChanged: (value) =>
                        safeSetState(() => searchText = value),
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: "Tìm kiếm...",
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTabKey = tabKeyMap[selectedTab]!;
    final items = fakeData[currentTabKey] ?? [];
    final filteredItems = items.where((item) {
      // Dùng trường 'name' để tìm kiếm nếu có, hoặc fallback 'tenDa'
      final name =
          (item['name'] ?? item['tenDa'] ?? '').toString().toLowerCase();
      return name.contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          AppBar(backgroundColor: Colors.white, elevation: 0, toolbarHeight: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildTabSelector(),
              const Divider(color: Colors.black, thickness: 1.1, height: 20),
              _buildSearchAndSort(),
              const SizedBox(height: 20),
              Expanded(
                  child: StoneList(
                stones: filteredItems,
                tabName: currentTabKey,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    final tabs = tabKeyMap.keys.toList();
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = selectedTab == tab;

          return GestureDetector(
            onTap: () => onTabChanged(tab),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF303A53)
                    : const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String title;
  final String count;

  const _StatColumn({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        Text(title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }
}
