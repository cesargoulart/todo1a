import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Importa a HomeScreen
import 'package:hive_flutter/hive_flutter.dart';
import 'models/task.dart'; // Importa a classe Task
// O TaskAdapter é gerado em task.g.dart, que é uma part de task.dart

void main() async { // Tornar o main assíncrono
  WidgetsFlutterBinding.ensureInitialized(); // Garantir a inicialização dos widgets
  await Hive.initFlutter(); // Inicializar o Hive
  Hive.registerAdapter(TaskAdapter()); // Registrar o adapter
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove o banner de debug
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light, // Especifica o brilho para o tema claro
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal, // Uma cor diferente para o tema escuro
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark, // Força o tema escuro
      home: const HomeScreen(), // Usa a HomeScreen como tela inicial
    );
  }
}
