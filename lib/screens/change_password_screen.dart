import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePasswordScreen extends StatefulWidget {
  final int userId; // شناسه کاربر (از Session یا Token میگیری)
  final bool isAdmin; // آیا مدیر هست یا کاربر عادی

  const ChangePasswordScreen({super.key, required this.userId, this.isAdmin = false});
  
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _loading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final url = Uri.parse("http://85.185.241.3:5000/api/users/${widget.userId}/password");

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "currentPassword": widget.isAdmin ? null : _currentPassController.text,
        "newPassword": _newPassController.text,
      }),
    );

    print("Response code: ${response.statusCode}");
    print("Response body: ${response.body}");
    print("Sending userId: ${widget.userId}");
    print("Current: ${_currentPassController.text}");
print("New: ${_newPassController.text}");

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ رمز عبور با موفقیت تغییر کرد")),
      );
      Navigator.pop(context);
    } else {
      final res = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ خطا: ${res['message']}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تغییر رمز عبور")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!widget.isAdmin) // فقط برای کاربر عادی
                TextFormField(
                  controller: _currentPassController,
                  decoration: InputDecoration(labelText: "رمز عبور فعلی"),
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? "رمز عبور فعلی را وارد کنید" : null,
                ),
              TextFormField(
                controller: _newPassController,
                decoration: InputDecoration(labelText: "رمز عبور جدید"),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? "رمز باید حداقل ۶ کاراکتر باشد" : null,
              ),
              TextFormField(
                controller: _confirmPassController,
                decoration: InputDecoration(labelText: "تکرار رمز عبور جدید"),
                obscureText: true,
                validator: (value) =>
                    value != _newPassController.text ? "رمزها یکسان نیستند" : null,
              ),
              SizedBox(height: 20),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _changePassword,
                      child: Text("تغییر رمز"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
