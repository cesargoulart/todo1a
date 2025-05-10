import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; // Necessário para BoxEvent
import '../models/task.dart';
import '../widgets/task_list.dart';
import '../services/hive_service.dart'; // Importar o HiveService

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HiveService _hiveService = HiveService();
  List<Task> _tasks = []; // Lista de tarefas agora virá do Hive
  final TextEditingController _taskController = TextEditingController();
  bool _showCompletedTasks = false;
  bool _isLoading = true; // Para indicar o carregamento inicial

  @override
  void initState() {
    super.initState();
    _loadTasks();
    // Ouvir mudanças na box para atualizar a UI em tempo real
    _hiveService.watchTasks().listen((BoxEvent event) {
      // event.key, event.value, event.deleted
      _loadTasks(); // Recarrega as tarefas quando houver uma mudança
    });
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });
    final box = await Hive.openBox<Task>('tasksBox'); // Abrir a box diretamente aqui para pegar as chaves
    final tasksFromHive = <Task>[];
    for (var key in box.keys) {
      final task = box.get(key);
      if (task != null) {
        task.hiveKey = key; // Atribuir a chave do Hive à tarefa
        tasksFromHive.add(task);
      }
    }
    // Não precisamos mais do _hiveService.getAllTasks() se abrirmos a box aqui
    // _tasks = await _hiveService.getAllTasks();
    setState(() {
      _tasks = tasksFromHive;
      _isLoading = false;
    });
  }

  void _toggleShowCompletedTasks() {
    setState(() {
      _showCompletedTasks = !_showCompletedTasks;
    });
  }

  Future<void> _addTask() async {
    if (_taskController.text.isNotEmpty) {
      final newTask = Task(title: _taskController.text);
      await _hiveService.addTask(newTask);
      _taskController.clear();
      if (mounted) { // Verificar se o widget ainda está montado
         Navigator.of(context).pop(); // Fecha o diálogo
      }
      // _loadTasks(); // Não é mais necessário aqui por causa do watchTasks
    }
  }

  void _showAddTaskDialog() {
    _taskController.clear(); // Limpar o controller antes de mostrar o diálogo
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nova Tarefa'),
          content: TextField(
            controller: _taskController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Digite o título da tarefa'),
            onSubmitted: (_) => _addTask(),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Adicionar'),
              onPressed: _addTask,
            ),
          ],
        );
      },
    );
  }

  Future<void> _onTaskCompletedChanged(Task task, bool? isCompleted) async {
    if (isCompleted != null && task.hiveKey != null) {
      final updatedTask = Task(
        title: task.title,
        isCompleted: isCompleted,
        hiveKey: task.hiveKey,
        subtasks: task.subtasks,
        isExpanded: task.isExpanded,
      );
      await _hiveService.updateTask(task.hiveKey!, updatedTask);
    }
  }

  // Método para alternar a expansão das subtarefas
  Future<void> _onTaskExpandToggle(Task task, bool isExpanded) async {
    if (task.hiveKey != null) {
      final updatedTask = Task(
        title: task.title,
        isCompleted: task.isCompleted,
        hiveKey: task.hiveKey,
        subtasks: task.subtasks,
        isExpanded: isExpanded,
      );
      await _hiveService.updateTask(task.hiveKey!, updatedTask);
    }
  }
  
  // Adicionar método para deletar tarefa
  Future<void> _deleteTask(Task task) async {
    if (task.hiveKey != null) {
      await _hiveService.deleteTask(task.hiveKey);
      // _loadTasks(); // Não é mais necessário aqui por causa do watchTasks
      // Opcional: mostrar um SnackBar de confirmação
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${task.title} removida')),
        );
      }
    }
  }

  // Método para mostrar o diálogo de edição de tarefa
  void _showEditTaskDialog(Task task, {Task? parentTask, int? subtaskIndex}) {
    _taskController.text = task.title;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(parentTask != null ? 'Editar Subtarefa' : 'Editar Tarefa'),
          content: TextField(
            controller: _taskController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Digite o novo título'),
            onSubmitted: (_) => _performEditTask(task, parentTask: parentTask, subtaskIndex: subtaskIndex),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Salvar'),
              onPressed: () => _performEditTask(task, parentTask: parentTask, subtaskIndex: subtaskIndex),
            ),
          ],
        );
      },
    );
  }

  // Método para efetivamente editar a tarefa no Hive
  Future<void> _performEditTask(Task task, {Task? parentTask, int? subtaskIndex}) async {
    if (_taskController.text.isEmpty) return;

    if (parentTask != null && subtaskIndex != null) {
      // Editando uma subtarefa
      final updatedSubtask = Task(
        title: _taskController.text,
        isCompleted: task.isCompleted,
      );

      // Criar uma nova lista de subtarefas com a subtarefa atualizada
      final updatedSubtasks = List<Task>.from(parentTask.subtasks);
      updatedSubtasks[subtaskIndex] = updatedSubtask;

      // Atualizar a tarefa pai com a nova lista de subtarefas
      final updatedParentTask = Task(
        title: parentTask.title,
        isCompleted: parentTask.isCompleted,
        hiveKey: parentTask.hiveKey,
        subtasks: updatedSubtasks,
        isExpanded: parentTask.isExpanded,
      );

      if (parentTask.hiveKey != null) {
        await _hiveService.updateTask(parentTask.hiveKey!, updatedParentTask);
      }
    } else {
      // Editando uma tarefa principal
      if (task.hiveKey != null) {
        final updatedTask = Task(
          title: _taskController.text,
          isCompleted: task.isCompleted,
          hiveKey: task.hiveKey,
          subtasks: task.subtasks,
          isExpanded: task.isExpanded,
        );
        await _hiveService.updateTask(task.hiveKey!, updatedTask);
      }
    }

    _taskController.clear();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  // Método para mostrar o diálogo de adicionar subtarefa
  void _showAddSubtaskDialog(Task parentTask) {
    _taskController.clear(); // Limpar o controller
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nova Subtarefa para "${parentTask.title}"'),
          content: TextField(
            controller: _taskController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Digite o título da subtarefa'),
            onSubmitted: (_) => _performAddSubtask(parentTask),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Adicionar Subtarefa'),
              onPressed: () => _performAddSubtask(parentTask),
            ),
          ],
        );
      },
    );
  }

  // Método para efetivamente adicionar a subtarefa
  Future<void> _performAddSubtask(Task parentTask) async {
    if (_taskController.text.isNotEmpty && parentTask.hiveKey != null) {
      final newSubtask = Task(title: _taskController.text);
      // Adicionar a nova subtarefa à lista de subtarefas da tarefa pai
      parentTask.subtasks.add(newSubtask);

      // Criar uma nova instância da tarefa pai com a lista de subtarefas atualizada
      // É importante criar uma nova instância para que o Hive detecte a mudança.
      final updatedParentTask = Task(
        title: parentTask.title,
        isCompleted: parentTask.isCompleted,
        hiveKey: parentTask.hiveKey,
        subtasks: List<Task>.from(parentTask.subtasks),
        isExpanded: parentTask.isExpanded,
      );

      await _hiveService.updateTask(parentTask.hiveKey!, updatedParentTask);
      _taskController.clear();
      if (mounted) {
        Navigator.of(context).pop(); // Fecha o diálogo
      }
      // _loadTasks(); // Não é mais necessário devido ao watchTasks
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tarefas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(
              _showCompletedTasks ? Icons.visibility_off : Icons.visibility,
            ),
            tooltip: _showCompletedTasks ? 'Ocultar Concluídas' : 'Mostrar Concluídas',
            onPressed: _toggleShowCompletedTasks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TaskList(
              tasks: _tasks,
              onTaskCompletedChanged: _onTaskCompletedChanged,
              showCompletedTasks: _showCompletedTasks,
              onTaskDeleted: _deleteTask,
              onTaskEdited: _showEditTaskDialog,
              onAddTaskSubtask: _showAddSubtaskDialog,
              onTaskExpandToggle: _onTaskExpandToggle,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Adicionar Tarefa',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}