import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stonelens/image_search_camera_screen.dart';
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
      dynamic predictedResult = result['result'];
      List<double> rawPredictions = result['raw'];

      // Tìm xác suất cao nhất từ raw predictions
      double confidence = rawPredictions.reduce((a, b) => a > b ? a : b);
      int predictedIndex;
      List<int>? topIndices;

      // Xử lý kết quả dự đoán
      if (predictedResult is int) {
        predictedIndex = predictedResult;
      } else if (predictedResult is List<int>) {
        predictedIndex = predictedResult[0];
        topIndices = predictedResult;
      } else {
        showRockAlertDialog(
          context,
          'Lỗi dự đoán',
          'Kết quả dự đoán không hợp lệ.',
        );
        return;
      }

      print(
          "🎯 Kết quả dự đoán: $predictedIndex | Độ chính xác: ${(confidence * 100).toStringAsFixed(2)}%");
      if (topIndices != null) {
        print("Top indices: $topIndices");
      }

      // Danh sách ID đá trong Firestore, index tương ứng với predictedIndex
      final List<String> rockIds = [
        'vwG9hJwT7I0kiSH9v7nW',
        'L9bPxbJCIq4NOtjequWo',
        'zyryUoCx3nsJsCfKz1gC',
        'ZcyYBBeW52k1OgEJFVc6',
      ];

      // Kiểm tra index hợp lệ
      if (predictedIndex < 0 || predictedIndex >= rockIds.length) {
        showRockAlertDialog(
          context,
          'Không nhận diện được',
          'Ảnh không phải đá hoặc chưa có dữ liệu về đá này. Vui lòng thử lại.',
        );
        return;
      }

      // Nếu top1 > 90%, điều hướng đến StoneDetailScreen
      if (predictedResult is int) {
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
        final Map<String, dynamic> dataWithId = Map<String, dynamic>.from(data);
        dataWithId['id'] = snapshot.id;

        // Lưu lịch sử
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

        // Điều hướng đến StoneDetailScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoneDetailScreen(
              stoneData: jsonEncode(dataWithId),
            ),
          ),
        );
      } else {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // Cho phép full screen nếu cần
          backgroundColor: Colors
              .transparent, // Nền trong suốt để thấy được phần thiết kế bên trong widget
          builder: (context) => ImageSearchCameraScreen(
            topIndices: topIndices!,
            rockIds: rockIds,
          ),
        );
      }
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
