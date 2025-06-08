import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:stonelens/camera_screen.dart';
import 'package:stonelens/viewmodels/rock_image_recognizer.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with TickerProviderStateMixin {
  XFile? _imageFile;
  String? _recognizedRockType;

  late final AnimationController _scanController;
  late final Animation<double> _scanAnimation;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;
  late final AnimationController _loupeController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<Offset> _translationAnimation;

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation controller
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _loupeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.12).animate(
      CurvedAnimation(parent: _loupeController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.12, end: 0.12).animate(
      CurvedAnimation(parent: _loupeController, curve: Curves.easeInOut),
    );

    _translationAnimation = Tween<Offset>(
      begin: const Offset(-6, -6),
      end: const Offset(6, 6),
    ).animate(
      CurvedAnimation(parent: _loupeController, curve: Curves.easeInOut),
    );

    // Mở camera sau khi widget được xây dựng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openCameraAndGetImage();
    });
  }

  Future<void> _openCameraAndGetImage() async {
    if (!mounted) return;

    final XFile? imageFile = await Navigator.push<XFile>(
      context,
      MaterialPageRoute(builder: (_) => const CustomCameraScreen()),
    );

    if (imageFile != null) {
      setState(() {
        _imageFile = imageFile;
      });
      print("Ảnh đã chụp: ${imageFile.path}");

      // Chạy nhận diện ảnh
      Future.microtask(() async {
        await Future.delayed(const Duration(seconds: 3));
        await RockImageRecognizer().recognizeImageFromFile(context, imageFile);

        if (!mounted) return;

        setState(() {
          _recognizedRockType = "done";
        });

        // Dừng animation
        _scanController.stop();
        _glowController.stop();
        _loupeController.stop();
      });
    } else {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    _glowController.dispose();
    _loupeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanBoxSize = Size(size.width * 0.9, size.height * 0.55);

    return Scaffold(
      backgroundColor: Colors.white,
      body: _imageFile == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Center(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_imageFile!.path),
                          width: scanBoxSize.width,
                          height: scanBoxSize.height,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: scanBoxSize.width,
                        height: scanBoxSize.height,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.brown.shade400,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _scanAnimation,
                          builder: (_, __) => CustomPaint(
                            painter: ScanLinePainter(
                              progress: _scanAnimation.value,
                              color: Colors.orangeAccent.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: (size.width - 100) / 2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Trong phần Positioned chứa hiệu ứng glow
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (_, __) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orangeAccent
                                      .withOpacity(_glowAnimation.value),
                                  blurRadius: 12.0, // Sửa từ 12 | 12 thành 12.0
                                  spreadRadius: 2.0, // Sửa từ 2 | 2 thành 2.0
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/img_rocks.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 10,
                        right: -10,
                        child: AnimatedBuilder(
                          animation: _loupeController,
                          builder: (_, child) {
                            return Transform.translate(
                              offset: _translationAnimation.value,
                              child: Transform.rotate(
                                angle: _rotationAnimation.value,
                                child: Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.search,
                            size: 48,
                            color: Colors.orange.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.black87, size: 26),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class ScanLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  ScanLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * progress;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.2), color, color.withOpacity(0.2)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, y - 1.5, size.width, 3))
      ..strokeWidth = 3;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(covariant ScanLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
