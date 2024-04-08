import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/enums/user_enums.dart';
import 'package:user_app/models/user.dart';

class UserService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<PolmitraUser>> getUsersByNetaId(String netaId) async {
    try {
      final querySnapshot = await firestore.collection('users').where('netaId', isEqualTo: netaId).get();

      final users = querySnapshot.docs.map((doc) => PolmitraUser.fromDocument(doc)).toList();
      return users;
    } catch (e) {
      // Handle errors (e.g., print error message, throw exception)
      print("Error fetching users: $e");
      return []; // Return empty list on error
    }
  }

  Future<List<PolmitraUser>> getUsersByRole(UserRole role) async {
    try {
      final querySnapshot = await firestore.collection('users').where('role', isEqualTo: role.toString()).get();

      final users = querySnapshot.docs.map((doc) => PolmitraUser.fromDocument(doc)).toList();
      return users;
    } catch (e) {
      // Handle errors (e.g., print error message, throw exception)
      print("Error fetching users: $e");
      return []; // Return empty list on error
    }
  }

  Future<PolmitraUser?> getUserById(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      return PolmitraUser.fromDocument(doc);
    } catch (e) {
      // Handle errors (e.g., print error message, throw exception)
      print("Error fetching user: $e");
      return null; // Return null on error
    }
  }

  Future<void> updateUser(PolmitraUser user) async {
    try {
      await firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      // Handle errors (e.g., print error message, throw exception)
      print("Error updating user: $e");
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await firestore.collection('users').doc(userId).delete();
    } catch (e) {
      // Handle errors (e.g., print error message, throw exception)
      print("Error deleting user: $e");
    }
  }
}
