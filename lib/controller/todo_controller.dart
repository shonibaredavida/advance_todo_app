import 'package:adv_todo_app/models/todo_model.dart';
class TodoController extends GetxController {
  final todosMap = <String, TodoModel>{}.obs;
  void onInit() {
    super.onInit();
  }
}
