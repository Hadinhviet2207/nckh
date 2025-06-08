import 'package:flutter/material.dart';
import 'package:stonelens/ScannerScreen.dart';
import 'package:stonelens/viewmodels/rock_image_recognizer.dart';
import 'package:stonelens/views/colection/colection_detail.dart';
import 'package:stonelens/views/home/home_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(key: const ValueKey('home')),
    const SizedBox.shrink(),
    ColectionDetailScreen(key: const ValueKey('collection')),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      RockImageRecognizer().pickAndRecognizeImage(context);
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final CircularNotchedRectangle notchShape = CircularNotchedRectangle();
    const double notchMargin = 8.0;

    return ScaffoldMessenger(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _screens[_selectedIndex],
        ),
        floatingActionButton: Transform.translate(
          offset: const Offset(0, 6),
          child: SizedBox(
            width: 64,
            height: 64,
            child: FloatingActionButton(
              elevation: 6,
              shape: const CircleBorder(),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ScannerScreen()),
                );
              },
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFB78E5B), Color(0xFF9D7142)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.photo_camera_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Stack(
          children: [
            BottomAppBar(
              shape: notchShape,
              notchMargin: notchMargin,
              color: Colors.white,
              elevation: 10,
              child: SizedBox(
                height: 45,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home, 'Trang chủ', 0),
                    const SizedBox(width: 35),
                    _buildNavItem(Icons.collections_bookmark, 'Bộ sưu tập', 2),
                  ],
                ),
              ),
            ),
            // Vẽ viền trên có notch vòng lên ôm camera
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                painter: _NotchedTopBorderPainter(
                  notchShape: notchShape,
                  notchMargin: notchMargin,
                  color: Colors.grey.withOpacity(0.2),
                  thickness: 1.5,
                  fabSize: 64,
                  fabMargin: 6,
                ),
                child: const SizedBox(height: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.brown.withOpacity(0.3),
      highlightColor: Colors.brown.withOpacity(0.1),
      child: SizedBox(
        width: 64,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: isSelected ? const Color(0xFF9D7142) : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF9D7142) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotchedTopBorderPainter extends CustomPainter {
  final CircularNotchedRectangle notchShape;
  final double notchMargin;
  final Color color;
  final double thickness;
  final double fabSize;
  final double fabMargin;

  _NotchedTopBorderPainter({
    required this.notchShape,
    required this.notchMargin,
    required this.color,
    required this.thickness,
    required this.fabSize,
    required this.fabMargin,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    final double width = size.width;
    final double y = thickness / 2; // Viền trên của BottomAppBar

    final double centerX = width / 2;
    final double radius = (fabSize / 2) + notchMargin;

    final Path path = Path();

    // Bắt đầu từ bên trái thanh BottomAppBar
    path.moveTo(0, y);

    // Vẽ đường thẳng tới điểm bắt đầu vòng cung notch
    path.lineTo(centerX - radius - fabMargin, y);

    // Vẽ vòng cung tròn vòng lên trên ôm trọn nút camera
    Rect arcRect = Rect.fromCircle(
      center: Offset(
          centerX, y), // Tâm vòng cung ngay trên đường viền và ở giữa màn hình
      radius: radius + fabMargin,
    );

    // Vẽ cung cung ngược chiều kim đồng hồ từ 180° (PI) tới 0°
    path.arcTo(arcRect, 3.14159, -3.14159, false);

    // Tiếp tục đường thẳng tới cuối thanh BottomAppBar
    path.lineTo(width, y);

    // Vẽ đường lên canvas
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NotchedTopBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.thickness != thickness ||
        oldDelegate.fabSize != fabSize ||
        oldDelegate.fabMargin != fabMargin;
  }
}
