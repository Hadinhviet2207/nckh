import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nckh/models/rock_classifier.dart';
import 'package:nckh/views/home/ket_qua.dart';
import 'package:nckh/widgets/homepage/custom_dialog.dart';

class RockImageRecognizer {
  final ImagePicker _picker = ImagePicker();

  Future<void> pickAndRecognizeImage(BuildContext context) async {
    final XFile? imageFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (imageFile == null) return;

    final bytes = await File(imageFile.path).readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      showRockAlertDialog(
        context,
        'Lỗi ảnh',
        'Không thể xử lý ảnh. Vui lòng chọn ảnh khác.',
      );
      return;
    }

    final classifier = RockClassifier();
    await classifier.loadModel();

    final result = await classifier.predict(image);
    int predictedIndex = result['predictedIndex'];
    double confidence = result['confidence'];
    print(
        "🎯 Kết quả dự đoán: $predictedIndex | Độ chính xác: ${(confidence * 100).toStringAsFixed(2)}%");
    final List<String> rockIds = [
      'I9L193idhSdBqeMPghOU',
      'DviEhCtAbdse1mO5ELO3',
      'Sgh169zpRAvDNpSlrELt',
      'rxkyT8MvD08D0pMdGX6e',
      'M3lz86JyDr6fDW9ZND44'
    ];

    if (confidence < 0.70 || predictedIndex >= rockIds.length) {
      showRockAlertDialog(
        context,
        'Không nhận diện được',
        'Ảnh không rõ ràng hoặc chưa có dữ liệu đá này. Vui lòng thử lại.',
      );
      return;
    }

    final String predictedRockName = rockIds[predictedIndex];
    final snapshot = await FirebaseFirestore.instance
        .collection('_rocks')
        .doc(predictedRockName)
        .get();

    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ModelResultScreen(stoneData: data),
        ),
      );
    } else {
      showRockAlertDialog(
        context,
        'Không tìm thấy dữ liệu',
        'Không có dữ liệu cho loại đá đã nhận diện.',
      );
    }
  }
}
