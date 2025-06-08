import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddCollectionView {
  static Widget buildScaffold({
    required BuildContext context,
    required Widget header,
    required List<Widget> formFields,
    required Widget bottomBar,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            header,
            const Divider(thickness: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: formFields,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottomBar,
    );
  }

  static Widget buildHeader({
    required String title,
    required VoidCallback onClose,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: onClose,
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

  static Widget buildBottomBar({
    required VoidCallback onSave,
    required String buttonText,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: const Color(0xFFF8F8F8),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE6792B),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  static Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: controller.text.isEmpty ? hintText : null,
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    );
  }

  static Widget buildNoteField({
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: controller.text.isEmpty ? "Thêm vào ghi chú" : null,
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    );
  }

  static Widget buildImagePicker({
    required String? firstOriginalImage,
    required List<XFile> selectedImages,
    required VoidCallback onPickImages,
    required void Function(int) onRemoveSelectedImage,
    required VoidCallback onRemoveOriginalImage,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (firstOriginalImage != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Stack(
                children: [
                  _buildNetworkImageBox(firstOriginalImage),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onRemoveOriginalImage,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ...selectedImages.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Stack(
                children: [
                  _buildImageBox(File(file.path)),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => onRemoveSelectedImage(index),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          _buildAddImageBox(onPickImages),
        ],
      ),
    );
  }

  static Widget _buildNetworkImageBox(String imageUrl) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image:
            DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      ),
    );
  }

  static Widget _buildImageBox(File file) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
      ),
    );
  }

  static Widget _buildAddImageBox(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, size: 36, color: Colors.grey),
      ),
    );
  }
}
