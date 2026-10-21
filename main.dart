import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ⚠️ لو هتجرب التطبيق على موبايل تاني غير اللي فيه الترمكس، غير الـ IP ده لـ IP الهوت سبوت بتاعك (مثلاً 192.168.43.1)
const String SERVER_IP = "127.0.0.1"; 
const String SERVER_URL = "http://$SERVER_IP:8080";

void main() {
  runApp(const SpiderApp());
}

class SpiderApp extends StatelessWidget {
  const SpiderApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spider Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFF00FF41),
      ),
      home: const LoginScreen(),
    );
  }
}

// 1. شاشة تسجيل الدخول
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userCtrl = TextEditingController(text: "admin");
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final response = await http.post(
        Uri.parse('$SERVER_URL/api/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": _userCtrl.text}),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['role'] == 'OWNER') {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const UserDashboard()));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('السيرفر مش متوصل. تأكد إنه شغال في الترمكس.')));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🕷️', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 20),
              const Text('SPIDER PRO', style: TextStyle(color: Color(0xFF00FF41), fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(
                controller: _userCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Username (admin / user)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              _loading 
                ? const CircularProgressIndicator(color: Color(0xFF00FF41))
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF41), minimumSize: const Size(double.infinity, 50)),
                    child: const Text('CONNECT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// 2. لوحة المستخدم
class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spider Pro - User'), backgroundColor: const Color(0xFF0A0A0A)),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        children: [
          _card(Icons.rocket_launch, 'Pump', Colors.greenAccent, () => _runPump(context)),
          _card(Icons.radar, 'Scrape', Colors.blueAccent, () {}),
          _card(Icons.terminal, 'Terminal', Colors.greenAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveTerminal()))),
          _card(Icons.shield, 'Anti-Ban', Colors.amberAccent, () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Emergency Stop!'))),
        backgroundColor: Colors.red,
        child: const Icon(Icons.warning),
      ),
    );
  }

  void _runPump(BuildContext context) async {
    try {
      await http.post(
        Uri.parse('$SERVER_URL/api/pump'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": 1, "target": "@test_group", "amount": 5}),
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تشغيل الماكينة! افتح Terminal.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error connecting to server.')));
    }
  }

  Widget _card(IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// 3. لوحة الملك
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GOD MODE - OWNER'), backgroundColor: Colors.amber),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _statCard('Total Earnings', '\$25,400', Colors.greenAccent),
          _statCard('Total Users', '1,500', Colors.blueAccent),
          _statCard('Active Machines', '12', Colors.purpleAccent),
          _statCard('System Health', '100%', Colors.green),
        ],
      ),
    );
  }
  Widget _statCard(String title, String value, Color color) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.grey)),
        trailing: Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// 4. الشاشة السوداء
class LiveTerminal extends StatelessWidget {
  const LiveTerminal({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('LIVE TERMINAL', style: TextStyle(color: Color(0xFF00FF41))), backgroundColor: Colors.black),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('> [SYSTEM] Initializing connection...', style: TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace')),
            Text('> [SUCCESS] Connected to target.', style: TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace')),
            Text('> [LIVE] Added member @ahmed (1)', style: TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace')),
            Text('> [LIVE] Added member @sara (2)', style: TextStyle(color: Color(0xFF00FF41), fontFamily: 'monospace')),
            Text('> [WARNING] Flood detected...', style: TextStyle(color: Colors.orange, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }
}
