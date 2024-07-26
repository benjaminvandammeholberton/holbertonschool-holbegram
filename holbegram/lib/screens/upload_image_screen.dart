import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:holbegram/methods/auth_methods.dart';
import 'package:holbegram/screens/home.dart';


class AddPicture extends StatefulWidget {
  final String email;
  final String password;
  final String username;

  const AddPicture({
    super.key,
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  AddPictureState createState() => AddPictureState();
}


class AddPictureState extends State<AddPicture> {
  Uint8List? _image;
  bool _isLoading = false;

  
  void selectImageFromGallery() async {
    Uint8List image = await pickImage(ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  
  void selectImageFromCamera() async {
    Uint8List image = await pickImage(ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  
  Future<Uint8List> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: source);
    if (file != null) {
      return await file.readAsBytes();
    } else {
      throw 'No image selected';
    }
  }

  
  Future<void> uploadImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      
      String res = await AuthMethods().signUpUser(
        email: widget.email,
        username: widget.username,
        password: widget.password,
        file: _image,
      );

      
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      
      if (res == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up successful')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res)),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign up: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
              child: Column(
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.04),

                  
                  Text(
                    'Holbegram',
                    style: TextStyle(
                      fontFamily: 'Billabong',
                      fontSize: screenHeight * 0.08,
                    ),
                  ),
                  Image.asset(
                    'assets/images/logo.png',
                    width: screenWidth * 0.2,
                    height: screenHeight * 0.08,
                  ),
                  SizedBox(height: screenHeight * 0.05),

                   
                  Text(
                    'Hello, ${widget.username} Welcome to Holbegram.',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: screenHeight * 0.024,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Choose an image from your gallery or take a new one.',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: screenHeight * 0.018,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),

                  
                  _image != null
                      ? CircleAvatar(
                          radius: screenWidth * 0.22,
                          backgroundImage: MemoryImage(_image!),
                        )
                      : CircleAvatar(
                          radius: screenWidth * 0.22,
                          backgroundColor: Colors.white,
                          backgroundImage: const AssetImage('assets/images/user_placeholder.png'),
                        ),
                  SizedBox(height: screenHeight * 0.02),

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.photo_library_outlined, color: Colors.red),
                        iconSize: screenWidth * 0.09,
                        onPressed: selectImageFromGallery,
                      ),
                      SizedBox(width: screenWidth * 0.25),
                      IconButton(
                        icon: const Icon(Icons.camera_alt_outlined, color: Colors.red),
                        iconSize: screenWidth * 0.09,
                        onPressed: selectImageFromCamera,
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(218, 226, 37, 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2, vertical: screenHeight * 0.02),
                          ),
                          onPressed: uploadImage,
                          child: Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenHeight * 0.020,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
