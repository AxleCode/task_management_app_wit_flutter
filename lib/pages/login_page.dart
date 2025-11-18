import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../utils/secure_storage.dart';
import 'dashboard_page.dart';
import 'register_page.dart';
import 'package:hive/hive.dart';

class LoginPage extends StatefulWidget {
  final String? defaultEmail;

  LoginPage({this.defaultEmail}); // <-- tambahkan ini

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.defaultEmail != null) {
      email.text = widget.defaultEmail!; // <-- isi default email otomatis
    }
  }

  Future<void> login() async {
  setState(() => loading = true);

  final res = await ApiService.login(email.text, password.text);

  setState(() => loading = false);

  if (res['status'] == true) {

      final token = res['data']['token'];
      final name = res['data']['name'];

      await SecureStorage.saveToken(token);

      var userBox = await Hive.openBox("userBox");
      await userBox.put("name", name);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardPage()),
      );
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Login gagal")),
      );
    }
  }


  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: email, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: password, obscureText: true, decoration: InputDecoration(labelText: "Password")),
            const SizedBox(height: 20),
            loading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: login, child: Text("Login")),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage()));
              },
              child: Text("Belum punya akun? Register"),
            )
          ],
        ),
      ),
    );
  }
}
