import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:taskman_ui/screens/user_management_screen.dart';
import 'package:taskman_ui/screens/user_dashboard_screen.dart';
import 'package:taskman_ui/screens/create_task_screen.dart';
import 'package:taskman_ui/screens/change_password_screen.dart';
import 'package:taskman_ui/screens/admin_task_management_screen.dart';

void main() {
  runApp(const MyApp());

  
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/userManagement': (context) => const UserManagementScreen(),
        '/userDashboard': (context) => const UserDashboardScreen(),
         '/createTask': (context) => const CreateTaskScreen(),
         '/adminTasks': (context) => const AdminTaskManagementScreen(),

         
        },
        onGenerateRoute: (settings) {
        if (settings.name == '/changePassword') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ChangePasswordScreen(
              userId: args['userId'],
              isAdmin: args['isAdmin'] ?? false,
            ),
          );
        }
        return null;
      },
    );
  }
}
