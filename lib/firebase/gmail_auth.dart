import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GmailAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;
    await _googleSignIn.initialize();
    _initialized = true;
  }

  Future<User?> signInWithGoogle() async {
    if (!_initialized) await _initialize();

    try {
      final GoogleSignInAccount? googleUser =
      await _googleSignIn.authenticate();

      if (googleUser == null) return null;

      // New API: only idToken available
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        throw Exception("Missing Google ID Token");
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // no accessToken anymore
      );

      final userCredential =
      await _auth.signInWithCredential(credential);

      return userCredential.user;
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
