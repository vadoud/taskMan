import 'package:flutter/material.dart';
import 'package:taskman_ui/services/http_service.dart';

class UserFormScreen extends StatefulWidget {
  final Map<String, dynamic>? user; // اگر null بود یعنی افزودن
  
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String password = '';
  int roleId = 3;

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      name = widget.user!['name'];
      email = widget.user!['email'];
      roleId = widget.user!['role_id'];
    }
  }

  void _submit() async {
  if (!_formKey.currentState!.validate()) return;
  _formKey.currentState!.save();

  try {
    if (isEdit) {
      final data = {
    'name': name,
    'role_id': roleId,
  };

  if (password.isNotEmpty) {
    data['password'] = password; // فقط اگر رمز وارد شد
  }

  await HttpService.updateUser(widget.user!['id'], data);
} else {
  await HttpService.createUser({
    'name': name,
    'email': email,
    'password': password,
    'role_id': roleId,
  });
    }
    Navigator.pop(context, true);
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('❌ خطا:\n$e')));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'ویرایش کاربر' : 'افزودن کاربر')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'نام'),
                validator: (val) => val == null || val.trim().isEmpty ? 'نام الزامی است' : null,
                onSaved: (val) => name = val!.trim(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: email,
                decoration: const InputDecoration(labelText: 'ایمیل'),
                validator: (val) => val != null && val.contains('@') ? null : 'ایمیل معتبر نیست',
                onSaved: (val) => email = val!.trim(),
                enabled: !isEdit,
              ),
              const SizedBox(height: 12),
              // فیلد رمز عبور
TextFormField(
  decoration: InputDecoration(
    labelText: isEdit ? 'رمز عبور جدید (اختیاری)' : 'رمز عبور',
  ),
  obscureText: true,
  validator: (val) {
    if (!isEdit && (val == null || val.length < 6)) {
      return 'رمز عبور حداقل ۶ کاراکتر باشد';
    }
    return null;
  },
  onSaved: (val) => password = val!.trim(),
),

              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: roleId,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('مدیر')),
                  DropdownMenuItem(value: 2, child: Text('ناظر')),
                  DropdownMenuItem(value: 3, child: Text('کاربر عادی')),
                ],
                onChanged: (val) => setState(() => roleId = val!),
                decoration: const InputDecoration(labelText: 'نقش'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isEdit ? 'ذخیره تغییرات' : 'افزودن کاربر'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
