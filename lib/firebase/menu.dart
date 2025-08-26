import 'package:cloud_firestore/cloud_firestore.dart';

class MenuAPI {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchMenuItems() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('menu').get();
      List<Map<String, dynamic>> items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Include document ID if you want to reference it later
        data['id'] = doc.id;
        return data;
      }).toList();
      return items;
    } catch (e) {
      print('Error fetching menu items: $e');
      return [];
    }
  }

  /// Fetch a single menu item by document ID
  Future<Map<String, dynamic>?> fetchMenuItemById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('menu').doc(id).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching menu item by ID: $e');
      return null;
    }
  }
}
