import 'package:flutter/material.dart';
import 'package:input_mahasiswa/login.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), 'mahasiswa_db.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE mahasiswa(id INTEGER PRIMARY KEY, nama TEXT, nim TEXT)',
      );
    },
    version: 1,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Login(),
    );
  }
}
