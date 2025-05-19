import 'package:flutter/material.dart';
import 'package:nckh/viewmodels/rock_image_recognizer.dart';
import 'package:nckh/views/home/home_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 2 màn hình chính
  final List<Widget> _screens = [
    HomeScreen(),
    const CollectionScreen(),
  ];

  void _onItemTapped(int index) {
    // Bỏ qua nút giữa (index 1)
    if (index == 1) return;

    setState(() {
      _selectedIndex = index == 2 ? 1 : 0; // 0: Home, 1: Collection
    });
  }

  void _onCameraPressed() {
    RockImageRecognizer().pickAndRecognizeImage(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body: dùng IndexedStack để giữ trạng thái các tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // Nút bottom bar tùy chỉnh
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 7, bottom: 5),
            decoration: const BoxDecoration(
              color: Color(0xFF222222),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex:
                  _selectedIndex == 0 ? 0 : 2, // điều chỉnh label đúng
              onTap: _onItemTapped,
              selectedItemColor: const Color(0xFFE5C47E),
              unselectedItemColor: Colors.white,
              selectedFontSize: 16,
              unselectedFontSize: 15,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.apps, size: 24),
                  label: "Trang chủ",
                ),
                BottomNavigationBarItem(
                  icon: SizedBox.shrink(), // nút giữa rỗng
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.collections_bookmark, size: 24),
                  label: "Bộ sưu tập",
                ),
              ],
            ),
          ),

          // Nút giữa nổi bật
          Positioned(
            bottom: 25,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFF8C89F8),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.photo_camera_outlined,
                    color: Colors.white,
                    size: 34,
                  ),
                  onPressed: _onCameraPressed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------- CollectionScreen giữ nguyên nội dung chính với vài sửa nhỏ ---------

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  String selectedTab = "Bộ Sưu Tập";
  String searchText = "";

  final Map<String, List<String>> fakeData = {
    "Bộ Sưu Tập": List.generate(6, (index) => "Mẫu đá $index"),
    "Yêu Thích": List.generate(3, (index) => "Đá yêu thích $index"),
    "Lịch Sử": List.generate(4, (index) => "Lịch sử $index"),
  };

  @override
  Widget build(BuildContext context) {
    final displayedItems = fakeData[selectedTab]!
        .where((item) => item.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // Header phần trên
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF303A53),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: const [
                              CircleAvatar(
                                radius: 30,
                                child: Icon(Icons.person, size: 35),
                              ),
                              SizedBox(height: 12),
                              Text(
                                "User name",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              Text(
                                "Location",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Icon(Icons.settings,
                              color: Colors.white, size: 40),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          _StatColumn(title: "Bộ Sưu Tập", count: "0"),
                          VerticalDivider(color: Colors.white, thickness: 1),
                          _StatColumn(title: "Yêu Thích", count: "0"),
                          VerticalDivider(color: Colors.white, thickness: 1),
                          _StatColumn(title: "Lịch Sử", count: "0"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tab chọn
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ["Bộ Sưu Tập", "Yêu Thích", "Lịch Sử"]
                      .map(
                        (tab) => GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTab = tab;
                              searchText = ""; // reset search khi đổi tab
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selectedTab == tab
                                  ? const Color(0xFF303A53)
                                  : const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                fontSize: 15,
                                color: selectedTab == tab
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 2),
              const Divider(
                color: Colors.black,
                thickness: 1.1,
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Row(
                  children: [
                    // Thanh tìm kiếm
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
                            const Icon(Icons.search,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    searchText = value;
                                  });
                                },
                                style: const TextStyle(fontSize: 13),
                                decoration: const InputDecoration(
                                  hintText: "Tìm kiếm...",
                                  hintStyle: TextStyle(color: Colors.grey),
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

                    const SizedBox(width: 60),

                    // Nút sắp xếp
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Transform.translate(
                        offset: const Offset(0, 4),
                        child: PopupMenuButton<String>(
                          color: Colors.white,
                          offset: const Offset(0, 36),
                          icon: const Icon(Icons.sort,
                              size: 20, color: Colors.black87),
                          onSelected: (value) {
                            print("Sắp xếp theo: $value");
                            // Xử lý logic sắp xếp
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                                value: 'time', child: Text('Theo thời gian')),
                            const PopupMenuItem(
                                value: 'name', child: Text('Theo tên')),
                            const PopupMenuItem(
                                value: 'type', child: Text('Theo loại đá')),
                            const PopupMenuItem(
                                value: 'order', child: Text('Theo thứ tự')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Grid hiển thị
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: displayedItems.isEmpty
                      ? Center(
                          child: Text(
                            "Không có dữ liệu phù hợp",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        )
                      : GridView.builder(
                          itemCount: displayedItems.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemBuilder: (context, index) {
                            final item = displayedItems[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF303A53),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
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
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        Text(
          count,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}
