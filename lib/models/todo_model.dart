import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  bool isDone;

  @HiveField(4)
  DateTime? deadline;

  @HiveField(5)
  int? reminderMinutesBefore;

  @HiveField(6)
  String? parentId;

  @HiveField(7)
  List<String> subTodoIds;

  TodoModel({
    required this.id,
    required this.title,
    this.description,
    this.isDone = false,
    this.deadline,
    this.reminderMinutesBefore,
    this.parentId,
    this.subTodoIds = const [],
  });
}
