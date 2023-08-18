class UserCard {
  final int cardNumber;
  final DateTime expiryDate;
  final int cvv;
  final int cardPin;
  final String cardImageUrl;
  final String bankName;
  final String id;

  UserCard(
      {required this.cardNumber,
      required this.cardPin,
      required this.cvv,
      required this.expiryDate,
      required this.cardImageUrl,
      required this.bankName,
      required this.id});
}
