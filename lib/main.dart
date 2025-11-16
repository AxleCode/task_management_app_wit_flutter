import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // <<-- penting
import 'package:hive/hive.dart';

import 'utils/secure_storage.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'models/task_model.dart'; // impor model agar TaskModelAdapter dikenali

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive khusus Flutter
  await Hive.initFlutter();

  // Register adapter (TaskModelAdapter didefinisikan di task_model.g.dart)
  Hive.registerAdapter(TaskModelAdapter());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<bool> checkLogin() async {
    final token = await SecureStorage.getToken();
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<bool>(
        future: checkLogin(),
        builder: (ctx, snap) {
          // Tampilkan loading yang rapi saat Future belum selesai
          if (snap.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Jika error pada Future, tampilkan pesan (opsional)
          if (snap.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snap.error}')),
            );
          }

          // Jika sudah ada data, cek login
          final loggedIn = snap.data ?? false;
          return loggedIn ? DashboardPage() : LoginPage();
        },
      ),
    );
  }
}
