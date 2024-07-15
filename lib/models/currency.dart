class CurrencyK {
  final String name;
  final double rate;
  final String code;

  CurrencyK({required this.name, required this.rate, required this.code});

  factory CurrencyK.fromJson(Map<String, dynamic> json) {
    return CurrencyK(
      name: json['name'],
      rate: json['rate'],
      code: json['code'],
    );
  }

  @override
  String toString() {
    return 'CurrencyK{name: $name, rate: $rate, code: $code}';
  }
}
