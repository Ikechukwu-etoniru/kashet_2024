class MoneyRequest {
  final String id;
  final String type;
  final String status;
  final String name;
  final String amount;
  final String ktcValue;
  final String currency;
  final String description;
  final String createdAt;
  final String updatedAt;

  MoneyRequest(
      {required this.id,
      required this.status,
      required this.type,
      required this.name,
      required this.amount,
      required this.ktcValue,
      required this.currency,
      required this.description,
      required this.createdAt,
      required this.updatedAt});
}
