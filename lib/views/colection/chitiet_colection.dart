import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stonelens/models/CollectionModel.dart';
import 'package:stonelens/models/rock_model.dart';
import 'package:stonelens/views/colection/add_colection.dart';
import 'package:stonelens/views/home/StoneDetailScreen.dart';

class CollectionScreen extends StatefulWidget {
  final String collectionId;
  final RockModel? rock;
  final String? editColection;

  const CollectionScreen(
      {super.key, required this.collectionId, this.rock, this.editColection});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - 10,
      size.width,
      size.height - 20,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _CollectionScreenState extends State<CollectionScreen> {
  int _selectedIndex = 0;
  String tenDa = 'Chưa rõ';
  List<dynamic> hinhAnh = [];
  int order = 0;
  CollectionModel? collection;

  String? location;
  String? time;
  String? note;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    fetchCollectionData();
  }

  Future<void> fetchCollectionData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User chưa đăng nhập');

      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('collections')
          .doc(widget.collectionId)
          .get();

      if (!docSnapshot.exists) {
        throw Exception(
            'Không tìm thấy collection với ID: ${widget.collectionId}');
      }

      final data = docSnapshot.data()!;
      final orderInt = int.tryParse(data['order']?.toString() ?? '0') ?? 0;

      setState(() {
        collection = CollectionModel.fromDoc(docSnapshot.id, data);
        tenDa = collection!.tenDa;
        hinhAnh = collection!.hinhAnh;
        order = orderInt;
        location = collection!.location;
        time = collection!.time;
        note = collection!.note;
      });
    } catch (e) {
      print('⚠️ Lỗi khi lấy dữ liệu collection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Lỗi tải dữ liệu bộ sưu tập')),
      );
    }
  }

  Widget buildCurvedImageWithPattern() {
    if (hinhAnh.isEmpty) {
      return ClipPath(
        clipper: BottomCurveClipper(),
        child: Container(
          width: double.infinity,
          height: 220,
          color: Colors.grey[300],
          alignment: Alignment.center,
          child: const Text('Không có ảnh'),
        ),
      );
    }

    return ClipPath(
      clipper: BottomCurveClipper(),
      child: Stack(
        children: [
          SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: hinhAnh.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final imageUrl = hinhAnh[index];
                return Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () async {
                if (collection?.rockId?.isNotEmpty == true) {
                  print(
                      '🧱 Đã truyền id: ${collection!.rockId}'); // <-- Dòng này đây
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final doc = await FirebaseFirestore.instance
                        .collection('_rocks')
                        .doc(collection!.rockId)
                        .get();

                    Navigator.pop(context);

                    if (doc.exists) {
                      final rockModel = RockModel.fromJson(doc.data()!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CollectionDetailScreen(
                            editCollection: collection!.id,
                            rock: rockModel,
                          ),
                        ),
                      );
                    } else {
                      print(
                          '🚫 Không tìm thấy đá với ID: ${collection!.rockId}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('❌ Không tìm thấy đá')),
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('❌ Lỗi khi tải đá: $e')),
                    );
                  }
                } else {
                  print('⚠️ collection null hoặc rockId rỗng');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('❌ Không có ID đá để hiển thị')),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  'assets/edit.png',
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F3546),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentPage + 1}/${hinhAnh.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index); // Chuyển tab ngay lập tức
        if (index == 1 && collection?.rockId?.isNotEmpty == true) {
          print('rockId được truyền: ${collection!.rockId}'); // Kiểm tra rockId
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          FirebaseFirestore.instance
              .collection('_rocks')
              .doc(collection!.rockId)
              .get()
              .then((doc) {
            Navigator.pop(context); // Đóng loading
            if (doc.exists) {
              final data = doc.data()!;
              print(
                  'Firestore data: $data'); // In dữ liệu Firestore để kiểm tra
              // Gán doc.id vào dữ liệu
              data['id'] = doc.id; // Thêm id từ doc.id
              final rockModel = RockModel.fromJson(data);
              print('RockModel ID: ${rockModel.id}'); // Kiểm tra ID sau khi tạo
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoneDetailScreen(rock: rockModel),
                ),
              ).then((_) {
                setState(() => _selectedIndex = 0);
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('❌ Không tìm thấy đá')),
              );
            }
          }).catchError((e) {
            Navigator.pop(context); // Đóng loading nếu lỗi
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('❌ Lỗi khi tải đá: $e')),
            );
          });
        } else {
          print('rockId không được truyền hoặc rỗng');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ Không có rockId để tải dữ liệu')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFFE87D34) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 20,
            color: isSelected ? const Color(0xFFE87D34) : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget buildInfoSection() {
    if ((location == null || location!.isEmpty) &&
        (time == null || time!.isEmpty) &&
        (note == null || note!.isEmpty)) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Image.asset(
            'assets/rock.png',
            width: 130,
            height: 130,
          ),
          const SizedBox(height: 20),
          const Text(
            'Chỉnh sửa bộ sưu tập của bạn',
            style: TextStyle(
              color: Color(0xFFE87D34),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (location != null && location!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE0B2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 20,
                      color: Color(0xFFE87D34),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vị trí',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          location!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (time != null && time!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFB3E5FC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.access_time,
                      size: 20,
                      color: Color(0xFF0288D1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thời gian thu thập',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          time!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (note != null && note!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC8E6C9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notes,
                      size: 20,
                      color: Color(0xFF388E3C),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ghi chú',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          note!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left_rounded, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTab('Nhãn', 0),
                        const SizedBox(width: 24),
                        _buildTab('Thông tin', 1),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - topPadding - 80,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            buildCurvedImageWithPattern(),
                            const SizedBox(height: 20),
                            Text(
                              tenDa,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'No.$order',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 20),
                            buildInfoSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
