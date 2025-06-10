import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stonelens/models/rock_model.dart';
import 'package:stonelens/services/favorite_service.dart';

class SearchScreenLogic {
  final BuildContext context;
  final StateSetter setState;
  final VoidCallback onSearchChanged;
  final TextEditingController searchController = TextEditingController();
  List<RockModel> suggestions = [];
  List<Map<String, dynamic>> searchResults = [];
  bool loading = true;
  bool searchLoading = false;
  Timer? _debounce;
  List<RockModel> _allRocks = [];

  SearchScreenLogic({
    required this.context,
    required this.setState,
    required this.onSearchChanged,
  });

  void init() {
    fetchRandomRocks();
    searchController.addListener(_onSearchChanged);
  }

  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _debounce?.cancel();
  }

  Future<void> fetchRandomRocks() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('_rocks').get();
      _allRocks = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        final rock = RockModel.fromJson(data);
        print(
            'Document ID: ${doc.id}, Rock ID: ${rock.id}, Name: ${rock.tenDa}');
        return rock;
      }).toList();

      _allRocks.shuffle();
      final random3 =
          _allRocks.length > 3 ? _allRocks.sublist(0, 3) : _allRocks;

      setState(() {
        suggestions = random3;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print('Lỗi khi tải đá: $e');
    }
  }

  void _onSearchChanged() {
    final query = searchController.text.trim();
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isNotEmpty) {
        searchRocks(query);
      } else {
        setState(() {
          searchResults = [];
          searchLoading = false;
        });
      }
    });
    onSearchChanged();
  }

  String _normalizeText(String? text) {
    if (text == null) return '';
    return text
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAllMapped(RegExp(r'[\u2080-\u2089]'), (Match match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) - 8272);
    });
  }

  Future<void> searchRocks(String query) async {
    setState(() {
      searchLoading = true;
    });

    try {
      final normalizedQuery = _normalizeText(query);
      final results = _allRocks.where((rock) {
        final normalizedTenDa = _normalizeText(rock.tenDa);
        final normalizedLoaiDa = _normalizeText(rock.loaiDa);
        final normalizedThanhPhan = _normalizeText(rock.thanhPhanHoaHoc);

        return normalizedTenDa.contains(normalizedQuery) ||
            normalizedLoaiDa.contains(normalizedQuery) ||
            normalizedThanhPhan.contains(normalizedQuery);
      }).map((rock) {
        final normalizedTenDa = _normalizeText(rock.tenDa);
        final normalizedLoaiDa = _normalizeText(rock.loaiDa);
        final normalizedThanhPhan = _normalizeText(rock.thanhPhanHoaHoc);
        String matchedField = '';
        String matchedValue = '';

        if (normalizedTenDa.contains(normalizedQuery)) {
          matchedField = 'Tên đá';
          matchedValue = rock.tenDa ?? 'Unknown';
        } else if (normalizedLoaiDa.contains(normalizedQuery)) {
          matchedField = 'Loại đá';
          matchedValue = rock.loaiDa ?? 'Unknown';
        } else if (normalizedThanhPhan.contains(normalizedQuery)) {
          matchedField = 'Thành phần hóa học';
          matchedValue = rock.thanhPhanHoaHoc ?? 'Unknown';
        }

        return {
          'rock': rock,
          'matchedField': matchedField,
          'matchedValue': matchedValue,
        };
      }).toList();

      setState(() {
        searchResults = results;
        searchLoading = false;
      });
    } catch (e) {
      print('Lỗi khi tìm kiếm đá: $e');
      setState(() {
        searchLoading = false;
      });
    }
  }
}
