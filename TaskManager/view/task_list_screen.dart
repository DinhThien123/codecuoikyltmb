import 'package:flutter/material.dart';
import 'package:app_02/TaskManager/dp/TaskmanagerDatabaseHelper.dart';
import 'package:app_02/TaskManager/model/task.dart';
import 'package:app_02/TaskManager/view/task_form_screen.dart';
import 'package:app_02/TaskManager/view/task_detail_screen.dart';
import 'package:app_02/TaskManager/view/task_item.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<TaskModel> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DatabaseHelper().getAllTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách công việc')),
      body: _tasks.isEmpty
          ? const Center(child: Text('Không có công việc nào. Nhấn + để thêm.'))
          : ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return TaskItem(
            task: task,
            onTaskUpdated: _loadTasks, // Truyền hàm làm mới vào TaskItem
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskFormScreen()),
          ).then((_) => _loadTasks());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}