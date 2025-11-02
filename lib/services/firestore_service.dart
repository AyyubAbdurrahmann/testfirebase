import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirestoreService {
  final CollectionReference tasksRef = FirebaseFirestore.instance.collection(
    'tasks',
  );

  Future<void> addTask(Task task) async {
    await tasksRef.add(task.toMap());
  }

  Stream<List<Task>> getTasks() {
    try {
      return tasksRef
          .orderBy('timestamp', descending: true)
          .snapshots(includeMetadataChanges: true)
          .handleError((error) {
            print('⚠ Firestore stream error: $error');
          })
          .map((snapshot) {
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
    await tasksRef.doc(id).update({'isDone': value});
  }

  Future<void> deleteTask(String id) async {
    await tasksRef.doc(id).delete();
  }
}
