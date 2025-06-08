import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stonelens/models/rock_classifier.dart';
import 'package:stonelens/views/home/StoneDetailScreen.dart';
import 'package:stonelens/widgets/homepage/custom_dialog.dart';

class RockImageRecognizer {
  final ImagePicker _picker = ImagePicker();

  // 1. Chọn ảnh từ gallery
  Future<void> pickAndRecognizeImage(BuildContext context) async {
    final XFile? imageFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (imageFile == null) return;

    await _processImage(context, imageFile);
  }

  // 2. Nhận ảnh từ camera dưới dạng XFile
  Future<void> recognizeImageFromFile(
      BuildContext context, XFile imageFile) async {
    await _processImage(context, imageFile);
  }

  // Hàm private xử lý chung ảnh nhận được
  Future<void> _processImage(BuildContext context, XFile imageFile) async {
    try {
      final bytes = await File(imageFile.path).readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        showRockAlertDialog(
          context,
          'Lỗi ảnh',
          'Không thể xử lý ảnh. Vui lòng thử lại.',
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

      // Danh sách ID đá trong Firestore, index tương ứng với predictedIndex
      final List<String> rockIds = [
        'I9L193idhSdBqeMPghOU',
        'DviEhCtAbdse1mO5ELO3',
        'Sgh169zpRAvDNpSlrELt',
        'M3lz86JyDr6fDW9ZND44',
      ];

      // Nếu predictedIndex không hợp lệ hoặc không có trong danh sách
      if (predictedIndex < 0 || predictedIndex >= rockIds.length) {
        showRockAlertDialog(
          context,
          'Không nhận diện được',
          'Ảnh không phải đá hoặc chưa có dữ liệu về đá này. Vui lòng thử lại.',
        );
        return;
      }

      if (confidence < 0.50) {
        showRockAlertDialog(
          context,
          'Không nhận diện được',
          'Ảnh không rõ ràng. Vui lòng thử lại.',
        );
        return;
      }

      final String predictedRockId = rockIds[predictedIndex];
      final snapshot = await FirebaseFirestore.instance
          .collection('_rocks')
          .doc(predictedRockId)
          .get();

      if (!snapshot.exists) {
        showRockAlertDialog(
          context,
          'Không tìm thấy dữ liệu',
          'Không có dữ liệu cho loại đá đã nhận diện.',
        );
        return;
      }

      final Map<String, dynamic> data = snapshot.data()!;
      // Thêm id document vào map data để sau này dùng cho yêu thích
      final Map<String, dynamic> dataWithId = Map<String, dynamic>.from(data);
      dataWithId['id'] = snapshot.id;

      // Thời gian hiện tại
      final now = DateTime.now().toUtc().add(const Duration(hours: 7));
      final formattedTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} - "
          "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final historyRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('history_rocks');

        final existingQuery = await historyRef
            .where('tenDa', isEqualTo: data['tenDa'])
            .limit(1)
            .get();

        if (existingQuery.docs.isEmpty) {
          await historyRef.add({
            'rock_id': predictedRockId,
            'tenDa': data['tenDa'],
            'time': formattedTime,
            'predictedAt': FieldValue.serverTimestamp(),
          });
        } else {
          print("⚠️ Đá này đã có trong lịch sử, không thêm lại.");
        }
      }

      // Điều hướng đến màn hình chi tiết đá, truyền dữ liệu đã có id
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoneDetailScreen(
            stoneData: jsonEncode(dataWithId), // encode map có id
          ),
        ),
      );
    } catch (e) {
      print("🔥 Lỗi xử lý ảnh hoặc nhận diện: $e");
      showRockAlertDialog(
        context,
        'Lỗi hệ thống',
        'Có lỗi xảy ra khi xử lý ảnh, vui lòng thử lại.',
      );
    }
  }
}
