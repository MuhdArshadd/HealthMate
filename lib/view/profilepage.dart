import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:healthmate/controller/user_controller.dart';
import 'package:healthmate/model/user_model.dart';
import 'custom_app_bar.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;

  const ProfilePage({super.key, required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String username;
  late String password;
  late String email;
  Uint8List? imageBytes;
  bool _isPasswordVisible = false;

  final UserController userController = UserController();

  @override
  void initState() {
    super.initState();
    username = widget.user.username;
    password = widget.user.password ?? ""; // Handle null case
    email = widget.user.email;
    if (widget.user.imageByte != null){
      imageBytes = widget.user.imageByte;
    }
  }

  // Pick image from the file system
  Future<Uint8List?> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        final File file = File(filePath);
        final Uint8List imagebytes = await file.readAsBytes();
        setState(() {
          imageBytes = imagebytes;
        });
        return imageBytes;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: widget.user.imageByte != null
                        ? MemoryImage(imageBytes!) // Display profile picture if available
                        : null,

                    child: widget.user.imageByte == null
                        ? const Icon(Icons.person, size: 30, color: Colors.white) // Default icon
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () async {
                        Uint8List? pickedImage = await _pickImage(); // Call image picker function

                        if (imageBytes != null) {
                          await userController.profileUpdate(1, widget.user.userId, null, pickedImage); // Call function to update image
                          widget.user.imageByte = imageBytes;
                        }
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 15,
                        child: Icon(Icons.edit, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              buildEditableField("Username", username, Icons.edit, (newValue) {
                setState(() {
                  username = newValue;
                });
              }),
              const SizedBox(height: 20),
              buildEditableField("Email", email, Icons.edit, (newValue) {
                setState(() {
                  email = newValue;
                });
              }),
              const SizedBox(height: 20),

              // Display password field only if the user is NOT a Google account user
              if (!widget.user.isGoogleUser) buildPasswordField("Password", password),

              const SizedBox(height: 50),

              // Sign out button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: const Offset(2, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    print("Sign Out clicked");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget buildEditableField(String label, String value, IconData icon, Function(String) onSave) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                spreadRadius: 2,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
              GestureDetector(
                onTap: () => _showEditDialog(label, value, onSave),
                child: Icon(icon, color: Colors.blueGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPasswordField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                spreadRadius: 2,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isPasswordVisible ? value : '*******',
                style: const TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    child: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showEditDialog("Password", value, (newValue) {
                      setState(() {
                        password = newValue;
                      });
                    }),
                    child: const Icon(Icons.edit, color: Colors.blueGrey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditDialog(String field, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $field"),
          content: TextField(
            controller: controller,
            obscureText: field == "Password",
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter new $field",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newValue = controller.text.trim();

                if (newValue.isNotEmpty) {
                  onSave(newValue); // Update UI state immediately

                  // Determine which option to call based on field name
                  int option;
                  if (field == "Username") {
                    option = 2;
                  } else if (field == "Email") {
                    option = 3;
                  } else if (field == "Password") {
                    option = 4;
                  } else {
                    return;
                  }

                  // Call profileUpdate function to update database
                  await userController.profileUpdate(option, widget.user.userId, newValue, null);

                  // Update UI and user model
                  setState(() {
                    onSave(newValue); // Update UI
                    if (field == "Username") {
                      widget.user.username = newValue;
                    } else if (field == "Email") {
                      widget.user.email = newValue;
                    } else if (field == "Password") {
                      widget.user.password = newValue;
                    }
                  });

                }

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

}
