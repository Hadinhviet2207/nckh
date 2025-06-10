import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class RockClassifier {
  late Interpreter _interpreter;

  /// Load mô hình từ assets
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model/test5.tflite');
      print("✅ Model loaded");
    } catch (e) {
      print("❌ Failed to load model: $e");
    }
  }

  Future<Map<String, dynamic>> predict(img.Image image) async {
    // Kiểm tra ảnh đầu vào
    if (image == null) {
      throw Exception("Ảnh đầu vào không hợp lệ");
    }

    // Resize ảnh về 224x224
    final resizedImage = img.copyResize(image, width: 224, height: 224);

    // Kiểm tra kích thước ảnh
    if (resizedImage.width != 224 || resizedImage.height != 224) {
      throw Exception("Ảnh không được resize đúng kích thước 224x224");
    }

    // Chuyển ảnh thành tensor 4D [1, 224, 224, 3]
    var input = List.generate(
        1,
        (_) => List.generate(
            224,
            (x) => List.generate(224, (y) {
                  final pixel = resizedImage.getPixel(x, y);
                  // Ép kiểu an toàn
                  final r = (pixel.r as num?)?.toDouble() ?? 0.0;
                  final g = (pixel.g as num?)?.toDouble() ?? 0.0;
                  final b = (pixel.b as num?)?.toDouble() ?? 0.0;
                  return [r / 255.0, g / 255.0, b / 255.0];
                })));

    // Tạo mảng output
    var output = List.filled(1 * 5, 0.0).reshape([1, 5]);

    // Chạy mô hình
    _interpreter.run(input, output);

    // Lấy danh sách xác suất
    List<double> predictions = output[0];

    // Tạo danh sách các cặp [index, xác suất]
    List<MapEntry<int, double>> indexedPredictions = predictions
        .asMap()
        .entries
        .map((e) => MapEntry(e.key, e.value))
        .toList();

    // Sắp xếp theo xác suất giảm dần
    indexedPredictions.sort((a, b) => b.value.compareTo(a.value));

    // Lấy nhãn cao nhất và nhãn thứ hai
    var top1 = indexedPredictions[0];
    var top2 = indexedPredictions.length > 1 ? indexedPredictions[1] : null;

    // In phần trăm của top1
    print(
        "Top 1 (index ${top1.key}): ${(top1.value * 100).toStringAsFixed(2)}%");

    dynamic result;

    // Ngưỡng xác suất 90%
    const double confidenceThreshold = 0.8;

    if (top1.value > confidenceThreshold) {
      // Nếu top1 > 90%, trả về index của top1
      result = top1.key;
    } else {
      // Nếu top1 <= 90%, trả về [top1, top2] nếu top2 tồn tại
      if (top2 != null) {
        print(
            "Top 2 (index ${top2.key}): ${(top2.value * 100).toStringAsFixed(2)}%");
        result = [top1.key, top2.key];
      } else {
        // Nếu không có top2, trả về [top1]
        result = [top1.key];
      }
    }

    // Giải phóng bộ nhớ mô hình
    _interpreter.close();
    print("✅ Model resources released successfully.");

    return {
      "result": result, // Trả về int hoặc List<int>
      "raw": predictions,
    };
  }
}
