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

    // Lọc theo loaiDa duy nhất
    final seenLoaiDa = <String>{};
    final filtered = <RockModel>[];

    for (var rock in allRocks) {
      final loai = rock.loaiDa.trim();
      if (!seenLoaiDa.contains(loai)) {
        seenLoaiDa.add(loai);
        filtered.add(rock);
      }
    }

    setState(() {
      uniqueRocks = filtered;
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
                        : 'Không có ảnh';

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
    return Column(
      children: [
        Container(
          width: 85,
          height: 85,
          margin: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage(imagePath),
              fit: BoxFit.cover,
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
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
