import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _tasksRef {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks');
  }

  Future<void> addTask(Task task) async {
    try {
      await _tasksRef.add({
        'title': task.title,
        'isDone': task.isDone,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error adding task: $e');
      rethrow;
    }
  }

  Stream<List<Task>> getTasks() {
    try {
      return _tasksRef
          .orderBy('timestamp', descending: true)
          .snapshots(includeMetadataChanges: true)
          .handleError((error) {
        print('⚠ Firestore stream error: $error');
      }).map((snapshot) {
        print('📦 Stream update: ${snapshot.docs.length} docs');
        return snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Task.fromDoc(doc.id, data);
        }).toList();
      });
    } catch (e) {
      print('❌ Firestore init error: $e');
      return const Stream.empty();
    }
  }

  Future<void> toggleDone(String id, bool value) async {
    try {
      await _tasksRef.doc(id).update({'isDone': value});
    } catch (e) {
      print('❌ Error toggling task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _tasksRef.doc(id).delete();
    } catch (e) {
      print('❌ Error deleting task: $e');
      rethrow;
    }
  }
}
