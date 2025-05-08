import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_02/TaskManager/dp/TaskmanagerDatabaseHelper.dart';
import 'package:app_02/TaskManager/model/task.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task; // Thêm tham số task để hỗ trợ chỉnh sửa

  const TaskFormScreen({super.key, this.task});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _status = 'To do';
  int _priority = 1;
  DateTime? _dueDate;
  String _createdBy = 'user1'; // Giả định user ID
  String? _category;
  bool _completed = false;
  String? _taskId; // Lưu ID của task nếu đang chỉnh sửa

  @override
  void initState() {
    super.initState();
    // Nếu có task được truyền vào (chế độ chỉnh sửa), điền sẵn dữ liệu
    if (widget.task != null) {
      _taskId = widget.task!.id;
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _status = widget.task!.status;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
      _createdBy = widget.task!.createdBy;
      _category = widget.task!.category;
      _completed = widget.task!.completed;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final task = TaskModel(
        id: _taskId ?? DateTime.now().millisecondsSinceEpoch.toString(), // Dùng ID cũ nếu chỉnh sửa, tạo mới ID nếu thêm
        title: _titleController.text,
        description: _descriptionController.text,
        status: _status,
        priority: _priority,
        dueDate: _dueDate,
        createdAt: widget.task?.createdAt ?? DateTime.now(), // Giữ nguyên createdAt nếu chỉnh sửa
        updatedAt: DateTime.now(),
        createdBy: _createdBy,
        category: _category,
        attachments: widget.task?.attachments, // Giữ nguyên attachments (chưa xử lý tải lên)
        completed: _completed,
      );

      if (_taskId != null) {
        // Chế độ chỉnh sửa: Cập nhật task
        await DatabaseHelper().updateTask(task);
      } else {
        // Chế độ thêm mới: Thêm task
        await DatabaseHelper().insertTask(task);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Chỉnh sửa công việc' : 'Thêm công việc'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Tiêu đề'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tiêu đề';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mô tả';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: ['To do', 'In progress', 'Done', 'Cancelled']
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Trạng thái'),
                ),
                DropdownButtonFormField<int>(
                  value: _priority,
                  items: [
                    const DropdownMenuItem(value: 1, child: Text('Thấp')),
                    const DropdownMenuItem(value: 2, child: Text('Trung bình')),
                    const DropdownMenuItem(value: 3, child: Text('Cao')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _priority = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Độ ưu tiên'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Phân loại'),
                  initialValue: _category,
                  onChanged: (value) {
                    _category = value;
                  },
                ),
                ListTile(
                  title: Text(
                    _dueDate == null
                        ? 'Chọn hạn hoàn thành'
                        : 'Hạn: ${DateFormat.yMd().format(_dueDate!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDueDate(context),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveTask,
                  child: Text(widget.task != null ? 'Cập nhật' : 'Lưu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
