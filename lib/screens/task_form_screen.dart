import 'package:flutter/material.dart';
import '../services/task_service.dart';

class TaskFormScreen extends StatefulWidget {
  final Map<String, dynamic>? task;

  const TaskFormScreen({  
    super.key,
    this.task,
  });

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final assigneeController = TextEditingController();
  final taskService = TaskService();

  bool loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      titleController.text = widget.task!['title'];
      descriptionController.text = widget.task!['description'] ?? '';
      assigneeController.text = widget.task!['assignee'] ?? '';
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    assigneeController.dispose();
    super.dispose();
  }

  Future<void> saveTask() async {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o título da tarefa')),
      );
      return;
    }

    try {
      setState(() => loading = true);

      if (widget.task == null) {
        await taskService.createTask(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          assignee: assigneeController.text.trim().isEmpty
              ? null
              : assigneeController.text.trim(),
        );
      } else {
        await taskService.updateTaskData(
          id: widget.task!['id'],
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          assignee: assigneeController.text.trim().isEmpty
              ? null
              : assigneeController.text.trim(),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar tarefa')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar tarefa' : 'Nova tarefa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: assigneeController,
              decoration: const InputDecoration(
                labelText: 'Responsável',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: loading ? null : saveTask,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}