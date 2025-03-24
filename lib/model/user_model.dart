class User {
  final int id;
  final String emailAddress;
  final String username;
  final String password;

  User({
    required this.id,
    required this.emailAddress,
    required this.username,
    required this.password,
  });

  // Convert a User object to a Map (for JSON encoding)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email_address': emailAddress,
      'username': username,
      'password': password,
    };
  }

  // Create a User object from a Map (for JSON decoding)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      emailAddress: json['email_address'],
      username: json['username'],
      password: json['password'],
    );
  }
}
