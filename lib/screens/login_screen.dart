import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


import 'admin_dashboard_screen.dart'; // بعداً برای user و supervisor هم اضافه می‌شه

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      //final url = Uri.parse('http://localhost:5000/api/auth/login');
      final url = Uri.parse('http://85.185.241.3:5000/api/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('status: ${response.statusCode}');
      print('body: ${response.body}');


      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['token'] != null) {
        final role = data['user']['role'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        if (role == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
          
        }
        else if(role == 3){
          final data = jsonDecode(response.body);
          final userId = data['user']['id'];
          Navigator.pushReplacementNamed(context, '/userDashboard', arguments: {'userId': userId});

        }
         else {
          // برای نقش‌های دیگر بعداً مدیریت می‌کنیم
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('نقش شما پشتیبانی نمی‌شود')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'ورود ناموفق')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در اتصال به سرور')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ورود')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ایمیل'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value != null && value.contains('@')
                    ? null
                    : 'ایمیل معتبر وارد کنید',
                onSaved: (value) => email = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'رمز عبور'),
                obscureText: true,
                validator: (value) => value != null && value.length >= 6
                    ? null
                    : 'رمز عبور حداقل ۶ کاراکتر باشد',
                onSaved: (value) => password = value!,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('ورود'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
