import 'package:flutter/material.dart';
import 'utils/secure_storage.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';

void main() {
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
      home: FutureBuilder(
        future: checkLogin(),
        builder: (ctx, snap) {
          if (!snap.hasData) return CircularProgressIndicator();

          return snap.data == true
              ? DashboardPage()
              : LoginPage();
        },
      ),
    );
  }
}
