import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import '../../db_connection.dart';
import "../model/user_model.dart";
import 'dart:math';

class UserController {
  final DatabaseConnection dbConnection = DatabaseConnection();

  //Sign Up Manually (not via google account)
  Future<String> signUp(String username, String email_address, String password, String confirmPassword, Uint8List? profileImage) async {
    try {
      await dbConnection.connectToDatabase();

      // Check if email or username already exists
      var existingUser = await dbConnection.connection.query(
        'SELECT "email_address", "username" FROM users WHERE "email_address" = @email_address OR "username" = @username',
        substitutionValues: {
          'email_address': email_address,
          'username': username
        },
      );

      if (existingUser.isNotEmpty) {
        for (var row in existingUser) {
          if (row[0] == email_address) {
            return "Error: Email already exists.";
          }
          if (row[1] == username) {
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
        INSERT INTO users ("username", "email_address", "password", "image_byte") 
        VALUES (@username, @email_address, @password, decode(@profile_image, 'base64'))
        ''',
          substitutionValues: {
            'username': username,
            'email_address': email_address,
            'password': hashedPassword,
            'profile_image': base64Image
          },
        );
      } else {
        await dbConnection.connection.query(
          '''
        INSERT INTO users ("username", "email_address", "password", "image_byte") 
        VALUES (@username, @email_address, @password, NULL)
        ''',
          substitutionValues: {
            'username': username,
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

  //Login Manually (not via google account)
  Future<UserModel?> login(String username, String password) async {
    await dbConnection.connectToDatabase();

    try {
    // if (dbConnection.connection == null || dbConnection.connection.isClosed) {
    //   print("Reconnecting to database...");
    //   await dbConnection.connectToDatabase();
    // }
      var result = await dbConnection.connection.query(
        "SELECT users_id, username, email_address, image_byte, password, isgoogle FROM users WHERE email_address = @username OR username = @username",
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
      Uint8List? imageByte = row[3];
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
          imageByte: imageByte,
          isGoogleUser: isGoogleUser,
          message: "Login Successful",
          password: password
        );

        print("UserModel Data Saved: "
            "User ID: ${user.userId}, "
            "Username: ${user.username}, "
            "Email: ${user.email}, "
            "Image Byte: ${user.imageByte}, "
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

//Using google account to sign up and sign in
  Future<UserModel?> handleGoogleSignIn(String displayName, String email) async {
    await dbConnection.connectToDatabase();

    try {
      var result = await dbConnection.connection.query(
        "SELECT users_id, username, email_address, image_byte FROM users WHERE email_address = @email_address",
        substitutionValues: {'email_address': email},
      );


      if (result.isEmpty) {
        print("🔄 New Google user detected, creating account for $displayName.");

        await dbConnection.connection.query(
          '''
        INSERT INTO users (username, email_address, image_byte, isgoogle) 
        VALUES (@username, @email_address, @image_byte, true)
        ''',
          substitutionValues: {
            'username': displayName,
            'email_address': email,
            'image': null, // first timer
          },
        );

        print("New Google user saved: $displayName ($email)");
      }

      //If already register , just sign in directly
      var userData = await dbConnection.connection.query(
        "SELECT users_id, username, email_address, image_byte FROM users WHERE email_address = @email_address",
        substitutionValues: {'email_address': email},
      );

      var row = userData.first;

      UserModel user = UserModel(
        userId: row[0],
        username: row[1],
        email: row[2],
        imageByte: row[3],
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

  Future<void> profileUpdate(int option, String userID, String? information, Uint8List? image) async {
    try {
      await dbConnection.connectToDatabase(); // Ensure database connection

      switch (option) {
        case 1: // Update profile picture
          if (image != null) {

            final base64Image = base64Encode(image);

            await dbConnection.connection.query(
              "UPDATE users SET image_byte = decode(@image, 'base64') WHERE users_id = @userid",
              substitutionValues: {
                'image': base64Image,
                'userid': userID,
              },
            );
            print("Profile picture updated successfully!");
          } else {
            print("No image selected.");
          }
          break;

        case 2: // Update username
          if (information != null && information.isNotEmpty) {
            await dbConnection.connection.query(
              "UPDATE users SET username = @username WHERE users_id = @userid",
              substitutionValues: {
                'username': information,
                'userid': userID,
              },
            );
            print("Username updated successfully!");
          } else {
            print("Invalid username input.");
          }
          break;

        case 3: // Update email
          if (information != null && information.isNotEmpty) {
            await dbConnection.connection.query(
              "UPDATE users SET email_address = @newEmail WHERE users_id = @userid",
              substitutionValues: {
                'newEmail': information,
                'userid': userID,
              },
            );
            print("Email updated successfully!");
          } else {
            print("Invalid email input.");
          }
          break;

        case 4: // Update password
          if (information != null && information.isNotEmpty) {

            String hashedPassword = hashPassword(information);

            await dbConnection.connection.query(
              "UPDATE users SET password = @password WHERE users_id = @userid",
              substitutionValues: {
                'password': hashedPassword,
                'userid': userID,
              },
            );
            print("Password updated successfully! Before hashed: $information");
          } else {
            print("Invalid password input.");
          }
          break;

        default:
          print("Invalid option.");
          break;
      }
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  // Function to hash password
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

}
