import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nckh/models/rock_model.dart';
import 'package:nckh/services/user_service.dart';
import 'package:nckh/widgets/Result/RockImageDialog_result.dart';

class CollectionDetailScreen extends StatefulWidget {
  final RockModel rock;

  const CollectionDetailScreen({super.key, required this.rock});

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  final TextEditingController orderController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool isLoading = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = UserService().getUserId();
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<List<String>> _uploadImagesToFirebase() async {
    List<String> downloadUrls = [];

    for (int i = 0; i < _selectedImages.length; i++) {
      final image = _selectedImages[i];
      final ref = FirebaseStorage.instance.ref().child(
            'collection_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}',
          );
      final uploadTask = await ref.putFile(File(image.path));
      final url = await uploadTask.ref.getDownloadURL();
      downloadUrls.add(url);
    }

    return downloadUrls;
  }

  Future<void> saveCollection() async {
    if (userId == null) {
      showCustomSnackbar(
        context: context,
        message: "Không tìm thấy thông tin người dùng",
        icon: Icons.error,
        backgroundColor: Colors.redAccent,
      );
      return;
    }

    if (orderController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty ||
        timeController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        noteController.text.trim().isEmpty) {
      showCustomSnackbar(
        context: context,
        message: "Vui lòng nhập đầy đủ các trường thông tin",
        icon: Icons.warning,
        backgroundColor: Colors.orangeAccent,
      );
      return;
    }

    setState(() => isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final name = nameController.text.trim();
      final order = orderController.text.trim();

      // Truy vấn đến subcollection: users/{userId}/collections
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('collections')
          .where('rock_id', isEqualTo: widget.rock.id)
          .get();

      final duplicates = querySnapshot.docs.where((doc) {
        final data = doc.data();
        return data['name'] == name || data['order'] == order;
      });

      if (duplicates.isNotEmpty) {
        Navigator.pop(context); // Close loading
        showCustomSnackbar(
          context: context,
          message: "Đá này đã được thêm vào bộ sưu tập của bạn trước đó!",
          icon: Icons.warning_amber,
          backgroundColor: Colors.red,
        );
        return;
      }

      final imageUrls = await _uploadImagesToFirebase();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('collections')
          .add({
        'rock_id': widget.rock.id,
        'order': order,
        'name': name,
        'time': timeController.text.trim(),
        'location': locationController.text.trim(),
        'note': noteController.text.trim(),
        'images': imageUrls,
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context); // Close loading
        showCustomSnackbar(
          context: context,
          message: "Lưu thành công",
          icon: Icons.check_circle,
          backgroundColor: Colors.green,
        );
        Navigator.pop(context); // Quay lại màn hình trước
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        showCustomSnackbar(
          context: context,
          message: "Lỗi khi lưu: $e",
          icon: Icons.error_outline,
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(thickness: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Thứ tự"),
                    _buildTextField(controller: orderController, hintText: "1"),
                    const SizedBox(height: 16),
                    _buildLabel("Tên của bộ sưu tập"),
                    _buildTextField(
                        controller: nameController,
                        hintText: "Bộ sưu tập của tôi ..."),
                    const SizedBox(height: 16),
                    _buildLabel("Hình ảnh"),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ..._selectedImages.map((image) => Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child:
                                    _buildImageBox(imageFile: File(image.path)),
                              )),
                          _buildAddImageBox(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel("Thời gian"),
                    _buildTextField(
                        controller: timeController,
                        hintText: "Nhập thời gian..."),
                    const SizedBox(height: 16),
                    _buildLabel("Địa điểm"),
                    _buildTextField(
                        controller: locationController,
                        hintText: "Nhập địa điểm..."),
                    const SizedBox(height: 16),
                    _buildLabel("Ghi chú"),
                    _buildNoteField(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // === UI Helpers ===

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text(
              'Bộ sưu tập chi tiết',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: Colors.grey[200], shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 24, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: const Color(0xFFF8F8F8),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: saveCollection,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE6792B),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: const Text(
            "LƯU",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller, String? hintText}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
      style: const TextStyle(
          fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildNoteField() {
    return TextField(
      controller: noteController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: "Thêm vào ghi chú",
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
      ),
      style: const TextStyle(
          fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildImageBox({required File imageFile}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildAddImageBox() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
        child:
            const Center(child: Icon(Icons.add, size: 32, color: Colors.grey)),
      ),
    );
  }
}
