import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import 'login_screen.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final authService = AuthService();
  final taskService = TaskService();

  List<Map<String, dynamic>> tasks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final data = await taskService.getTasks();

    setState(() {
      tasks = data;
      loading = false;
    });
  }

  Future<void> logout() async {
    await authService.logout();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> deleteTask(String id) async {
    await taskService.deleteTask(id);
    await loadTasks();
  }

  Future<void> toggleTask(String id, bool completed) async {
    await taskService.updateTask(
      id: id,
      completed: !completed,
    );

    await loadTasks();
  }

  void openForm({Map<String, dynamic>? task}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(task: task),
      ),
    );

    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas tarefas'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(child: Text('Nenhuma tarefa cadastrada'))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final assignee = task['assignee'];

                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: task['completed'] ?? false,
                          onChanged: (_) {
                            toggleTask(
                              task['id'],
                              task['completed'] ?? false,
                            );
                          },
                        ),
                        title: Text(task['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task['description'] ?? ''),
                            if (assignee != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Responsável: $assignee',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () => openForm(task: task),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteTask(task['id']),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}