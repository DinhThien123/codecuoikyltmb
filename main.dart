import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_02/TaskManager/dp/TaskmanagerDatabaseHelper.dart';
import 'package:app_02/TaskManager/view/task_list_screen.dart';
import 'package:app_02/TaskManager/view/register_screen.dart';
import 'package:app_02/TaskManager/view/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(), // Giữ LoginScreen làm màn hình chính
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(), // Thêm route cho RegisterScreen
        '/task_list': (context) => const TaskListScreen(), // Thêm route cho TaskListScreen
      },
    );
  }
}