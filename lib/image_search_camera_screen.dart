import 'package:flutter/material.dart';

class ImageSearchCameraScreen extends StatelessWidget {
  const ImageSearchCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.2,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tìm kiếm bằng hình ảnh',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _imageThumb(),
                          const SizedBox(width: 12),
                          _imageThumb(icon: Icons.add_a_photo),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm bằng màu sắc, cấu tạo...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[500],
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          onChanged: (value) {
                            print('Tìm kiếm: $value');
                          },
                        ),
                      ),
                      const SizedBox(height: 5), // Giảm từ 20 xuống 12
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {},
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 4,
                              shadowColor: Colors.black26,
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                        child: Image.asset(
                                          'assets/placeholder.jpg',
                                          width: double.infinity,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Kết quả ${index + 1}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.share,
                                                    size: 14,
                                                    color: Colors.black),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'Thông tin mô tả',
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: 100,
                                    right: 10,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4)
                                        ],
                                      ),
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.favorite_border,
                                          color: Colors.grey,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _imageThumb({IconData? icon}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        height: 64,
        color: Colors.grey[200],
        child: icon != null
            ? Icon(icon, color: Colors.grey[600], size: 24)
            : const Icon(Icons.image, color: Colors.grey, size: 24),
      ),
    );
  }
}
