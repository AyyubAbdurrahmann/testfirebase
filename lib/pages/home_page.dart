import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/task.dart';

class HomePage extends StatelessWidget {
  final FirestoreService firestore = FirestoreService();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List Firestore')),
      body: StreamBuilder<List<Task>>(
        stream: firestore.getTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!;
          if (tasks.isEmpty) {
            return const Center(child: Text('Belum ada tugas.'));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return CheckboxListTile(
                title: Text(task.title),
                value: task.isDone,
                onChanged: (val) {
                  firestore.toggleDone(task.id, val!);
                },
                secondary: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => firestore.deleteTask(task.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add') as String?;
          if (result != null && result.isNotEmpty) {
            firestore.addTask(
              Task(
                id: '',
                title: result,
                isDone: false,
                timestamp: DateTime.now(),
              ),
            );
          }
        },
      ),
    );
  }
}
