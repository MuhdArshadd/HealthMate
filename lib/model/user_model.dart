

class UserModel {
  final String userId;
  final String username;
  final String email;
  final String? imageUrl;
  final bool isGoogleUser;
  final String? message;

  UserModel({
     required this.userId,
    required this.username,
    required this.email,
    this.imageUrl,
    required this.isGoogleUser,
    this.message, 
  });

  factory UserModel.fromDatabase(Map<String, dynamic> data) {
    return UserModel(
      userId: data['users_id'],
      username: data['username'],
      email: data['email_address'],
      imageUrl: data['image_url'],
      isGoogleUser: data['isgoogle'] ?? false,
    );
  }

}


