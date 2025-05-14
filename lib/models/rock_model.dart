class RockModel {
  final String id;
  final String tenDa;
  final String mieuTa;
  final String nhomDa;
  final String loaiDa;
  final String dacDiem;
  final String congDung;
  final String kienTruc;
  final String thanhPhanKhoangSan;
  final String thanhPhanHoaHoc;
  final String matDo;
  final String doCung;
  final String cauTao;
  final String motSoKhoangSanLienQuan;
  final String mauSac;
  final String noiPhanBo;
  final List<String> cauHoi;
  final List<String> traLoi;
  final List<String> hinhAnh;

  RockModel({
    required this.id,
    required this.tenDa,
    required this.mieuTa,
    required this.nhomDa,
    required this.loaiDa,
    required this.dacDiem,
    required this.congDung,
    required this.kienTruc,
    required this.thanhPhanKhoangSan,
    required this.thanhPhanHoaHoc,
    required this.matDo,
    required this.doCung,
    required this.cauTao,
    required this.motSoKhoangSanLienQuan,
    required this.mauSac,
    required this.noiPhanBo,
    required this.cauHoi,
    required this.traLoi,
    required this.hinhAnh,
  });

  factory RockModel.fromJson(Map<String, dynamic> json) {
    return RockModel(
      id: json['id'] ?? '',
      tenDa: json['tenDa'] ?? '',
      mieuTa: json['mieuTa'] ?? '',
      nhomDa: json['nhomDa'] ?? '',
      loaiDa: json['loaiDa'] ?? '',
      dacDiem: json['dacDiem'] ?? '',
      congDung: json['congDung'] ?? '',
      kienTruc: json['kienTruc'] ?? '',
      thanhPhanKhoangSan: json['thanhPhanKhoangSan'] ?? '',
      thanhPhanHoaHoc: json['thanhPhanHoaHoc'] ?? '',
      matDo: json['matDo'] ?? '',
      doCung: json['doCung'] ?? '',
      cauTao: json['cauTao'] ?? '',
      motSoKhoangSanLienQuan: json['motSoKhoangSanLienQuan'] ?? '',
      mauSac: json['mauSac'] ?? '',
      noiPhanBo: json['noiPhanBo'] ?? '',
      cauHoi: List<String>.from(json['cauHoi'] ?? []),
      traLoi: List<String>.from(json['traLoi'] ?? []),
      hinhAnh: List<String>.from(json['hinhAnh'] ?? []),
    );
  }
}
