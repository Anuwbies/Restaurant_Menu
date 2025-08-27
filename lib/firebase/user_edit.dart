import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserAPI {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Update user's display name in Firestore (requires password reauthentication)
  Future<void> updateUserName(String newName, String currentPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is currently logged in.');

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);

      // Update name in Firestore
      await _firestore.collection('users').doc(user.uid).update({'name': newName});
    } catch (e) {
      throw Exception('Failed to update name: $e');
    }
  }

  /// Update user's email (with password)
  Future<void> updateUserEmail(String newEmail, String currentPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is currently logged in.');

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);

      // Firebase now requires verifyBeforeUpdateEmail instead of updateEmail
      await user.verifyBeforeUpdateEmail(newEmail);

      // Update Firestore email
      await _firestore.collection('users').doc(user.uid).update({'email': newEmail});
    } catch (e) {
      throw Exception('Failed to update email: $e');
    }
  }
}
