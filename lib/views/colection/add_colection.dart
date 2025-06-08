import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stonelens/models/rock_model.dart';
import 'package:stonelens/services/add_collection_service.dart';
import 'package:stonelens/viewmodels/collection_detail_view.dart';
import 'package:stonelens/views/home/RockImageDialog_result.dart';

class CollectionDetailScreen extends StatefulWidget {
  final RockModel? rock;
  final String? stoneData;
  final String? editCollection;

  const CollectionDetailScreen({
    super.key,
    this.rock,
    this.stoneData,
    this.editCollection,
  });

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  final _orderController = TextEditingController();
  final _nameController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();

  final List<XFile> _selectedImages = [];
  final AddCollectionService _service = AddCollectionService();

  String? _firstOriginalImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.editCollection != null) {
      // Chế độ chỉnh sửa
      _loadExistingCollectionData();
    } else {
      // Chế độ thêm mới
      _initializeNewCollectionData();
    }
  }

  void _loadExistingCollectionData() {
    _service.loadCollectionData(widget.editCollection!, (data) {
      if (!mounted) return;
      setState(() {
        _orderController.text = data['order'] ?? '';
        _nameController.text = data['tenDa'] ?? '';
        _timeController.text = data['time'] ?? '';
        _locationController.text = data['location'] ?? '';
        _noteController.text = data['note'] ?? '';

        final images = data['hinhAnh'] as List?;
        if (images != null && images.isNotEmpty) {
          _firstOriginalImage = images.first;
        }
      });
    });
  }

  void _initializeNewCollectionData() {
    _nameController.text = widget.rock?.tenDa ?? '';

    final now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final formatted =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} - "
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    _timeController.text = formatted;

    _service.initOrderField((order) {
      if (mounted) {
        setState(() => _orderController.text = order);
      }
    });

    if (widget.rock?.hinhAnh != null && widget.rock!.hinhAnh!.isNotEmpty) {
      _firstOriginalImage = widget.rock!.hinhAnh!.first;
    }
  }

  void _saveCollection() {
    if (_nameController.text.trim().isEmpty) {
      _showSnackbar("Vui lòng nhập tên đá", Icons.error_outline, Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    _service.saveCollection(
      rock: widget.rock,
      editCollection: widget.editCollection,
      name: _nameController.text.trim(),
      order: _orderController.text.trim(),
      time: _timeController.text.trim(),
      location: _locationController.text.trim(),
      note: _noteController.text.trim(),
      firstOriginalImage: _firstOriginalImage,
      selectedImages: _selectedImages,
      onResult: (message, success, {String? newDocId}) {
        Navigator.pop(context);
        _showSnackbar(
          message,
          success ? Icons.check_circle : Icons.error_outline,
          success ? Colors.green : Colors.red,
        );
        if (success && mounted) {
          Navigator.pop(context);
        }
        setState(() => _isLoading = false);
      },
    );
  }

  void _showSnackbar(String message, IconData icon, Color color) {
    showCustomSnackbar(
      context: context,
      message: message,
      icon: icon,
      backgroundColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AddCollectionView.buildScaffold(
      context: context,
      header: AddCollectionView.buildHeader(
        title: widget.editCollection != null
            ? 'Chỉnh sửa bộ sưu tập'
            : 'Bộ sưu tập chi tiết',
        onClose: () => Navigator.pop(context),
      ),
      formFields: [
        AddCollectionView.buildLabel("Thứ tự"),
        AddCollectionView.buildTextField(
          controller: _orderController,
          hintText: "Nhập thứ tự...",
        ),
        const SizedBox(height: 16),
        AddCollectionView.buildLabel("Tên đá"),
        AddCollectionView.buildTextField(
          controller: _nameController,
          hintText: "Nhập tên đá...",
        ),
        const SizedBox(height: 16),
        AddCollectionView.buildLabel("Hình ảnh"),
        AddCollectionView.buildImagePicker(
          firstOriginalImage: _firstOriginalImage,
          selectedImages: _selectedImages,
          onPickImages: () async {
            await _service.pickImages(_selectedImages);
            if (mounted) setState(() {});
          },
          onRemoveSelectedImage: (index) {
            setState(() => _selectedImages.removeAt(index));
          },
          onRemoveOriginalImage: () {
            setState(() => _firstOriginalImage = null);
          },
        ),
        const SizedBox(height: 16),
        AddCollectionView.buildLabel("Thời gian"),
        AddCollectionView.buildTextField(
          controller: _timeController,
          hintText: "Nhập thời gian...",
        ),
        const SizedBox(height: 16),
        AddCollectionView.buildLabel("Địa điểm"),
        AddCollectionView.buildTextField(
          controller: _locationController,
          hintText: "Nhập địa điểm...",
        ),
        const SizedBox(height: 16),
        AddCollectionView.buildLabel("Ghi chú"),
        AddCollectionView.buildNoteField(controller: _noteController),
        const SizedBox(height: 32),
      ],
      bottomBar: AddCollectionView.buildBottomBar(
        onSave: _saveCollection,
        buttonText: widget.editCollection != null ? "CẬP NHẬT" : "LƯU",
      ),
    );
  }
}
