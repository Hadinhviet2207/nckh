import 'package:flutter/material.dart';
import 'package:nckh/services/RockImageDialog.dart';
import 'package:nckh/services/user_service.dart';
import 'package:nckh/viewmodels/rock_image_recognizer.dart';
import 'package:nckh/views/home/SearchScreen.dart';
import 'package:nckh/views/home/SettingsScreen.dart';
import 'package:nckh/views/home/colection_detail.dart';
import 'package:nckh/widgets/homepage/article_section.dart';
import 'package:nckh/widgets/homepage/hero_section.dart';
import 'package:nckh/widgets/homepage/popular_rocks_section.dart';
import 'package:nckh/widgets/homepage/rock_category_section.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 8,
      ),
      body: ScrollConfiguration(
        behavior: NoGlowScrollBehavior(),
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: SearchBar()),
            SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverAnimatedSection(child: HeroSection(), delay: 100),
            SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverAnimatedSection(child: ArticleSection(), delay: 200),
            SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverAnimatedSection(child: PopularRocksSection(), delay: 300),
            SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverAnimatedSection(child: RockCategorySection(), delay: 400),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

// Không hiệu ứng chớp khi cuộn
class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(context, child, details) => child;
}

// Animation cho từng section khi cuộn vào
class SliverAnimatedSection extends StatefulWidget {
  final Widget child;
  final int delay;

  const SliverAnimatedSection({required this.child, this.delay = 0});

  @override
  State<SliverAnimatedSection> createState() => _SliverAnimatedSectionState();
}

class _SliverAnimatedSectionState extends State<SliverAnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

// Thanh tìm kiếm

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 16, top: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey, size: 22),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: IgnorePointer(
                        child: TextField(
                          enabled: false,
                          decoration: InputDecoration(
                            hintText: "Tìm kiếm",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 16),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          StreamBuilder<Map<String, dynamic>?>(
            stream: UserService().getCurrentUserStream(),
            builder: (context, snapshot) {
              // Loading
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Lỗi
              if (snapshot.hasError) {
                return const Center(
                  child: Icon(Icons.error, color: Colors.red),
                );
              }

              final avatarUrl = snapshot.data?['avatar'];

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const SettingsScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0); // Bắt đầu từ trái
                          const end = Offset.zero; // Kết thúc ở giữa màn hình
                          const curve = Curves.easeInOut;

                          final tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          final offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12, width: 1),
                      image: avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(avatarUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: avatarUrl == null
                        ? const Icon(Icons.person,
                            color: Colors.black, size: 24)
                        : null,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    // Không setState nếu là nút giữa
    if (index == 1) return;

    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const Scaffold(
            body: SafeArea(child: CollectionScreen()),
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
            currentIndex: _selectedIndex,
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
                icon: SizedBox.shrink(), // Nút giữa rỗng
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.collections_bookmark, size: 24),
                label: "Bộ sưu tập",
              ),
            ],
          ),
        ),

        // Nút giữa nổi
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
                onPressed: () {
                  RockImageRecognizer().pickAndRecognizeImage(context);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
