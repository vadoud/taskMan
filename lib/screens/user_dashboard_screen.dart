import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskman_ui/screens/task_detail_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  List<dynamic> tasks = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('📦 Token: $token');

      final response = await http.get(
        Uri.parse('http://85.185.241.3:5000/api/tasks/assigned'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('🔍 status: ${response.statusCode}');
      print('🔍 body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 نوع داده data: ${data.runtimeType}');

        if (data is List) {
          setState(() {
            tasks = data;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'خطا: فرمت داده دریافتی نادرست است';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'خطا در دریافت تسک‌ها: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '❌ خطا در ارتباط با سرور: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int currentUserId = args['userId'];
    //final bool isAdmin = args['isAdmin'] ?? false;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('داشبورد کاربر'),
          actions: [
            PopupMenuButton<String>(itemBuilder: (context) => const [
              PopupMenuItem(value: 'changePassword', child: Text('تغییر رمز عبور')),
              PopupMenuItem(value: 'logout', child: Text('خروج')),
                  
            ],
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushReplacementNamed(context, '/login');
              } else if (value == 'changePassword') {
                Navigator.pushNamed(
                  context,
                  '/changePassword',
                  arguments: {'userId': currentUserId, 'isAdmin': false},
                );
              }
            },
            
            ),
          
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text(errorMessage!))
                : tasks.isEmpty
                    ? const Center(child: Text('هیچ تسکی برای شما ثبت نشده است.'))
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(task['title'] ?? ''),
                              subtitle: Text(task['description'] ?? ''),
                              trailing: Text(task['status'] ?? ''),
                              onTap: () {
                                Navigator.push(
                                context,
                                MaterialPageRoute(
                                 builder: (_) => TaskDetailScreen(task: task),
                                  ),
  );
}

                              
                            ),
                            
                          );
                          
                        },
                        
                      ),
      ),
    );
  }
}
