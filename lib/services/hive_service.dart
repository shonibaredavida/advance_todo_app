import 'package:adv_todo_app/models/todo_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String todoBoxName = "todos";

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TodoModelAdapter());
    await Hive.openBox<TodoModel>(todoBoxName);
  }

  static void saveTodos(List<TodoModel> todos) {
    final box = Hive.box<TodoModel>(todoBoxName);
    box.clear();
    for (var todo in todos) {
      box.put(todo.id, todo);
    }
  }

  static List<TodoModel> loadTodos() {
    final box = Hive.box<TodoModel>(todoBoxName);
    return box.values.toList();
  }
}
