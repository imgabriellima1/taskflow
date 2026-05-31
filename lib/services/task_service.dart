import 'package:supabase_flutter/supabase_flutter.dart';

class TaskService {
  final supabase = Supabase.instance.client;

  Future<void> createTask({
    required String title,
    required String description,
    String? assignee,
  }) async {
    final user = supabase.auth.currentUser;

    await supabase.from('tasks').insert({
      'title': title,
      'description': description,
      'completed': false,
      'user_id': user!.id,
      'assignee': assignee,
    });
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final user = supabase.auth.currentUser;

    final response = await supabase
        .from('tasks')
        .select()
        .eq('user_id', user!.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateTask({
    required String id,
    required bool completed,
  }) async {
    await supabase.from('tasks').update({
      'completed': completed,
    }).eq('id', id);
  }

  Future<void> updateTaskData({
    required String id,
    required String title,
    required String description,
    String? assignee,
  }) async {
    await supabase.from('tasks').update({
      'title': title,
      'description': description,
      'assignee': assignee,
    }).eq('id', id);
  }

  Future<void> deleteTask(String id) async {
    await supabase.from('tasks').delete().eq('id', id);
  }
}