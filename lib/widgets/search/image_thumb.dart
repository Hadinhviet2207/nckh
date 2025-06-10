import 'package:flutter/material.dart';

class ImageThumb extends StatelessWidget {
  final IconData? icon;

  const ImageThumb({super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        height: 64,
        color: Colors.grey[200],
        child: icon != null
            ? Icon(icon, color: Colors.grey[600], size: 24)
            : const Icon(Icons.image, color: Colors.grey, size: 24),
      ),
    );
  }
}
