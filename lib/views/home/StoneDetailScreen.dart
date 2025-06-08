import 'package:flutter/material.dart';
import 'package:stonelens/ScannerScreen.dart';
import 'package:stonelens/models/rock_model.dart';
import 'package:stonelens/services/favorite_service.dart';
import 'package:stonelens/widgets/stone/Description_widget.dart';
import 'package:stonelens/widgets/stone/FrequentlyAskedQuestions.dart';
import 'package:stonelens/widgets/stone/OtherInformationWidget.dart';
import 'package:stonelens/widgets/stone/StructureAndComposition.dart';
import 'package:stonelens/widgets/stone/basic_characteristics.dart';
import 'package:stonelens/views/colection/add_colection.dart';
import 'package:stonelens/widgets/stone/stone_info_widget.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CollectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<bool> checkRockInUserCollection(String rockId) {
    final userId = _auth.currentUser?.uid;
    print('Checking rockId: $rockId for userId: $userId');

    if (rockId.isEmpty || userId == null) {
      print('Invalid rockId or missing userId, returning false');
      return Stream.value(false);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('collections')
        .where('rock_id', isEqualTo: rockId)
        .snapshots()
        .map((snapshot) {
      final isInCollection = snapshot.docs.isNotEmpty;
      print('Firestore query result: $isInCollection for rockId: $rockId');
      return isInCollection;
    });
  }
}

class StoneDetailScreen extends StatefulWidget {
  final RockModel? rock;
  final String? stoneData;

  const StoneDetailScreen({Key? key, this.rock, this.stoneData})
      : super(key: key);

  @override
  _StoneDetailScreenState createState() => _StoneDetailScreenState();
}

class _StoneDetailScreenState extends State<StoneDetailScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  final CollectionService _collectionService = CollectionService();

  late final RockModel rock;
  late final bool fromAI;

  @override
  void initState() {
    super.initState();
    if (widget.stoneData != null && widget.stoneData!.isNotEmpty) {
      final Map<String, dynamic> parsedJson = jsonDecode(widget.stoneData!);
      rock = RockModel.fromJson(parsedJson);
      fromAI = true;
    } else if (widget.rock != null) {
      rock = widget.rock!;
      fromAI = false;
    } else {
      throw Exception('StoneDetailScreen requires either rock or stoneData');
    }
    print('RockId ${rock.id}'); // Debug log
  }

  void _toggleFavorite(bool currentStatus) async {
    await _favoriteService.toggleFavorite(rock.id, !currentStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ảnh đá với Hero animation
                    Stack(
                      children: [
                        Hero(
                          tag: 'stoneImage',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              rock.hinhAnh.isNotEmpty ? rock.hinhAnh[0] : '',
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              width: 60,
                              height: 40,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF303A53),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Tiêu đề đá & loại đá
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rock.tenDa,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Loại đá: ${rock.loaiDa}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFE57C3B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Nút yêu thích
                        StreamBuilder<bool>(
                          stream: _favoriteService
                              .rockFavoriteStatusStream(rock.id),
                          builder: (context, snapshot) {
                            final isFavorite = snapshot.data ?? false;
                            return IconButton(
                              onPressed: () => _toggleFavorite(isFavorite),
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(
                                        scale: animation, child: child),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  key: ValueKey<bool>(isFavorite),
                                  color: isFavorite ? Colors.red : Colors.grey,
                                  size: 28,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // Các widget hiển thị thông tin đá
                    StoneInfoWidget(
                      rock: rock,
                      stoneData: widget.stoneData,
                      fromAI: fromAI,
                      isFavorite: false,
                      onFavoriteToggle: () {},
                    ),

                    Description(
                        rock: rock,
                        stoneData: widget.stoneData,
                        fromAI: fromAI),
                    BasicCharacteristics(
                        rock: rock,
                        stoneData: widget.stoneData,
                        fromAI: fromAI),
                    StructureAndComposition(
                        rock: rock,
                        stoneData: widget.stoneData,
                        fromAI: fromAI),
                    FrequentlyAskedQuestions(
                        rock: rock,
                        stoneData: widget.stoneData,
                        fromAI: fromAI),
                    OtherInformationWidget(
                        rock: rock,
                        stoneData: widget.stoneData,
                        fromAI: fromAI),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        rock: rock,
        favoriteService: _favoriteService,
        collectionService: _collectionService,
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final RockModel rock;
  final FavoriteService favoriteService;
  final CollectionService collectionService;

  const BottomNavBar({
    Key? key,
    required this.rock,
    required this.favoriteService,
    required this.collectionService,
  }) : super(key: key);

  void _toggleFavorite(BuildContext context, bool currentStatus) {
    favoriteService.toggleFavorite(rock.id, !currentStatus);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: favoriteService.rockFavoriteStatusStream(rock.id),
      builder: (context, favoriteSnapshot) {
        final isFavorite = favoriteSnapshot.data ?? false;
        final width = MediaQuery.of(context).size.width;

        return StreamBuilder<bool>(
          stream: collectionService.checkRockInUserCollection(rock.id),
          builder: (context, collectionSnapshot) {
            final isInCollection = collectionSnapshot.data ?? false;
            print(
                'Rendering BottomNavBar, isInCollection: $isInCollection'); // Debug log

            return Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Camera Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        ScannerScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(0.0, 1.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          child:
                              _buildIconButton(icon: Icons.camera_alt_outlined),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Favorite Button
                      GestureDetector(
                        onTap: () => _toggleFavorite(context, isFavorite),
                        child: _buildIconButton(
                          icon: isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          iconColor: isFavorite ? Colors.red : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  // Button Thêm vào bộ sưu tập hoặc Đã có trong bộ sưu tập
                  SizedBox(
                    width: width * 0.55,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isInCollection
                          ? null // Vô hiệu hóa nếu đã có trong bộ sưu tập
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CollectionDetailScreen(rock: rock),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: isInCollection
                              ? null // Không gradient nếu đã có
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFFFFB547),
                                    Color(0xFFF37736)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                          color: isInCollection
                              ? Colors.grey[300] // Màu xám khi vô hiệu hóa
                              : null,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isInCollection ? Icons.check : Icons.add,
                                color: isInCollection
                                    ? Colors.grey[700]
                                    : Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isInCollection
                                    ? "Đã có trong bộ sưu tập"
                                    : "Thêm vào bộ sưu tập",
                                style: TextStyle(
                                  color: isInCollection
                                      ? Colors.grey[700]
                                      : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    Color iconColor = Colors.black,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}
