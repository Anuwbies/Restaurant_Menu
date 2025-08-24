import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current logged-in user
  User? get currentUser => _auth.currentUser;

  /// Load user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore.collection("users").doc(user.uid).get();
    return snapshot.data();
  }

  /// Check if username exists (excluding current user)
  Future<bool> usernameExists(String username) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final query = await _firestore
        .collection("users")
        .where("username", isEqualTo: username)
        .limit(1)
        .get();

    return query.docs.isNotEmpty && query.docs.first.id != user.uid;
  }

  /// Check if email exists (excluding current user)
  Future<bool> emailExists(String email) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final query = await _firestore
        .collection("users")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();

    return query.docs.isNotEmpty && query.docs.first.id != user.uid;
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String username,
    required String name,
    required String email,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection("users").doc(user.uid).update({
      "username": username,
      "name": name,
      "email": email,
    });

    // Optionally update Firebase Auth email too
    if (email != user.email) {
      // await user.updateEmail(email);
    }
  }
}