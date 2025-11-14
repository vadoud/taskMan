import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  // در emulator آدرس 10.0.2.2 = localhost سیستم
  static const String baseUrl = 'http://85.185.241.3:5000/api';

static Future<List<dynamic>> fetchUsers() async {
  final url = Uri.parse('$baseUrl/users');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('خطا در دریافت لیست کاربران');
  }
}

static Future<void> createUser(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/users');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode != 201) {
      throw Exception(jsonDecode(res.body)['message'] ?? 'خطا در افزودن کاربر');
    }
  }

  static Future<void> updateUser(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final res = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['message'] ?? 'خطا در ویرایش کاربر');
    }
  }

static Future<void> deleteUser(int id) async {
  final url = Uri.parse('$baseUrl/users/$id');
  final response = await http.delete(url);
  if (response.statusCode != 200) {
    throw Exception('خطا در حذف کاربر');
  }
}

  static Future<Map<String, dynamic>> fetchStats() async {
    final url = Uri.parse('$baseUrl/stats');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('خطا در دریافت آمار از سرور');
    }
  }

static Future<List<dynamic>> fetchAdminTasks() async {
  final response = await http.get(Uri.parse('http://85.185.241.3:5000/api/tasks/admin'));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('خطا در دریافت لیست تسک‌ها');
  }
}



  // سایر توابع (login, register...) می‌تونن اینجا اضافه بشن
}
