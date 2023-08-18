class ResponseModel {
  final bool status;
  final String message;

  ResponseModel({
    required this.message,
    required this.status,
  });
}

class LoginResponseModel {
  final bool status;
  final String message;
  final bool? authFailed;

  LoginResponseModel({
    required this.message,
    required this.status,
    this.authFailed,
  });
}
