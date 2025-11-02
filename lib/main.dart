import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import './services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List Firestore',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();
  final CollectionReference tasks = FirebaseFirestore.instance.collection(
    'tasks',
  );

  Future<void> _addTask(String title) async {
    await tasks.add({
      'title': title,
      'isDone': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _controller.clear();
  }

  Future<void> _toggleDone(String id, bool value) async {
    await tasks.doc(id).update({'isDone': value});
  }

  Future<void> _deleteTask(String id) async {
    await tasks.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List Firestore')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: tasks.orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('Belum ada tugas.'));
                }

                return ListView(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final id = doc.id;
                    final title = data['title'] ?? '';
                    final isDone = data['isDone'] ?? false;

                    return CheckboxListTile(
                      title: Text(title),
                      value: isDone,
                      onChanged: (val) => _toggleDone(id, val!),
                      secondary: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTask(id),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Tambahkan tugas...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      _addTask(_controller.text.trim());
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
