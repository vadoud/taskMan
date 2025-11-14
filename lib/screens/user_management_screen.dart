import 'package:flutter/material.dart';
import 'package:taskman_ui/screens/user_form_screen.dart';
import 'package:taskman_ui/services/http_service.dart';

class User {
  final int id;
  final String name;
  final String email;
  final int roleId;
  final String roleName;
  final String? lastLogin;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roleId,
    required this.roleName,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      roleId: json['role_id'],
      roleName: json['role'],
      lastLogin: json['last_login'],
    );
  }
}

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    _usersFuture = HttpService.fetchUsers().then(
      (jsonList) => jsonList.map((json) => User.fromJson(json)).toList(),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadUsers();
    });
  }

  void _openAddUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserFormScreen()),
    );
    if (result == true) _refresh();
  }

  void _openEditUser(User user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserFormScreen(user: {
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'role_id': user.roleId,
        }),
      ),
    );
    if (result == true) _refresh();
  }

  void _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف کاربر'),
        content: Text('آیا از حذف "${user.name}" مطمئن هستید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لغو')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await HttpService.deleteUser(user.id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کاربر حذف شد')));
        _refresh();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('خطا در حذف کاربر:\n$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    


    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت کاربران'),
        actions: [
          IconButton(onPressed: _openAddUser, icon: const Icon(Icons.add)),
        ],
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطا در دریافت کاربران:\n${snapshot.error}'));
          }

          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(child: Text('هیچ کاربری یافت نشد.'));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(user.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        Text('نقش: ${user.roleName}'),
                        if (user.lastLogin != null)
                          Text('آخرین ورود: ${user.lastLogin}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _openEditUser(user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUser(user),
                        ),
                      ],
                    ),
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
