import 'package:adv_todo_app/controller/todo_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showAddTodoDialog(
  BuildContext context,
  TodoController controller, {
  String? parentId,
}) {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(parentId == null ? "Add Todo" : "Add Sub-Todo"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleCtrl,
            decoration: const InputDecoration(hintText: "Title"),
          ),
          TextField(
            controller: descCtrl,
            decoration: const InputDecoration(hintText: "Description"),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            if (titleCtrl.text.trim().isNotEmpty) {
              controller.addTodo(
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
                parentId: parentId,
              );
              Get.back();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: const Text("Add", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
