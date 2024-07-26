import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:holbegram/models/user.dart';
import 'package:holbegram/screens/auth/methods/user_storage.dart';


class AuthMethods {
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  Future<String> login({
    required String email,
    required String password,
  }) async {
    
    if (email.isEmpty || password.isEmpty) {
      return 'Please fill all the fields';
    }

    try {
      
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return 'success';
    } catch (e) {
      
      return e.toString();
    }
  }

  
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    Uint8List? file,
  }) async {
    
    if (email.isEmpty || password.isEmpty || username.isEmpty || file == null) {
      return 'Please fill all the fields';
    }

    try {
      
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User? user = userCredential.user;

      
      if (user == null) {
        return 'User creation failed';
      }

      
      String photoUrl = await StorageMethods().uploadImageToStorage(
        false,
        'profilePics',
        file,
      );

      
      Users newUser = Users(
        uid: user.uid,
        email: email,
        username: username,
        bio: '',
        photoUrl: photoUrl,
        followers: [],
        following: [],
        posts: [],
        saved: [],
        searchKey: username[0].toUpperCase(),
      );

      
      await _firestore.collection('users').doc(user.uid).set(newUser.toJson());

      return 'success';
    } catch (e) {
      
      return e.toString();
    }
  }

  
  Future<Users> getUserDetails() async {
    User? currentUser = _auth.currentUser;

    
    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    
    DocumentSnapshot snap = await _firestore.collection('users').doc(currentUser.uid).get();
    if (snap.data() == null) {
      throw Exception('User data is null');
    }
    
    
    return Users.fromSnap(snap);
  }
}
