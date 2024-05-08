import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController nimController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  late Database db;
  List<Map<String, Object?>> mahasiswa = [];

  @override
  void initState() {
    super.initState();
    setupDatabase();
  }

  void setupDatabase() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'mahasiswa_db.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE mahasiswa(id INTEGER PRIMARY KEY, nama TEXT, nim TEXT)',
        );
      },
      version: 1,
    );

    retrieve();
  }

  void save() async {
    // Cek apakah ada duplikasi data sebelum menyimpan
    var existingData = mahasiswa.firstWhere(
      (element) => element['nim'] == nimController.text,
      orElse: () => {},
    );

    if (existingData.isNotEmpty) {
      // Update data yang sudah ada
      await db.update(
        'mahasiswa',
        {"nama": namaController.text, "nim": nimController.text},
        where: 'id = ?',
        whereArgs: [existingData['id']],
      );
    } else {
      // Tambah data baru
      await db.insert(
        'mahasiswa',
        {"nama": namaController.text, "nim": nimController.text},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    retrieve();
  }

  void retrieve() async {
    final List<Map<String, Object?>> queryResults = await db.query('mahasiswa');
    setState(() {
      mahasiswa = queryResults;
    });
  }

  void deleteRow(int id) async {
    await db.delete(
      'mahasiswa',
      where: 'id = ?',
      whereArgs: [id],
    );
    retrieve();
  }

  void navigateToEdit(Map<String, Object?> mahasiswaData) {
    Navigator.push(
      context as BuildContext,
      MaterialPageRoute(
        builder: (_) => Testingmhs(mahasiswaData: mahasiswaData),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
     backgroundColor: Color.fromARGB(255, 84, 137, 142),
    appBar: AppBar(title: Text("Input Data Mahasiswa")),
    body: Container(
      padding: EdgeInsets.all(20),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          TextField(
            controller: nimController,
            decoration: const InputDecoration(
              label: Text("NIM"),
            ),
          ),
          TextField(
            controller: namaController,
            decoration: const InputDecoration(
              label: Text("Nama Mahasiswa"),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              save();
            },
            child: Text("Simpan Data Mahasiswa"),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: IntrinsicWidth(
                child: DataTable(
                  columnSpacing: 38.0, // Sesuaikan dengan kebutuhan
                  columns: const [
                    DataColumn(label: Text('Nama')),
                    DataColumn(label: Text('Nim')),
                    DataColumn(label: Text('Aksi')),
                  ],
                  rows: mahasiswa.map((mahasiswaData) {
                    return DataRow(cells: [
                      DataCell(Text(mahasiswaData['nama'].toString())),
                      DataCell(Text(mahasiswaData['nim'].toString())),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => navigateToEdit(mahasiswaData),
                            child: Text('Edit'),
                          ),
                          IconButton(
                            onPressed: () => deleteRow(mahasiswaData['id'] as int),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Testingmhs({required Map<String, Object?> mahasiswaData}) {}}