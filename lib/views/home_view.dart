// ignore_for_file: deprecated_member_use

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
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

        return AnimatedContainer(
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
              controller.moveTodoToSub(draggedTodo.id, todo.id);
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
                controller.deleteTodoRecursive(todo.id);
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
              leading: Checkbox(
                value: todo.isDone,
                onChanged: (_) {
                        controller.toggleDone(todo.id);
                },
              ),
              trailing: todo.parentId == null
                  ? IconButton(
                      icon: const Icon(Icons.add, color: Colors.indigo),
                      tooltip: "Add Sub-Todo",
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

