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

    final response = await http.get(
      Uri.parse("$baseUrl/dashboard"),
      headers: {"Authorization": "Bearer $token"},
    );

    return jsonDecode(response.body);
  }
  static Future<List<TaskModel>> getTasks() async {
    final token = await SecureStorage.getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/tasks"),
      headers: {"Authorization": "Bearer $token"},
    );

    final List data = jsonDecode(response.body)['data'];
    return data.map((e) => TaskModel.fromJson(e)).toList();
  }

  // Update status task
  static Future<bool> updateTaskStatus(int id, int newStatus) async {
    final token = await SecureStorage.getToken();

    final response = await http.put(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: {"Authorization": "Bearer $token"},
      body: {"status": newStatus.toString()},
    );

    return response.statusCode == 200;
  }

}
