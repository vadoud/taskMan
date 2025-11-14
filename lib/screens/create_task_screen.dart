import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String priority = '1';
  String? assignedTo;
  bool isSubmitting = false;

  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final response = await http.get(Uri.parse('http://85.185.241.3:5000/api/users'));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        users = List<Map<String, dynamic>>.from(data);
      });
    }
  }

  Future<void> _submitTask() async {
  if (!_formKey.currentState!.validate() || assignedTo == null) return;
  _formKey.currentState!.save();
  setState(() => isSubmitting = true);

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  

  final response = await http.post(
    Uri.parse('http://85.185.241.3:5000/api/tasks'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode({
      'title': title,
      'description': description,
      'priority': int.parse(priority),
      'assignedTo': int.parse(assignedTo!),
    }),
  );

  print('status: ${response.statusCode}');
  print('body: ${response.body}');

  setState(() => isSubmitting = false);

  if (response.statusCode == 201) {
    Navigator.pop(context, true);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('خطا در ایجاد تسک')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ایجاد تسک جدید')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'عنوان تسک'),
                validator: (value) => value != null && value.isNotEmpty ? null : 'اجباری',
                onSaved: (value) => title = value!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'توضیحات'),
                maxLines: 3,
                onSaved: (value) => description = value ?? '',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'اولویت (۱ = بالا)'),
                value: priority,
                items: ['1', '2', '3']
                    .map((p) => DropdownMenuItem(value: p, child: Text('اولویت $p')))
                    .toList(),
                onChanged: (val) => setState(() => priority = val!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'ارجاع به کاربر'),
                value: assignedTo,
                items: users
                    .where((u) => u['role_id'] == 3)
                    .map((user) => DropdownMenuItem(
                          value: user['id'].toString(),
                          child: Text(user['name'] ?? user['email']),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => assignedTo = val),
              ),
              const SizedBox(height: 20),
              isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitTask,
                      child: const Text('ثبت تسک'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
