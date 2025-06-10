import 'package:cloud_firestore/cloud_firestore.dart';

class RockDataService {
  /// Lấy dữ liệu đá từ Firestore dựa trên topIndices và rockIds
  Future<List<Map<String, dynamic>>> fetchRockData(
      List<int> topIndices, List<String> rockIds) async {
    if (topIndices.isEmpty || rockIds.isEmpty) {
      print('topIndices hoặc rockIds rỗng');
      return [];
    }

    List<Map<String, dynamic>> rocks = [];
    final validRockIds = topIndices
        .where((index) => index >= 0 && index < rockIds.length)
        .map((index) => rockIds[index])
        .toList();

    if (validRockIds.isEmpty) {
      print('Không có rockIds hợp lệ');
      return [];
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('_rocks')
          .where(FieldPath.documentId, whereIn: validRockIds)
          .get();

      for (var doc in snapshot.docs) {
        if (doc.exists && doc.data().isNotEmpty) {
          final rockData = Map<String, dynamic>.from(doc.data());
          rockData['id'] = doc.id;
          rocks.add(rockData);
        } else {
          print('Tài liệu ${doc.id} không tồn tại hoặc rỗng');
        }
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu: $e');
    }

    print('Dữ liệu đá lấy được: $rocks');
    return rocks;
  }

  /// Tìm kiếm nâng cao với so sánh từng từ, hỗ trợ có dấu và không dấu
  Future<List<Map<String, dynamic>>> performSearch(
      String query, List<int> topIndices, List<String> rockIds) async {
    // Lấy danh sách đá ban đầu
    final rocks = await fetchRockData(topIndices, rockIds);

    // Nếu query rỗng, trả về danh sách ban đầu
    if (query.isEmpty) {
      return rocks;
    }

    // Tách query thành các từ khóa và chuẩn hóa
    final keywords = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((k) => k.isNotEmpty)
        .map((k) => _normalize(k))
        .toList();
    const fields = [
      'mauSac',
      'cauTao',
      'thanhPhanHoaHoc',
      'dacDiem',
      'loaiDa',
      'kienTruc'
    ];
    List<Map<String, dynamic>> results = [];

    for (var rock in rocks) {
      double score = 0.0; // Điểm số đánh giá mức độ khớp

      for (var field in fields) {
        final fieldValue = rock[field];
        if (fieldValue == null) continue;

        // Lấy tất cả các từ trong giá trị trường
        List<String> fieldWords = [];
        if (fieldValue is String) {
          fieldWords = fieldValue
              .toLowerCase()
              .split(RegExp(r'\s+|,|;'))
              .where((w) => w.isNotEmpty)
              .map((w) => _normalize(w))
              .toList();
        } else if (fieldValue is List) {
          fieldWords = fieldValue
              .where((item) => item != null)
              .expand((item) =>
                  item.toString().toLowerCase().split(RegExp(r'\s+|,|;')))
              .where((w) => w.isNotEmpty)
              .map((w) => _normalize(w))
              .toList();
        }

        // Xử lý công thức hóa học với độ chính xác cao
        double fieldWeight = field == 'kienTruc' ? 3.0 : 1.0;

        // So sánh từng từ khóa với từng từ trong giá trị trường
        for (var keyword in keywords) {
          for (var word in fieldWords) {
            if (word.contains(keyword)) {
              // Tính tỷ lệ khớp dựa trên độ dài từ khóa
              final matchRatio = keyword.length / (word.length + 1);
              score += matchRatio * fieldWeight;
            }
          }
        }
      }

      // Chuẩn hóa điểm số dựa trên số từ khóa
      if (score > 0) {
        final normalizedScore = score / keywords.length;
        final rockWithScore = Map<String, dynamic>.from(rock);
        rockWithScore['score'] = normalizedScore;
        results.add(rockWithScore);
      }
    }

    // Sắp xếp kết quả theo score giảm dần
    results.sort((a, b) => b['score'].compareTo(a['score']));

    // Loại bỏ trường score khỏi kết quả cuối cùng
    final finalResults = results.map((rock) {
      final rockCopy = Map<String, dynamic>.from(rock);
      rockCopy.remove('score');
      return rockCopy;
    }).toList();

    print('Kết quả tìm kiếm: $finalResults');
    return finalResults;
  }

  /// Chuẩn hóa chuỗi: Chuyển có dấu thành không dấu
  String _normalize(String input) {
    const vietnameseChars =
        'àáảãạăắằẳẵặâấầẩẫậèéẻẽẹêếềểễệìíỉĩịòóỏõọôốồổỗộơớờởỡợùúủũụưứừửữựỳýỷỹỵđ';
    const noAccentChars =
        'aaaaaăaaaaaâaaaaaeeeeeêeeeeeiiiiioooooôoooooơoooooouuuuuưuuuuuyyyyyd';

    String result = input.toLowerCase();
    for (int i = 0; i < vietnameseChars.length; i++) {
      result = result.replaceAll(vietnameseChars[i], noAccentChars[i]);
    }
    return result;
  }
}
