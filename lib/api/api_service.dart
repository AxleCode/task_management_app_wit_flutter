import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_storage.dart';
import '../models/task_model.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000/api"; // untuk emulator

  // LOGIN
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      body: {
        "email": email,
        "password": password,
      },
    );

    return jsonDecode(response.body);
  }

  // REGISTER
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {

    final response = await http.post(
      Uri.parse("$baseUrl/register"),
      body: {
        "name": name,
        "email": email,
        "password": password,
      },
    );

    return jsonDecode(response.body);
  }

  // GET DASHBOARD
  static Future<Map<String, dynamic>> getDashboard() async {
    final token = await SecureStorage.getToken();
    print("TOKEN ke dashboard = $token");
    final response = await http.get(
      Uri.parse("$baseUrl/dashboard"),
      headers: 
      {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    return jsonDecode(response.body);
  }

  static Future<List<TaskModel>> getTasks() async {
    final token = await SecureStorage.getToken();
    print("TOKEN ke list = $token");

    final response = await http.get(
      Uri.parse("$baseUrl/tasks"),
      headers: 
      {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    print("TASK RESPONSE: ${response.body}"); // Tambahkan ini

    final json = jsonDecode(response.body);

    if (json['data'] == null) {
      throw Exception("API tidak mengembalikan data list");
    }

    final List data = json['data'];
    return data.map((e) => TaskModel.fromJson(e)).toList();
  }

  // Update status task
  static Future<bool> updateTaskStatus(int id, int newStatus) async {
    final token = await SecureStorage.getToken();

    final response = await http.put(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: 
      {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
      body: {"status": newStatus.toString()},
    );

    return response.statusCode == 200;
  }

}
