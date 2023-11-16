class IdModel {
  final int id;
  final int userId;
  final String type;
  final String frontImage;
  final String backImage;
  final String? documentNumber;
  final String status;
  final String? remark;
  IdModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.frontImage,
    required this.backImage,
    required this.documentNumber,
    required this.status,
    this.remark,
  });
}
