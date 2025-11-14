import 'package:flutter/material.dart';
import 'package:taskman_ui/services/http_service.dart';

class AdminTaskManagementScreen extends StatefulWidget {
  const AdminTaskManagementScreen({super.key});

  @override
  State<AdminTaskManagementScreen> createState() => _AdminTaskManagementScreenState();
}

class _AdminTaskManagementScreenState extends State<AdminTaskManagementScreen> {
  late Future<List<dynamic>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    _tasksFuture = HttpService.fetchAdminTasks();
  }

  Future<void> _refresh() async {
    setState(() => _loadTasks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت تسک‌ها')),
      body: FutureBuilder<List<dynamic>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطا در دریافت تسک‌ها:\n${snapshot.error}'));
          }

          final tasks = snapshot.data!;
          if (tasks.isEmpty) {
            return const Center(child: Text('هیچ تسکی یافت نشد.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(task['title'] ?? 'بدون عنوان'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ارجاع به: ${task['assigned_user'] ?? 'نامشخص'}'),
                        Text('اولویت: ${task['priority']}'),
                        Text('وضعیت: ${task['status']}'),
                        Text('تاریخ: ${task['timestamp'] ?? ''}'),
                      ],
                    ),
                    onTap: () {
                      // در آینده: نمایش جزئیات یا مستندات
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
