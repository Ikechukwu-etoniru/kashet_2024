class User {
  final String firstName;
  final String lastName;
  final String emailAddress;
  final String phoneNumber;
  final String id;
  final String? password;
  final String? imageUrl;
  final String? dob;
  final String? city;
  final String? gender;
  final String? address;
  final String? state;
  final String? country;
  final String? countryInitial;
  final String? isEmailVerified;
  final String? isNumberVerified;
  final String? isBvnVerified;
  final String? userCurrency;

  User(
      {required this.firstName,
      required this.lastName,
      required this.emailAddress,
      required this.phoneNumber,
      required this.id,
      this.city,
      this.userCurrency,
      this.password,
      this.imageUrl,
      this.dob,
      this.gender,
      this.address,
      this.country,
      this.state,
      this.isBvnVerified,
      this.isEmailVerified,
      this.isNumberVerified,
      this.countryInitial});
}

class UserLogin {
  final String emailAddress;
  final String password;

  UserLogin({required this.emailAddress, required this.password});
}

class SendUserDetails {
  final String email;
  final String name;
  final String amount;
  final String ktcValue;
  final String currency;
  final String user;
  final String charges;

  SendUserDetails(
      {required this.amount,
      required this.currency,
      required this.email,
      required this.ktcValue,
      required this.name,
      required this.user,
      required this.charges});
}
