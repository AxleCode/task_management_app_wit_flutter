import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject{
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  int status;

  @HiveField(4)
  int createdBy;

  @HiveField(5)
  int assignedTo;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdBy,
    required this.assignedTo,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? "",
        status: json['status'],
        createdBy: json['created_by'],
        assignedTo: json['assigned_to'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "status": status,
        "created_by": createdBy,
        "assigned_to": assignedTo,
      };
}
