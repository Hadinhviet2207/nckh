import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CustomCameraScreen extends StatefulWidget {
  const CustomCameraScreen({Key? key}) : super(key: key);

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  Future<void>? _initializeCameraFuture; // Không dùng `late`

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // Gọi hàm khởi tạo camera

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.9).animate(_animationController);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No cameras available');
        return;
      }

      final firstCamera = cameras.first;

      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeCameraFuture = _cameraController!.initialize().then((_) async {
        await _cameraController!.setFlashMode(FlashMode.off);
        if (mounted) {
          setState(() {});
        }
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _initializeCameraFuture =
          Future.value(); // Gán giá trị mặc định để tránh lỗi
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      await _initializeCameraFuture;

      final XFile image = await _cameraController!.takePicture();

      if (mounted) {
        Navigator.pop(context, image);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        Navigator.pop(context, image);
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double cameraHeight = size.height * 0.6;
    final double cameraWidth = size.width * 0.95;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top bar with close and flash
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _glassButton(
                    icon: Icons.close,
                    onTap: () => Navigator.pop(context),
                  ),
                  _glassButton(
                    icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    onTap: _toggleFlash,
                  ),
                ],
              ),
            ),
            // Camera preview container
            Center(
              child: FutureBuilder<void>(
                future: _initializeCameraFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      _cameraController != null &&
                      _cameraController!.value.isInitialized) {
                    return Container(
                      width: cameraWidth,
                      height: cameraHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.1),
                          width: 1.5,
                        ),
                        color: Colors.black12,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: CameraPreview(_cameraController!),
                    );
                  } else {
                    return Container(
                      width: cameraWidth,
                      height: cameraHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.1),
                          width: 1.5,
                        ),
                        color: Colors.black12,
                      ),
                      child: const Center(
                        child:
                            SizedBox(), // Không hiển thị gì khi đang khởi tạo
                      ),
                    );
                  }
                },
              ),
            ),
            // Bottom controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Gallery button on left
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: GestureDetector(
                        onTap: _pickImageFromGallery,
                        child: _bottomIcon(
                          Icons.photo_library_rounded,
                          "Photos",
                        ),
                      ),
                    ),
                  ),
                  // Capture button center with animation
                  GestureDetector(
                    onTapDown: (_) => _animationController.reverse(),
                    onTapUp: (_) {
                      _animationController.forward();
                      _takePicture();
                    },
                    onTapCancel: () => _animationController.forward(),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _captureButton(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
        child: Icon(icon, color: Colors.black.withOpacity(0.8), size: 24),
      ),
    );
  }

  Widget _bottomIcon(IconData icon, String label,
      {Color? color, Color? bgColor, Color? borderColor}) {
    final iconColor = color ?? Colors.black.withOpacity(0.85);
    final backgroundColor = bgColor ?? Colors.grey.withOpacity(0.1);
    final borderClr = borderColor ?? Colors.grey.withOpacity(0.3);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderClr, width: 1),
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.nunito(
            color: iconColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _captureButton(
      {Color? borderColor, Color? shadowColor, Color? innerColor}) {
    return Container(
      height: 72,
      width: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? Colors.black.withOpacity(0.85),
          width: 4,
        ),
        color: innerColor ?? Colors.black.withOpacity(0.08),
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }
}
