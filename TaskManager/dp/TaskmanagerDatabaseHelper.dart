import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:app_02/TaskManager/model/user.dart';
import 'package:app_02/TaskManager/model/task.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'task_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            username TEXT NOT NULL,
            password TEXT NOT NULL,
            email TEXT NOT NULL,
            avatar TEXT,
            createdAt TEXT NOT NULL,
            lastActive TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            status TEXT NOT NULL,
            priority INTEGER NOT NULL,
            dueDate TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            assignedTo TEXT,
            createdBy TEXT NOT NULL,
            category TEXT,
            attachments TEXT,
            completed INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // CRUD for User
  Future<void> insertUser(UserModel user) async {
    final db = await database;
    await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserModel?> getUser(String id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    final db = await database;
    await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  Future<void> deleteUser(String id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD for Task
  Future<void> insertTask(TaskModel task) async {
    final db = await database;
    await db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<TaskModel?> getTask(String id) async {
    final db = await database;
    final maps = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return TaskModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<TaskModel>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks');
    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<void> updateTask(TaskModel task) async {
    final db = await database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // Tìm kiếm và lọc dữ liệu
  Future<List<TaskModel>> searchTasks({
    String? title,
    String? status,
    String? category,
    int? priority,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (title != null) {
      whereClause += 'title LIKE ?';
      whereArgs.add('%$title%');
    }
    if (status != null) {
      whereClause += whereClause.isNotEmpty ? ' AND ' : '';
      whereClause += 'status = ?';
      whereArgs.add(status);
    }
    if (category != null) {
      whereClause += whereClause.isNotEmpty ? ' AND ' : '';
      whereClause += 'category = ?';
      whereArgs.add(category);
    }
    if (priority != null) {
      whereClause += whereClause.isNotEmpty ? ' AND ' : '';
      whereClause += 'priority = ?';
      whereArgs.add(priority);
    }

    final maps = await db.query(
      'tasks',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }
}
