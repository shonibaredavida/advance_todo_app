import 'package:adv_todo_app/controller/add_todo_controller.dart';
import 'package:adv_todo_app/controller/todo_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

void showAddTodoDialog(
  BuildContext context,
  TodoController controller, {
  String? parentId,
}) {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final addController = Get.put(AddTodoDialogController());
  Future<void> pickDeadline(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        addController.finalDeadline.value = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      }
    }
  }

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(
        parentId == null ? "Add task" : "Add sub-task",
        style: TextStyle(fontSize: 16),
      ),
      content: Obx(
        () => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                maxLength: 16,
                decoration: const InputDecoration(hintText: "title"),
              ),
              TextField(
                controller: descCtrl,
                maxLength: 28,
                decoration: const InputDecoration(
                  hintText: "description",
                  hintStyle: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  pickDeadline(context);
                },
                child: Text(
                  addController.finalDeadline.value == null
                      ? 'Click to add Reminder'
                      : "Deadline: ${DateFormat.yMd().add_jm().format(addController.finalDeadline.value!)}",
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            if (titleCtrl.text.trim().isNotEmpty) {
              addController.finalDeadline.value == null
                  ? controller.addTodo(
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      parentId: parentId,
                    )
                  : controller.addTodo(
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      parentId: parentId,
                      deadline: addController.finalDeadline.value,
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
