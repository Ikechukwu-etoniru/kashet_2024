enum TransactionType { credit, debit }

class Transaction {
  final int id;
  final int userId;
  final TransactionType type;
  final String amount;
  final String ktcValue;
  final String paymentType;
  final String description;
  final String status;
  final String currency;
  final num? charges;
  final String createDate;
  final String? updatedDate;

  Transaction(
      {required this.id,
      required this.userId,
      required this.type,
      required this.amount,
      required this.ktcValue,
      required this.paymentType,
      required this.description,
      required this.status,
      required this.currency,
      required this.charges,
      required this.createDate,
      required this.updatedDate,
      });
}
