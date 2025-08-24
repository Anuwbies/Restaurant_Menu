import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailPassAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign up with email & password, including name
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // 1. Check if email already exists in Firestore
      final emailQuery = await _firestore
          .collection("users")
          .where("email", isEqualTo: email.trim())
          .limit(1)
          .get();

      if (emailQuery.docs.isNotEmpty) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          message: 'Email already exists',
        );
      }

      // 2. Create FirebaseAuth account
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // 3. Update Firebase Auth displayName
        await user.updateDisplayName(name.trim());
        await user.reload(); // Refresh the user object

        // 4. Save user profile in Firestore
        await _firestore.collection("users").doc(user.uid).set({
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
