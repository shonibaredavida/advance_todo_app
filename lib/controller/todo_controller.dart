import 'dart:math';
import 'package:adv_todo_app/models/todo_model.dart';
import 'package:adv_todo_app/services/hive_service.dart';
import 'package:adv_todo_app/services/notification_service.dart';
import 'package:get/get.dart';

class TodoController extends GetxController {
  final todosMap = <String, TodoModel>{}.obs;
  final notificationService = NotificationService();
  @override
  void onInit() {
    super.onInit();
    loadTodosFromStorage();
  }

  void loadTodosFromStorage() {
    final savedTodos = HiveService.loadTodos();
    todosMap.value = {for (var eachTodo in savedTodos) eachTodo.id: eachTodo};
  }

  List<TodoModel> getParentTodos() {
    return todosMap.values
        .where((thisTodo) => thisTodo.parentId == null)
        .toList();
  }

  List<TodoModel> getChildrenTodos(String parentId) {
    return todosMap.values
        .where((thisTodo) => thisTodo.parentId == parentId)
        .toList();
  }

  TodoModel? getById(String id) => todosMap[id];

  void addTodo({
    required String title,
    String? description,
    DateTime? deadline,
    int? reminderMinutesBefore,
    String? parentId,
  }) {
    int suffix = Random().nextInt(100000);
    final id = '${DateTime.now().microsecond}$suffix';
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

    if (deadline != null) {
      NotificationService.showScheduledNotification(
        id: int.parse(id),
        title: title,
        body: description ?? "Urgent Task",
        dateTime: deadline,
      );
    }

    saveToHive();
    todosMap.refresh();
  }

  void moveTodoToSub(String draggedId, String newParentId) {
    final dragged = todosMap[draggedId];
    final newParent = todosMap[newParentId];
    if (dragged == null || newParent == null) return;

    // Remove from old parent or top-level
    if (dragged.parentId != null) {
      final oldParent = todosMap[dragged.parentId!];
      oldParent?.subTodoIds.remove(draggedId);
    }

    dragged.parentId = newParentId;
    newParent.subTodoIds.add(draggedId);
    saveToHive();
    todosMap.refresh();
  }

  void moveTodoToTopLevel(String todoId) {
    final todo = todosMap[todoId];
    if (todo == null) return;

    if (todo.parentId != null) {
      final parent = todosMap[todo.parentId!];
      parent?.subTodoIds.remove(todoId);
      todo.parentId = null;
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

  void toggleDone(String id) {
    final thisTodo = todosMap[id];
    if (thisTodo == null) return;
    thisTodo.isDone = !thisTodo.isDone;
    for (var childId in thisTodo.subTodoIds) {
      _setDoneRecursive(childId, thisTodo.isDone);
    }
    saveToHive();
    todosMap.refresh();
  }

  void _setDoneRecursive(String id, bool done) {
    final thisTodo = todosMap[id];
    if (thisTodo == null) return;
    thisTodo.isDone = done;
    for (var child in thisTodo.subTodoIds) {
      _setDoneRecursive(child, done);
    }
  }

  bool isOutdated(String id) {
    final thisTodo = todosMap[id];
    if (thisTodo!.deadline != null) {
      return thisTodo.deadline!.isBefore(DateTime.now());
    }
    return false;
  }

  deleteTodoRecursive(String id) async {
    final thisTodo = todosMap[id];
    if (thisTodo == null) return;
    if (thisTodo.parentId != null) {
      final parent = todosMap[thisTodo.parentId!];
      if (parent != null) {
        parent.subTodoIds = parent.subTodoIds.where((e) => e != id).toList();
        int notificationId = int.parse(id);
        await NotificationService.cancelNotification(notificationId);
      }
    }
    for (var c in List<String>.from(thisTodo.subTodoIds)) {
      deleteTodoRecursive(c);
    }
    todosMap.remove(id);
    saveToHive();
    todosMap.refresh();
  }

  bool canNest(String childId, String? newParentId) {
    if (newParentId == null) return true; // moving to root allowed
    if (childId == newParentId) return false;
    var cur = todosMap[newParentId];
    while (cur != null) {
      if (cur.parentId == childId) return false;
      if (cur.parentId == null) break;
      cur = todosMap[cur.parentId];
    }
    return true;
  }

  void moveToParent(String childId, String? newParentId) {
    if (!canNest(childId, newParentId)) return;
    final child = todosMap[childId];
    if (child == null) return;

    if (child.parentId != null) {
      final oldParent = todosMap[child.parentId!];
      if (oldParent != null) {
        oldParent.subTodoIds = oldParent.subTodoIds
            .where((e) => e != childId)
            .toList();
      }
    }
    child.parentId = newParentId;
    if (newParentId != null) {
      final newParent = todosMap[newParentId];
      if (newParent != null) {
        newParent.subTodoIds = [...newParent.subTodoIds, childId];
      }
    }
    saveToHive();
    todosMap.refresh();
  }

  void saveToHive() {
    HiveService.saveTodos(todosMap.values.toList());
  }
}
