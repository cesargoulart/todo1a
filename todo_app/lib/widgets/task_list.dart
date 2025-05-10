import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_item.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task, bool?) onTaskCompletedChanged;
  final bool showCompletedTasks;
  final Function(Task) onTaskDeleted;
  final Function(Task task, {Task? parentTask, int? subtaskIndex}) onTaskEdited;
  final Function(Task) onAddTaskSubtask;
  final Function(Task, bool) onTaskExpandToggle;

  const TaskList({
    super.key,
    required this.tasks,
    required this.onTaskCompletedChanged,
    required this.showCompletedTasks,
    required this.onTaskDeleted,
    required this.onTaskEdited,
    required this.onAddTaskSubtask,
    required this.onTaskExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    final List<Task> filteredTasks;
    if (showCompletedTasks) {
      filteredTasks = tasks;
    } else {
      filteredTasks = tasks.where((task) => !task.isCompleted).toList();
    }

    if (filteredTasks.isEmpty) {
      return Center(
        child: Text(
          showCompletedTasks ? 'Nenhuma tarefa ainda!' : 'Nenhuma tarefa pendente!',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return TaskItem(
          task: task,
          onCompletedChanged: (value) {
            onTaskCompletedChanged(task, value);
          },
          onDeleted: () {
            onTaskDeleted(task);
          },
          onEdited: (editTask, {parentTask, subtaskIndex}) {
            onTaskEdited(editTask, parentTask: parentTask, subtaskIndex: subtaskIndex);
          },
          onAddSubtask: () {
            onAddTaskSubtask(task);
          },
          onExpandToggle: (isExpanded) {
            onTaskExpandToggle(task, isExpanded);
          },
        );
      },
    );
  }
}