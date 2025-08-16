import 'package:adv_todo_app/models/todo_model.dart';
import 'package:adv_todo_app/services/hive_service.dart';
import 'package:get/get.dart';

class TodoController extends GetxController {
  final todosMap = <String, TodoModel>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadTodosFromStorage();
  }

  void loadTodosFromStorage() {
    final savedTodos = HiveService.loadTodos();
    todosMap.value = {for (var eachTodo in savedTodos) eachTodo.id: eachTodo};
  }



  TodoModel? getById(String id) => todosMap[id];

  void addTodo({
    required String title,
    String? description,
    DateTime? deadline,
    int? reminderMinutesBefore,
    String? parentId,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newTodo = TodoModel(
      id: id,
      title: title,
      description: description,
      deadline: deadline,
      reminderMinutesBefore: reminderMinutesBefore,
      parentId: parentId,
      subTodoIds: [],
    );
    todosMap[id] = newTodo;
    if (parentId != null) {
      final parent = todosMap[parentId];
      if (parent != null) {
        parent.subTodoIds = [...parent.subTodoIds, id];
      }
    }
    saveToHive();
    todosMap.refresh();
  }

  void editTodo(
    String id, {
    String? title,
    String? description,
    DateTime? deadline,
    int? reminderMinutesBefore,
  }) {
    final currentTodo = todosMap[id];
    if (currentTodo == null) return;
    currentTodo.title = title ?? currentTodo.title;
    currentTodo.description = description ?? currentTodo.description;
    currentTodo.deadline = deadline;
    currentTodo.reminderMinutesBefore = reminderMinutesBefore;
    saveToHive();
    todosMap.refresh();
  }
  void saveToHive() {
    HiveService.saveTodos(todosMap.values.toList());
  }
}
