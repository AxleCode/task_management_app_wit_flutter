import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../api/api_service.dart';
import '../models/task_model.dart';
import '../utils/secure_storage.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<TaskModel> tasks = [];
  late Box taskBox;

  @override
  void initState() {
    super.initState();
    initHive(); // hanya ini, monitorConnection dipindah
  }

  String userName = "";

  // --- HIVE INIT ---
  Future<void> initHive() async {
    taskBox = await Hive.openBox<TaskModel>("tasks");

    var userBox = await Hive.openBox("userBox");
    setState(() {
      userName = userBox.get("name") ?? "";
    });

    await loadData();
    monitorConnection(); // <-- DIPANGGIL SETELAH taskBox siap
  }

  // LOGOUT
  Future<void> logout() async {
    var userBox = await Hive.openBox("userBox"); // box penyimpanan login
    await userBox.clear(); // hapus data login
    await userBox.close();

    await SecureStorage.deleteToken(); // hapus token

    // pindah ke LoginPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  // cek koneksi dan sync otomatis
  void monitorConnection() {
    Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        // tambahkan pengaman jika taskBox belum siap (extra safety)
        if (!taskBox.isOpen) return;

        syncData();
      }
    });
  }

  // ambil data
  Future<void> loadData() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();

      if (connectivity != ConnectivityResult.none) {
        // ONLINE → ambil dari API
        final apiTasks = await ApiService.getTasks();
        setState(() => tasks = apiTasks);

        // simpan ke hive
        await taskBox.clear();
        for (var t in apiTasks) {
          taskBox.put(t.id, t);
        }
      } else {
        // OFFLINE → ambil dari Hive
        setState(() => tasks = taskBox.values.cast<TaskModel>().toList());
      }
    } catch (e) {
      print("Error loadData: $e");
    }
  }

  // sync update status offline → server
  Future<void> syncData() async {
    if (!taskBox.isOpen) return; // extra safety

    for (var t in taskBox.values.cast<TaskModel>()) {
      await ApiService.updateTaskStatus(t.id, t.status);
    }
  }

  // update status
  Future<void> updateStatus(TaskModel task) async {
    int newStatus = (task.status + 1) % 3;

    task.status = newStatus;
    taskBox.put(task.id, task);
    setState(() {});

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.none) {
      await ApiService.updateTaskStatus(task.id, newStatus);
    }
  }

  String statusLabel(int s) {
    switch (s) {
      case 0: return "Pending";
      case 1: return "In-Progress";
      case 2: return "Done";
      default: return "-";
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard Task - $userName"),

        // === TOMBOL LOGOUT ===
        actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: logout,
            ),
          ],
        ),
        
        body: tasks.isEmpty
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => loadData(),
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (_, i) {
                  final t = tasks[i];
                  return Card(
                    child: ListTile(
                      title: Text(t.title),
                      subtitle: Text("${t.description}\nStatus: ${statusLabel(t.status)}"),
                      trailing: IconButton(
                        icon: Icon(Icons.sync),
                        onPressed: () => updateStatus(t),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
