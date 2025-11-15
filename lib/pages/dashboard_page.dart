// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../api/api_service.dart';
import '../models/task_model.dart';

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
    initHive();
    monitorConnection();
  }

  initHive() async {
    taskBox = await Hive.openBox<TaskModel>("tasks");
    await loadData();
  }

  // cek koneksi dan sync otomatis
  monitorConnection() {
    Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        syncData();
      }
    });
  }

  // ambil data
  loadData() async {
    final connectivity = await Connectivity().checkConnectivity();

    if (connectivity != ConnectivityResult.none) {
      // ONLINE → ambil dari API
      final apiTasks = await ApiService.getTasks();
      setState(() => tasks = apiTasks);

      // simpan ke hive
      taskBox.clear();
      for (var t in apiTasks) {
        taskBox.put(t.id, t);
      }
    } else {
      // OFFLINE → ambil dari Hive
      setState(() => tasks = taskBox.values.cast<TaskModel>().toList());
    }
  }

  // sync update status offline → server
  syncData() async {
    for (var t in taskBox.values) {
      await ApiService.updateTaskStatus(t.id, t.status);
    }
  }

  // update status
  updateStatus(TaskModel task) async {
    int newStatus = (task.status + 1) % 3;

    task.status = newStatus;
    taskBox.put(task.id, task);
    setState(() {});

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity != ConnectivityResult.none) {
      await ApiService.updateTaskStatus(task.id, newStatus);
    }
  }

  statusLabel(int s) {
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
      appBar: AppBar(title: Text("Dashboard Task")),
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
