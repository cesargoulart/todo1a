import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  final Function(bool?) onCompletedChanged;
  final VoidCallback onDeleted;
  final Function(Task task, {Task? parentTask, int? subtaskIndex}) onEdited;
  final VoidCallback onAddSubtask;
  final bool isSubtask;
  final Task? parentTask;
  final int? subtaskIndex;
  final Function(bool) onExpandToggle;

  const TaskItem({
    super.key,
    required this.task,
    required this.onCompletedChanged,
    required this.onDeleted,
    required this.onEdited,
    required this.onAddSubtask,
    required this.onExpandToggle,
    this.isSubtask = false,
    this.parentTask,
    this.subtaskIndex,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.task.isExpanded) {
      _expandController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (widget.task.subtasks.isEmpty) return;
    
    if (widget.task.isExpanded) {
      _expandController.reverse();
    } else {
      _expandController.forward();
    }
    widget.onExpandToggle(!widget.task.isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: _isHovered
                  ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Transform.scale(
              scale: _isHovered ? 1.02 : 1.0,
              child: ListTile(
                contentPadding: widget.isSubtask
                    ? const EdgeInsets.only(left: 40.0, right: 16.0)
                    : null,
                leading: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Checkbox(
                    value: widget.task.isCompleted,
                    onChanged: widget.onCompletedChanged,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: InkWell(
                  onTap: _toggleExpanded,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.task.title,
                          style: TextStyle(
                            decoration: widget.task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: widget.task.isCompleted
                                ? Colors.grey
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: widget.isSubtask ? 14.0 : null,
                          ),
                        ),
                      ),
                      if (widget.task.subtasks.isNotEmpty)
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 300),
                          turns: widget.task.isExpanded ? 0.5 : 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.expand_more,
                              color: _isHovered
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                trailing: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isHovered ? 1.0 : 0.7,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (!widget.isSubtask)
                        IconButton(
                          icon: Icon(
                            Icons.playlist_add_outlined,
                            color: _isHovered
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.primary.withOpacity(0.7),
                          ),
                          tooltip: 'Adicionar Subtarefa',
                          onPressed: widget.onAddSubtask,
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.edit_note_outlined,
                          color: _isHovered
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                        ),
                        tooltip: 'Editar Tarefa',
                        onPressed: () => widget.onEdited(widget.task,
                            parentTask: widget.parentTask, subtaskIndex: widget.subtaskIndex),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_sweep_outlined,
                          color: _isHovered
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.error.withOpacity(0.7),
                        ),
                        tooltip: 'Remover Tarefa',
                        onPressed: widget.onDeleted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.task.subtasks.isNotEmpty)
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                children: widget.task.subtasks.map((subtask) {
                  return TaskItem(
                    key: ValueKey(subtask.hiveKey ?? subtask.title + subtask.isCompleted.toString()),
                    task: subtask,
                    onCompletedChanged: (isCompleted) {
                      widget.onCompletedChanged(isCompleted);
                    },
                    onDeleted: widget.onDeleted,
                    onEdited: widget.onEdited,
                    onAddSubtask: () {},
                    onExpandToggle: (expanded) {
                      widget.onExpandToggle(expanded);
                    },
                    isSubtask: true,
                    parentTask: widget.task,
                    subtaskIndex: widget.task.subtasks.indexOf(subtask),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}