import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class RockClassifier {
  late Interpreter _interpreter;

  /// Load mô hình từ assets
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model/test3.tflite');
      print("✅ Model loaded");
    } catch (e) {
      print("❌ Failed to load model: $e");
    }
  }

  /// Dự đoán ảnh đã resize
  Future<Map<String, dynamic>> predict(img.Image image) async {
    // Resize ảnh về 224x224
    final resizedImage = img.copyResize(image, width: 224, height: 224);

    // Chuyển ảnh thành tensor 4D [1, 224, 224, 3]
    var input = List.generate(
        1,
        (_) => List.generate(
            224,
            (x) => List.generate(224, (y) {
                  final pixel = resizedImage.getPixel(x, y);
                  final r = pixel.r / 255.0;
                  final g = pixel.g / 255.0;
                  final b = pixel.b / 255.0;
                  return [r, g, b];
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

    // Ngưỡng để xác định "gần bằng nhau" (ví dụ: chênh lệch < 10%)
    const double threshold = 0.1;

    List<Map<String, dynamic>> topLabels;

    // In phần trăm của top1
    print(
        "Top 1 (index ${top1.key}): ${(top1.value * 100).toStringAsFixed(2)}%");

    if (top2 != null) {
      // In phần trăm của top2
      print(
          "Top 2 (index ${top2.key}): ${(top2.value * 100).toStringAsFixed(2)}%");

      if ((top1.value - top2.value) < threshold) {
        // Nếu nhãn cao nhất và nhãn thứ hai gần nhau, trả về cả hai
        topLabels = [
          {"index": top1.key, "confidence": top1.value},
          {"index": top2.key, "confidence": top2.value},
        ];
      } else {
        // Nếu nhãn cao nhất vượt trội, chỉ trả về nhãn cao nhất
        topLabels = [
          {"index": top1.key, "confidence": top1.value},
        ];
      }
    } else {
      // Nếu không có top2, chỉ trả về top1
      topLabels = [
        {"index": top1.key, "confidence": top1.value},
      ];
    }

    // Giải phóng bộ nhớ mô hình
    _interpreter.close();
    print("✅ Model resources released successfully.");

    return {
      "topLabels": topLabels,
      "raw": predictions,
    };
  }
}
