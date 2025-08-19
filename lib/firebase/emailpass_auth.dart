import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailPassAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign up with email & password, including username and name
  Future<User?> signUp({
    required String email,
    required String password,
    required String username,
    required String name,
  }) async {
    try {
      // 1. Check if username already exists
      final usernameQuery = await _firestore
          .collection("users")
          .where("username", isEqualTo: username.trim())
          .limit(1)
          .get();

      // 2. Check if email already exists in Firestore
      final emailQuery = await _firestore
          .collection("users")
          .where("email", isEqualTo: email.trim())
          .limit(1)
          .get();

      // 3. Collect errors
      final errors = <String, String>{};
      if (usernameQuery.docs.isNotEmpty) {
        errors['username'] = 'Username already exists';
      }
      if (emailQuery.docs.isNotEmpty) {
        errors['email'] = 'Email already exists';
      }

      if (errors.isNotEmpty) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          message: errors.entries
              .map((e) => '${e.key}:${e.value}')
              .join('|'), // encode both errors
        );
      }

      // 4. Create FirebaseAuth account
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // 5. Save user profile in Firestore
        await _firestore.collection("users").doc(user.uid).set({
          "username": username.trim(),
          "name": name.trim(),
          "email": email.trim(),
          "role": "user",
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email & password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async => await _auth.signOut();

  Future<void> sendPasswordResetEmail({required String email}) async =>
      await _auth.sendPasswordResetEmail(email: email.trim());

  User? get currentUser => _auth.currentUser;
}