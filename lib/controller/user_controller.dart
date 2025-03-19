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
    String email,
    String password,
    String confirmPassword,
    Uint8List? profileImage) async {
  await dbConnection.connectToDatabase();

  try {
    // Check if email or username already exists
    var existingUser = await dbConnection.connection.query(
      "SELECT email, username FROM users WHERE email = @email OR username = @username",
      substitutionValues: {'email': email, 'username': fullName},
    );

    if (existingUser.isNotEmpty) {
      for (var row in existingUser) {
        if (row[0] == email) {
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

      await dbConnection.connection.query(
        '''
        INSERT INTO users (user_ic, username, email, password, image_url) 
        VALUES (@user_ic, @username, @email, @password, decode(@profile_image, 'base64'))
        ''',
        substitutionValues: {
          'user_ic': noIc,
          'username': fullName,
          'email': email,
          'password': hashedPassword,
          'profile_image': base64Image
        },
      );
    } else {
      await dbConnection.connection.query(
        '''
        INSERT INTO users (user_ic, username, email, password, image_url) 
        VALUES (@user_ic, @username, @email, @password, NULL)
        ''',
        substitutionValues: {
          'user_ic': noIc,
          'username': fullName,
          'email': email,
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
      "SELECT password, isgoogle FROM users WHERE email = @username OR username = @username",
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
      "SELECT username FROM users WHERE email = @email",
      substitutionValues: {'email': email},
    );
    
    if (result.isEmpty) {

      if (photoUrl != null) {
        try {
          final http.Response response = await http.get(Uri.parse(photoUrl));
          final Uint8List imageBytes = response.bodyBytes;
          final base64Image = base64Encode(imageBytes);
          
          await dbConnection.connection.query(
            '''
            INSERT INTO users (user_ic, username, email, password, image_url, isgoogle) 
            VALUES (NULL, @username, @email, NULL, decode(@profile_image, 'base64'), TRUE)
            ''',
            substitutionValues: {
              'username': displayName,
              'email': email,
              'profile_image': base64Image
            },
          );
        } catch (e) {
          await dbConnection.connection.query(
            '''
            INSERT INTO users (user_ic, username, email, password, isgoogle) 
            VALUES (NULL, @username, @email, NULL, TRUE)
            ''',
            substitutionValues: {
              'username': displayName,
              'email': email,
            },
          );
        }
      } else {
        await dbConnection.connection.query(
          '''
          INSERT INTO users (user_ic, username, email, password, isgoogle) 
          VALUES (NULL, @username, @email, NULL, TRUE)
          ''',
          substitutionValues: {
            'username': displayName,
            'email': email,
          },
        );
      }
      
      return "New user created with Google account";
    } else {
      // For existing users, update the isgoogle flag if needed
      await dbConnection.connection.query(
        "UPDATE users SET isgoogle = TRUE WHERE email = @email AND (isgoogle IS NULL OR isgoogle = FALSE)",
        substitutionValues: {'email': email},
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

