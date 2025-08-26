import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryAPI {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all inventory names (as before)
  Future<List<String>> fetchInventoryNames() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('inventory').get();
      return snapshot.docs
          .map((doc) => doc['name'].toString())
          .toList();
    } catch (e) {
      print('Error fetching inventory names: $e');
      return [];
    }
  }

  Future<String?> fetchInventoryNameById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('inventory').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return doc['name'].toString();
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching inventory name by ID: $e');
      return null;
    }
  }

  /// NEW: Fetch all inventory data as List<Map<String, dynamic>>
  Future<List<Map<String, dynamic>>> fetchAllInventoryData() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('inventory').get();
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        };
      }).toList();
    } catch (e) {
      print('Error fetching all inventory data: $e');
      return [];
    }
  }

  /// NEW: Fetch single inventory document by ID with full data
  Future<Map<String, dynamic>?> fetchInventoryById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('inventory').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        };
      }
      return null;
    } catch (e) {
      print('Error fetching inventory by ID: $e');
      return null;
    }
  }
}
