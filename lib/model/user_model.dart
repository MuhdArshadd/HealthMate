import 'dart:typed_data';

class UserModel {
  final String userId;
  String username;
  String email;
  Uint8List? imageByte;
  final bool isGoogleUser;
  final String? message;
  String? password;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    this.imageByte,
    required this.isGoogleUser,
    this.message,
    this.password
  });

  factory UserModel.fromDatabase(Map<String, dynamic> data) {
    return UserModel(
      userId: data['users_id'],
      username: data['username'],
      email: data['email_address'],
      imageByte: data['image_byte'] ?? '',
      isGoogleUser: data['isgoogle'] ?? false,
      password: data['password'] ?? ''
    );
  }

}


