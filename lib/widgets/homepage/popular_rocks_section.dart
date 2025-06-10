import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stonelens/models/rock_model.dart';

class PopularRocksSection extends StatefulWidget {
  @override
  _PopularRocksSectionState createState() => _PopularRocksSectionState();
}

class _PopularRocksSectionState extends State<PopularRocksSection> {
  List<RockModel> uniqueRocks = [];

  @override
  void initState() {
    super.initState();
    fetchRocksData();
  }

  Future<void> fetchRocksData() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('_rocks').get();

    final allRocks = snapshot.docs.map((doc) {
      return RockModel.fromJson(doc.data());
    }).toList();

    // Nhóm đá theo loaiDa và đếm số lượng
    final rockCountByLoaiDa = <String, List<RockModel>>{};
    for (var rock in allRocks) {
      final loai = rock.loaiDa.trim();
      if (!rockCountByLoaiDa.containsKey(loai)) {
        rockCountByLoaiDa[loai] = [];
      }
      rockCountByLoaiDa[loai]!.add(rock);
    }

    // Lọc các loaiDa có số lượng tên đá >= 2 và chọn một đại diện
    final filteredRocks = <RockModel>[];
    rockCountByLoaiDa.forEach((loaiDa, rocks) {
      if (rocks.length >= 2) {
        // Ngưỡng: ít nhất 2 tên đá
        filteredRocks.add(rocks.first); // Chọn đá đầu tiên làm đại diện
      }
    });

    setState(() {
      uniqueRocks = filteredRocks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "Những loại đá phổ biến",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: 8),
        uniqueRocks.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: uniqueRocks.length,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final rock = uniqueRocks[index];
                    final name = rock.loaiDa;
                    final imageUrl = (rock.hinhAnh.isNotEmpty)
                        ? rock.hinhAnh[0]
                        : 'https://via.placeholder.com/85'; // Ảnh mặc định nếu không có

                    return RockCard(
                      name: name,
                      imagePath: imageUrl,
                    );
                  },
                ),
              ),
      ],
    );
  }
}

class RockCard extends StatelessWidget {
  final String name;
  final String imagePath;

  const RockCard({required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, // Giới hạn chiều rộng của RockCard
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(imagePath),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) => AssetImage(
                    'assets/placeholder.png'), // Ảnh thay thế nếu lỗi
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold), // Giảm fontSize
            maxLines: 1, // Giới hạn 1 dòng
            overflow: TextOverflow.ellipsis, // Thêm dấu "..." nếu văn bản dài
            textAlign: TextAlign.center, // Căn giữa văn bản
          ),
        ],
      ),
    );
  }
}
