import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stonelens/models/rock_model.dart';
import 'package:stonelens/services/user_service.dart';

class AddCollectionService {
  final String? userId = UserService().getUserId();
  final ImagePicker _picker = ImagePicker();

  Future<void> loadCollectionData(
    String? editCollection,
    void Function(Map<String, dynamic>) onDataLoaded,
  ) async {
    if (userId == null || editCollection == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('collections')
        .doc(editCollection)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      onDataLoaded({
        'order': data['order']?.toString() ?? '',
        'tenDa': data['tenDa']?.toString() ?? '',
        'time': data['time']?.toString() ?? '',
        'location': data['location']?.toString() ?? '',
        'note': data['note']?.toString() ?? '',
        'hinhAnh': data['hinhAnh'] ?? [],
      });
    } else {
      onDataLoaded({
        'order': '',
        'tenDa': '',
        'time': '',
        'location': '',
        'note': '',
        'hinhAnh': [],
      });
    }
  }

  Future<void> initOrderField(void Function(String) onOrderSet) async {
    if (userId == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('collections')
        .get();
    onOrderSet((snapshot.docs.length + 1).toString());
  }

  Future<void> pickImages(List<XFile> selectedImages) async {
    final images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      selectedImages.addAll(images);
    }
  }

  Future<List<String>> uploadImagesToFirebase(
      List<XFile> selectedImages) async {
    List<String> downloadUrls = [];
    for (final image in selectedImages) {
      final ref = FirebaseStorage.instance.ref().child(
            'collection_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}',
          );
      final uploadTask = ref.putFile(File(image.path));
      await uploadTask;
      final url = await ref.getDownloadURL();
      downloadUrls.add(url);
    }
    return downloadUrls;
  }

  Future<void> saveCollection({
    required RockModel? rock,
    required String? editCollection,
    required String name,
    required String order,
    required String time,
    required String location,
    required String note,
    required String? firstOriginalImage,
    required List<XFile> selectedImages,
    required Function(String, bool, {String? newDocId}) onResult,
  }) async {
    if (userId == null) {
      onResult("Không tìm thấy người dùng", false);
      return;
    }

    try {
      final trimmedName = name.trim();
      final trimmedOrder = order.trim().isEmpty
          ? (await _getDefaultOrderNumber()).toString()
          : order.trim();

      final newImageUrls = await uploadImagesToFirebase(selectedImages);
      final allImages = [
        if (firstOriginalImage != null) firstOriginalImage,
        ...newImageUrls,
      ];

      final userCollectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('collections');

      if (editCollection != null) {
        final docSnapshot = await userCollectionRef.doc(editCollection).get();
        if (!docSnapshot.exists) {
          onResult("Không tìm thấy bộ sưu tập để cập nhật.", false);
          return;
        }

        final existing = await userCollectionRef
            .where('tenDa', isEqualTo: trimmedName)
            .where(FieldPath.documentId, isNotEqualTo: editCollection)
            .get();
        if (existing.docs.isNotEmpty) {
          onResult("Tên đá này đã tồn tại!", false);
          return;
        }

        final dataToUpdate = {
          'order': trimmedOrder,
          'tenDa': trimmedName,
          'time': time.trim(),
          'location': location.trim(),
          'note': note.trim(),
          'hinhAnh': allImages,
        };

        await userCollectionRef
            .doc(editCollection)
            .set(dataToUpdate, SetOptions(merge: true));

        onResult("Cập nhật bộ sưu tập thành công!", true,
            newDocId: editCollection);
      } else {
        final existing = await userCollectionRef
            .where('tenDa', isEqualTo: trimmedName)
            .get();
        if (existing.docs.isNotEmpty) {
          onResult("Tên đá này đã tồn tại!", false);
          return;
        }

        final dataToAdd = {
          'rock_id': rock?.id,
          'order': trimmedOrder,
          'tenDa': trimmedName,
          'time': time.trim(),
          'location': location.trim(),
          'note': note.trim(),
          'hinhAnh': allImages,
        };

        final docRef = await userCollectionRef.add(dataToAdd);

        onResult("Thêm vào bộ sưu tập thành công!", true, newDocId: docRef.id);
      }
    } catch (e) {
      onResult("Lỗi khi lưu: $e", false);
    }
  }

  Future<int> _getDefaultOrderNumber() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('collections')
        .get();
    return snapshot.docs.length + 1;
  }
}
