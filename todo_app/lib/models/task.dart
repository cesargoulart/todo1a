import 'package:hive/hive.dart';

part 'task.g.dart'; // Arquivo gerado pelo Hive

@HiveType(typeId: 0) // Define o typeId para esta classe
class Task {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  List<Task> subtasks;

  @HiveField(3) // Novo campo para controlar visibilidade
  bool isExpanded;

  dynamic hiveKey;

  Task({
    required this.title,
    this.isCompleted = false,
    this.hiveKey,
    this.isExpanded = false, // Inicialmente fechado
    List<Task>? subtasks,
  }) : subtasks = subtasks ?? [];
}