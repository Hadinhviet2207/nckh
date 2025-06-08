import 'dart:convert';

class CollectionModel {
  final String id; // document ID trong subcollection
  final List<String> hinhAnh;
  final String location;
  final String note;
  final String order;
  final String rockId;
  final String tenDa;
  final String time;
  final String userId;

  CollectionModel({
    required this.id,
    required this.userId,
    required this.hinhAnh,
    required this.location,
    required this.note,
    required this.order,
    required this.rockId,
    required this.tenDa,
    required this.time,
  });

  /// Tạo từ Firestore map + doc ID
  factory CollectionModel.fromDoc(String id, Map<String, dynamic> map) {
    return CollectionModel(
      id: id,
      userId: map['userId'] ?? '',
      hinhAnh: List<String>.from(map['hinhAnh'] ?? []),
      location: map['location'] ?? '',
      note: map['note'] ?? '',
      order: map['order'] ?? '',
      rockId: map['rock_id'] ?? '',
      tenDa: map['tenDa'] ?? '',
      time: map['time'] ?? '',
    );
  }

  /// Tạo từ JSON string
  factory CollectionModel.fromJson(String source) =>
      CollectionModel.fromMap(json.decode(source));

  /// Convert từ Map (không cần ID)
  factory CollectionModel.fromMap(Map<String, dynamic> map) {
    return CollectionModel(
      userId: map['userId'] ?? '',
      id: map['id'] ?? '',
      hinhAnh: List<String>.from(map['hinhAnh'] ?? []),
      location: map['location'] ?? '',
      note: map['note'] ?? '',
      order: map['order'] ?? '',
      rockId: map['rock_id'] ?? '',
      tenDa: map['tenDa'] ?? '',
      time: map['time'] ?? '',
    );
  }

  /// Convert thành Map (dùng để lưu Firestore hoặc encode JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hinhAnh': hinhAnh,
      'location': location,
      'note': note,
      'order': order,
      'rock_id': rockId,
      'tenDa': tenDa,
      'time': time,
    };
  }

  /// Convert thành JSON string
  String toJson() => json.encode(toMap());
}
