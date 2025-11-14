import 'package:flutter/material.dart';
import 'package:taskman_ui/widgets/animated_gauge_stat_card.dart';
import 'package:taskman_ui/services/http_service.dart';

class Stats {
  final int userCount;
  final int totalTasks;
  final int assignedTasks;
  final int completedTasks;
  final double avgDuration;

  Stats({
    required this.userCount,
    required this.totalTasks,
    required this.assignedTasks,
    required this.completedTasks,
    required this.avgDuration,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      userCount: json['userCount'],
      totalTasks: json['totalTasks'],
      assignedTasks: json['assignedTasks'],
      completedTasks: json['completedTasks'],
      avgDuration: (json['avgDuration'] as num).toDouble(),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Stats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    _statsFuture = HttpService.fetchStats().then((data) => Stats.fromJson(data));
  }


  void _navigateTo(String title) async {
    print('Tapped: $title');
    if (title == 'مدیریت کاربران') {
      final result = await Navigator.pushNamed(context, '/userManagement');
      if (result == true) {
        setState(() {
          _loadStats();
        });
      }
    } else if (title == 'ایجاد تسک جدید') {
    await Navigator.pushNamed(context, '/createTask');
  }
  else if (title == 'مدیریت تسک‌ها') {
  Navigator.of(context, rootNavigator: true).pushNamed('/adminTasks');

}

  }
  

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت تسک'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'refresh') {
                setState(() => _loadStats());
              } else if (value == 'logout') {
                _logout();
              }
              else if (value == 'changePassword') {
        Navigator.pushNamed(
          context,
          '/changePassword',
          arguments: {
            'userId': 1,   // 👈 اینجا باید id مدیر لاگین‌شده رو بزاری
            'isAdmin': true,
          },
        );
      }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'refresh', child: Text('تازه‌سازی آمار')),
              PopupMenuItem(value: 'changePassword', child: Text('تغییر رمز عبور')),
              PopupMenuItem(value: 'logout', child: Text('خروج')),
            ],
          ),
        ],
        
      ),


      
      body: FutureBuilder<Stats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطا در دریافت آمار: ${snapshot.error}'));
          }

          final stats = snapshot.data!;

          return Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'آمار کلی',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'تازه‌سازی آمار',
                      onPressed: () => setState(() => _loadStats()),
                    ),
                  ],
                  
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    AnimatedGaugeStatCard(
  title: 'تعداد کاربران',
  icon: Icons.person,
  value: stats.userCount,
  maxValue: 100,
  color: Colors.blue,
  backgroundColor: Colors.white,
  borderColor: Colors.indigo,
),
                    
                    AnimatedGaugeStatCard(
  title: 'تسک‌های ایجاد شده',
  icon: Icons.create,
  value: stats.totalTasks,
  maxValue: 100,
  color: Colors.deepPurple,
  backgroundColor: Colors.white,
  borderColor: Colors.indigo,
),
                    
                    AnimatedGaugeStatCard(
  title: 'تسک‌های ارجاع شده',
  icon: Icons.send,
  value: stats.assignedTasks,
  maxValue: stats.totalTasks,
  color: Colors.orange,
  backgroundColor: Colors.white,
  borderColor: Colors.indigo,
),

                    
                    AnimatedGaugeStatCard(
  title: 'تسک‌های پایان‌یافته',
  icon: Icons.check_circle,
  value: stats.completedTasks,
  maxValue: stats.totalTasks,
  color: Colors.green,
  backgroundColor: Colors.white,
  borderColor: Colors.indigo,
),

                    
                    AnimatedGaugeStatCard(
  title: 'میانگین زمان تسک',
  icon: Icons.av_timer,
  value: stats.avgDuration.toInt(),
  maxValue: 24,
  color: Colors.teal,
  backgroundColor: Colors.white,
  borderColor: Colors.indigo,
),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'گزینه‌های مدیریتی',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: [
                    _buildActionCard('مدیریت کاربران', Icons.people),
                    _buildActionCard('مدیریت تسک‌ها', Icons.assignment),
                    _buildActionCard('مشاهده مستندات', Icons.folder),
                    _buildActionCard('گزارش عملکرد', Icons.bar_chart),
                    _buildActionCard('ایجاد تسک جدید', Icons.add_task),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(6),
                child: Text(
                  'طراحی شده توسط مصطفی مرادی',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon) {
    return GestureDetector(
      onTap: () => _navigateTo(title),
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.85),
          border: Border.all(color: Colors.indigo.shade400, width: 0.8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.indigo),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
