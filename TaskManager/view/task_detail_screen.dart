import 'package:flutter/material.dart';
import 'package:app_02/TaskManager/model/task.dart';
import 'package:app_02/TaskManager/dp/TaskmanagerDatabaseHelper.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết công việc')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tiêu đề: ${task.title}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Mô tả: ${task.description}'),
            Text('Trạng thái: ${task.status}'),
            Text('Độ ưu tiên: ${task.priority}'),
            Text('Hạn hoàn thành: ${task.dueDate ?? "Không có"}'),
            Text('Được giao cho: ${task.assignedTo ?? "Không có"}'),
            Text('Phân loại: ${task.category ?? "Không có"}'),
            const SizedBox(height: 10),
            if (task.attachments != null && task.attachments!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tệp đính kèm:'),
                  ...task.attachments!.map((attachment) => Text(attachment)),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Xác định trạng thái mới dựa trên completed
                bool newCompleted = !task.completed;
                String newStatus = newCompleted
                    ? 'Done'
                    : (task.status == 'Done' ? 'In progress' : task.status);

                final updatedTask = TaskModel(
                  id: task.id,
                  title: task.title,
                  description: task.description,
                  status: newStatus,
                  priority: task.priority,
                  dueDate: task.dueDate,
                  createdAt: task.createdAt,
                  updatedAt: DateTime.now(),
                  assignedTo: task.assignedTo,
                  createdBy: task.createdBy,
                  category: task.category,
                  attachments: task.attachments,
                  completed: newCompleted,
                );
                try {
                  await DatabaseHelper().updateTask(updatedTask);
                  // Kiểm tra dữ liệu sau khi cập nhật (tùy chọn, có thể xóa sau khi kiểm tra)
                  final updatedTaskFromDb = await DatabaseHelper().getTask(updatedTask.id);
                  print('Updated task status: ${updatedTaskFromDb?.status}, completed: ${updatedTaskFromDb?.completed}');
                  // Hiển thị thông báo thành công
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        newCompleted
                            ? 'Đã đánh dấu hoàn thành!'
                            : 'Đã đánh dấu chưa hoàn thành!',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  // Trả về true để báo hiệu rằng dữ liệu đã thay đổi
                  Navigator.pop(context, true);
                } catch (e) {
                  // Hiển thị thông báo lỗi nếu có
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi khi cập nhật công việc: $e'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text(
                task.completed ? 'Đánh dấu chưa hoàn thành' : 'Đánh dấu hoàn thành',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
