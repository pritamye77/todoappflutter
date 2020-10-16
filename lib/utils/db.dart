import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqllite/utils/tasks.dart';
import 'package:sqllite/utils/todo.dart';

class DB {
  Future<Database> database() async {
    return openDatabase(
      join(await getDatabasesPath(), 'todo.db'),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, desc TEXT)",
        );
        await db.execute(
          "CREATE TABLE todo(id INTEGER PRIMARY KEY, taskID INTEGER, title TEXT, isDone INTEGER)",
        );
        return db;
      },
      version: 1,
    );
  }

  Future<int> insertTask(Task task) async {
    int _taskID = 0;
    Database _db = await database();
    await _db
        .insert('tasks', task.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => {_taskID = value});
    return _taskID;
  }

  Future<void> updateTaskTitle(int id, String title) async {
    Database _db = await database();
    await _db.rawUpdate("UPDATE tasks SET title = '$title' WHERE id = '$id'");
  }

  Future<void> updateTaskDesc(int id, String desc) async {
    Database _db = await database();
    await _db.rawUpdate("UPDATE tasks SET desc = '$desc' WHERE id = '$id'");
  }

  Future<void> updateTodoDone(int id, int isDone) async {
    Database _db = await database();
    await _db.rawUpdate('UPDATE todo SET isDone = $isDone WHERE id = $id');
  }

  Future<void> deleteTask(int id) async {
    Database _db = await database();
    await _db.rawDelete('DELETE FROM tasks WHERE id = $id');
    await _db.rawDelete('DELETE FROM todo WHERE taskID = $id');
  }

  Future<void> insertTodo(Todo todo) async {
    Database _db = await database();
    await _db.insert('todo', todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getTasks() async {
    Database _db = await database();
    List<Map<String, dynamic>> taskMap = await _db.query('tasks');
    return List.generate(taskMap.length, (index) {
      return Task(
          id: taskMap[index]['id'],
          title: taskMap[index]['title'],
          description: taskMap[index]['desc']);
    });
  }

  Future<List<Todo>> getTodo(int taskId) async {
    Database _db = await database();
    List<Map<String, dynamic>> todoMap =
        await _db.rawQuery('SELECT * FROM todo WHERE taskID = $taskId');
    return List.generate(todoMap.length, (index) {
      return Todo(
        id: todoMap[index]['id'],
        title: todoMap[index]['title'],
        taskID: todoMap[index]['taskID'],
        isDone: todoMap[index]['isDone'],
      );
    });
  }
}
