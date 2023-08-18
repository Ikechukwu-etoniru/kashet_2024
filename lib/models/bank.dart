class Bank {
  final int id;
  final String name;
  final String code;
  final String country;

  Bank(
      {required this.code,
      required this.country,
      required this.id,
      required this.name});
}

class UserBank {
  final int? id;
  final String? acctName;
  final String? acctNumber;
  final String? bankName;
  final String? bankCode;

  UserBank({
    required this.id,
    required this.acctName,
    required this.acctNumber,
    required this.bankCode,
    required this.bankName
  });
}
