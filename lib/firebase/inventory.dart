// inventory.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryAPI {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> fetchInventoryNames() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('inventory').get();
      List<String> names = snapshot.docs
          .map((doc) => doc['name'].toString())
          .toList();
      return names;
    } catch (e) {
      print('Error fetching inventory names: $e');
      return [];
    }
  }

  /// Fetches a single inventory item name by document ID
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
}
