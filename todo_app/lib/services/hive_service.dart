import 'package:hive/hive.dart';
import '../models/task.dart';

class HiveService {
  static const String _boxName = 'tasksBox';

  // Abrir a box de tarefas
  Future<Box<Task>> _openBox() async {
    return await Hive.openBox<Task>(_boxName);
  }

  // Adicionar uma nova tarefa
  Future<void> addTask(Task task) async {
    final box = await _openBox();
    await box.add(task);
  }

  // Obter todas as tarefas
  Future<List<Task>> getAllTasks() async {
    final box = await _openBox();
    // Retorna os valores como uma lista. Se a box estiver vazia, retorna uma lista vazia.
    return box.values.toList();
  }

  // Atualizar uma tarefa existente
  // Para atualizar, precisamos da chave da tarefa no Hive.
  // Uma forma comum é armazenar a chave Hive na própria Task ou passar o índice/chave.
  // Por simplicidade, vamos assumir que a Task tem uma propriedade 'key' ou que a encontramos pelo título (menos ideal para produção).
  // Para uma implementação mais robusta, a Task deveria ter um campo para a chave do Hive.
  // Neste exemplo, vamos atualizar pelo índice, o que requer que a ordem não mude drasticamente
  // ou que você tenha uma forma de mapear a Task para sua chave no Hive.
  Future<void> updateTask(dynamic key, Task task) async {
    final box = await _openBox();
    await box.put(key, task);
  }

  // Deletar uma tarefa
  Future<void> deleteTask(dynamic key) async {
    final box = await _openBox();
    await box.delete(key);
  }

  // Fechar a box (opcional, o Hive gerencia isso bem, mas pode ser útil em alguns cenários)
  Future<void> closeBox() async {
    final box = await Hive.openBox<Task>(_boxName);
    await box.close();
  }

  // Método para observar mudanças na box (útil para atualizar a UI reativamente)
  Stream<BoxEvent> watchTasks() async* {
    final box = await _openBox();
    yield* box.watch();
  }
}