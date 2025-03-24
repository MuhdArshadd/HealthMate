import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import '../../db_connection.dart';

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


Future<String> login(String username, String password) async {
  await dbConnection.connectToDatabase();

  try {
    var result = await dbConnection.connection.query(
      "SELECT password, isgoogle FROM users WHERE email_address = @username OR username = @username",
      substitutionValues: {'username': username},
    );

    if (result.isEmpty) {
      return "Error: User not found.";
    }

    String? storedPassword = result[0][0];
    bool isGoogleUser = result[0][1] == true;

    if (isGoogleUser && storedPassword == null) {
      return "This account uses Google Sign-In. Please sign in with Google.";
    }

    if (storedPassword != null) {
      String enteredHashedPassword = hashPassword(password);
      if (storedPassword == enteredHashedPassword) {
        return "Login Successful";
      } else {
        return "Error: Invalid credentials.";
      }
    } else {
      return "Error: Invalid account type.";
    }
  } catch (e) {
    return "Error: $e";
  }
}


  // Function to hash password
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }


Future<String> handleGoogleSignIn(String displayName, String email, String? photoUrl) async {
  await dbConnection.connectToDatabase();
  
  try {

    var result = await dbConnection.connection.query(
      "SELECT username FROM users WHERE email_address = @email_address",
      substitutionValues: {'email_address': email},
    );
    
    if (result.isEmpty) {

      if (photoUrl != null) {
        try {
          final http.Response response = await http.get(Uri.parse(photoUrl));
          final Uint8List imageBytes = response.bodyBytes;
          final base64Image = base64Encode(imageBytes);
          
          await dbConnection.connection.query(
            '''
            INSERT INTO users (username, email_address, password, image_url, isgoogle) 
            VALUES (@username, @email_address, NULL, decode(@profile_image, 'base64'), TRUE)
            ''',
            substitutionValues: {
              'username': displayName,
              'email_address': email,
              'profile_image': base64Image
            },
          );
        } catch (e) {
          await dbConnection.connection.query(
            '''
            INSERT INTO users (username, email_address, password, isgoogle) 
            VALUES (@username, @email_address, NULL, TRUE)
            ''',
            substitutionValues: {
              'username': displayName,
              'email_address': email,
            },
          );
        }
      } else {
        await dbConnection.connection.query(
          '''
          INSERT INTO users (username, email_address, password, isgoogle) 
          VALUES (@username, @email_address, NULL, TRUE)
          ''',
          substitutionValues: {
            'username': displayName,
            'email_address': email,
          },
        );
      }
      
      return "New user created with Google account";
    } else {
      // For existing users, update the isgoogle flag if needed
      await dbConnection.connection.query(
        "UPDATE users SET isgoogle = TRUE WHERE email_address = @email_address AND (isgoogle IS NULL OR isgoogle = FALSE)",
        substitutionValues: {'email_address': email},
      );
      
      return "Login Successful"; 
    }
  } catch (e) {
    return "Error: $e";
  } finally {
    dbConnection.closeConnection();
  }
}
}

