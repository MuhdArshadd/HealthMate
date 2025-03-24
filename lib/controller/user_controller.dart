import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../../db_connection.dart';
import "../model/user_model.dart";

class UserController {
  final DatabaseConnection dbConnection = DatabaseConnection();

  Future<String> signUp(
      String? noIc,
      String fullName,
      String email_address,
      String password,
      String confirmPassword,
      Uint8List? profileImage) async {

    try {
      await dbConnection.connectToDatabase();

      // Check if email or username already exists
      var existingUser = await dbConnection.connection.query(
        'SELECT "email_address", "username" FROM users WHERE "email_address" = @email_address OR "username" = @username',
        substitutionValues: {'email_address': email_address, 'username': fullName},
      );

      if (existingUser.isNotEmpty) {
        for (var row in existingUser) {
          if (row[0] == email_address) {
            return "Error: Email already exists.";
          }
          if (row[1] == fullName) {
            return "Error: Username already exists.";
          }
        }
      }

      if (password != confirmPassword) {
        return "Error: Passwords do not match.";
      }

      String hashedPassword = hashPassword(password);

      if (profileImage != null) {
        final base64Image = base64Encode(profileImage);

        print("DEBUG: Preparing to insert user into database (with image)...");
        await dbConnection.connection.query(
          '''
        INSERT INTO users ("username", "email_address", "password", "image_url") 
        VALUES (@username, @email_address, @password, decode(@profile_image, 'base64'))
        ''',
          substitutionValues: {
            'username': fullName,
            'email_address': email_address,
            'password': hashedPassword,
            'profile_image': base64Image
          },
        );
      } else {
        await dbConnection.connection.query(
          '''
        INSERT INTO users ("username", "email_address", "password", "image_url") 
        VALUES (@username, @email_address, @password, NULL)
        ''',
          substitutionValues: {
            'username': fullName,
            'email_address': email_address,
            'password': hashedPassword,
          },
        );
      }


      return "Sign up successful";

    } catch (e) {
      return "Error signing up: $e";
    } finally {
      dbConnection.closeConnection();
    }
  }



  Future<UserModel?> login(String username, String password) async {
    await dbConnection.connectToDatabase();

    try {
      var result = await dbConnection.connection.query(
        "SELECT users_id, username, email_address, image_url, password, isgoogle FROM users WHERE email_address = @username OR username = @username",
        substitutionValues: {'username': username},
      );

      if (result.isEmpty) {
        print("Login Failed: No user found with username/email: $username");
        return null;
      }

      var row = result.first;
      String userId = row[0];
      String fetchedUsername = row[1];
      String email = row[2];
      String? imageUrl = row[3];
      String storedPassword = row[4] ?? '';
      bool isGoogleUser = row[5] == true;

      if (isGoogleUser && storedPassword.isEmpty) {
        print("Login Failed: Google user detected, but no password stored.");
        return null;
      }

      if (hashPassword(password) == storedPassword) {
        UserModel user = UserModel(
          userId: userId,
          username: fetchedUsername,
          email: email,
          imageUrl: imageUrl,
          isGoogleUser: isGoogleUser,
          message: "Login Successful",
        );

        print("UserModel Data Saved: "
            "User ID: ${user.userId}, "
            "Username: ${user.username}, "
            "Email: ${user.email}, "
            "Image URL: ${user.imageUrl}, "
            "Google User: ${user.isGoogleUser}, "
            "Message: ${user.message}");

        return user;
      } else {
        print("Login Failed: Incorrect password.");
        return null;
      }
    } catch (e) {
      print("Login Error: $e");
      return null;
    } finally {
      dbConnection.closeConnection();
    }
  }


  // Function to hash password
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }


  Future<UserModel?> handleGoogleSignIn(String displayName, String email, String? photoUrl) async {
    await dbConnection.connectToDatabase();

    try {
      var result = await dbConnection.connection.query(
        "SELECT users_id, username, email_address, image_url FROM users WHERE email_address = @email_address",
        substitutionValues: {'email_address': email},
      );

      String? imageUrl;

      if (result.isEmpty) {
        print("🔄 New Google user detected, creating account for $displayName.");

        if (photoUrl != null) {
          final http.Response response = await http.get(Uri.parse(photoUrl));
          final Uint8List imageBytes = response.bodyBytes;
          imageUrl = base64Encode(imageBytes);
        }

        await dbConnection.connection.query(
          '''
        INSERT INTO users (username, email_address, image_url, isgoogle) 
        VALUES (@username, @email_address, @image_url, true)
        ''',
          substitutionValues: {
            'username': displayName,
            'email_address': email,
            'image_url': imageUrl,
          },
        );

        print("New Google user saved: $displayName ($email)");
      }

      var userData = await dbConnection.connection.query(
        "SELECT users_id, username, email_address, image_url FROM users WHERE email_address = @email_address",
        substitutionValues: {'email_address': email},
      );

      var row = userData.first;

      UserModel user = UserModel(
        userId: row[0],
        username: row[0],
        email: row[1],
        imageUrl: row[2],
        isGoogleUser: true,
      );

      print("Google Sign-In UserModel Data: User ID: ${user.userId}, Username: ${user.username}");

      return user;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    } finally {
      dbConnection.closeConnection();
    }
  }

}