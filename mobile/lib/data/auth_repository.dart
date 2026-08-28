import '../core/api_client.dart';

class MeOut {
  final String email;
  final String company;

  const MeOut({required this.email, required this.company});

  /// The web nav shows the local part of the email as the display name.
  String get displayName => email.split('@').first;

  factory MeOut.fromJson(Map<String, dynamic> json) {
    return MeOut(
      email: json['email'] as String,
      company: (json['company'] as String?) ?? 'Axia Solutions',
    );
  }
}

class AuthRepository {
  Future<String> login(String email, String password) async {
    final response = await apiClient.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return response.data['access_token'] as String;
  }

  Future<MeOut> fetchMe() async {
    final response = await apiClient.get('/auth/me');
    return MeOut.fromJson(response.data);
  }
}
