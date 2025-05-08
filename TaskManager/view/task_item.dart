import 'package:flutter/material.dart';
import 'package:app_02/TaskManager/model/task.dart';
import 'package:app_02/TaskManager/dp/TaskmanagerDatabaseHelper.dart';
import 'package:app_02/TaskManager/view/task_form_screen.dart';
import 'package:app_02/TaskManager/view/task_detail_screen.dart';
import 'package:app_02/TaskManager/view/task_list_screen.dart';

class TaskItem extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTaskUpdated; // Thêm callback để làm mới danh sách

  const TaskItem({super.key, required this.task, required this.onTaskUpdated});

  Color _getPriorityColor() {
    switch (task.priority) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor() {
    switch (task.status) {
      case 'To do':
        return Colors.blue;
      case 'In progress':
        return Colors.orange;
      case 'Done':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          ).then((value) {
            if (value == true) {
              onTaskUpdated(); // Gọi callback để làm mới danh sách
            }
          });
        },
        title: Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.label,
                  color: _getPriorityColor(),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskFormScreen(task: task),
                  ),
                ).then((_) {
                  onTaskUpdated(); // Làm mới sau khi chỉnh sửa
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                try {
                  await DatabaseHelper().deleteTask(task.id);
                  onTaskUpdated(); // Làm mới sau khi xóa
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi khi xóa công việc: $e'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
