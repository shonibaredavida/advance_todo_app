// ignore_for_file: deprecated_member_use

import 'package:adv_todo_app/views/widgets/checkbox_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import '../controller/todo_controller.dart';
import '../models/todo_model.dart';
import 'widgets/todo_dialog_prompt.dart';

class HomeView extends StatelessWidget {
  final TodoController controller = Get.put(TodoController());

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(title: const Text(" Advanced Todo 📝")),
      body: Obx(() {
        final rootTodos = controller.todosMap.values
            .where((thisTodo) => thisTodo.parentId == null)
            .toList();

        return Padding(
          padding: const EdgeInsets.all(12),
          child: ListView(
            children: [
              _buildDropToTopLevelArea(),
              const SizedBox(height: 10),
              if (rootTodos.isEmpty)
                Center(
                  child: Text(
                    "No todos added.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ),
              ...rootTodos.map((todo) => _buildTodoTile(todo)),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onPressed: () {
          showAddTodoDialog(Get.context!, controller);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDropToTopLevelArea() {
    return DragTarget<TodoModel>(
      onWillAccept: (dragged) => true,
      onAccept: (dragged) {
        showDialog(
          () {
            controller.moveTodoToTopLevel(dragged.id);
            Get.back();
          },
          titleString: 'Move Todo',
          subTitleString: 'This will make this Sub-task a Main Task',
        );
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty
                ? Colors.greenAccent.withOpacity(0.3)
                : Colors.white,
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? Colors.green
                  : Colors.grey[400]!,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              '⬆️ Drop here to make Top-level Task',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodoTile(TodoModel todo, {int depth = 0}) {
    final subTodos = todo.subTodoIds
        .map((id) => controller.todosMap[id])
        .where((t) => t != null)
        .cast<TodoModel>()
        .toList();

    return DragTarget<TodoModel>(
      onWillAccept: (dragged) => dragged != null && dragged.id != todo.id,
      onAccept: (draggedTodo) {
        final isTargetTopLevel = todo.parentId == null;

        if (!_isDescendant(todo, draggedTodo) && isTargetTopLevel) {
          showDialog(
            () {
              controller.moveTodoToSub(draggedTodo.id, todo.id);
              Get.back();
            },
            titleString: 'Move Todo',
            subTitleString: 'This will make this Task a Sub-Task',
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Draggable<TodoModel>(
          data: todo,
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                todo.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildTileContent(todo, depth, subTodos),
          ),
          child: _buildTileContent(todo, depth, subTodos),
        );
      },
    );
  }

  Widget _buildTileContent(
    TodoModel todo,
    int depth,
    List<TodoModel> subTodos,
  ) {
    return Slidable(
      key: Key(todo.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              showDialog(() {
                controller.deleteTodoRecursive(todo.id);
                Get.back();
              });
            },
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.only(left: depth * 20.0, top: 8),
        padding: const EdgeInsets.only(bottom: 10, right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                todo.title.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: todo.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (todo.description?.isNotEmpty ?? false)
                    Text(
                      todo.description!,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                ],
              ),
                value: todo.isDone,
                onChange: (_) {
                  if (todo.parentId == null) {
                    showDialog(
                      () {
                        controller.toggleDone(todo.id);
                        Get.back();
                      },
                      titleString: todo.isDone
                          ? 'UnMark all Sub Tasks'
                          : 'Mark all Sub Tasks',
                      subTitleString: todo.isDone
                          ? 'This will uncheck all sub Task'
                          : 'This will check all sub Task as done',
                    );
                  } else {
                    controller.toggleDone(todo.id);
                  }
                },
              ),
              trailing: todo.parentId == null
                  ? IconButton(
                      icon: const Icon(Icons.add, color: Colors.indigo),
                      tooltip: "Add Sub-Todo",
                      onPressed: () => showAddTodoDialog(
                        Get.context!,
                        controller,
                        parentId: todo.id,
                      ),
                    )
                  : const SizedBox(),
            ),
            if (subTodos.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  children: subTodos
                      .map((sub) => _buildTodoTile(sub, depth: depth + 1))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isDescendant(TodoModel parent, TodoModel child) {
    if (parent.subTodoIds.contains(child.id)) return true;

    for (var id in parent.subTodoIds) {
      final sub = controller.todosMap[id];
      if (sub != null && _isDescendant(sub, child)) return true;
    }
    return false;
  }
}

void showDialog(
  fucntion, {
  String titleString = "Delete Todoa",
  String subTitleString = "Are you sure you want to delete this todo?",
}) {
  Get.defaultDialog(
    title: titleString,
    middleText: subTitleString,
    textConfirm: "Yes",
    textCancel: "No",
    onConfirm: fucntion,
    onCancel: () {},
  );
}
