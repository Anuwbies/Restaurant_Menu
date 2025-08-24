import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GmailAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;
    await _googleSignIn.initialize();
    _initialized = true;
  }

  Future<User?> signInWithGoogle() async {
    if (!_initialized) await _initialize();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw Exception("Missing Google ID Token");
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Check if user already exists in Firestore
        final docRef = _firestore.collection("users").doc(user.uid);
        final doc = await docRef.get();

        if (!doc.exists) {
          // Save user profile in Firestore (without username)
          await docRef.set({
            "name": user.displayName ?? "",
            "email": user.email ?? "",
            "role": "user",
            "createdAt": FieldValue.serverTimestamp(),
          });
        }
      }

      return user;
    } catch (e) {
      print("Google sign-in failed: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}