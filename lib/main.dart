import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soroush Bot',
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E17),
        primaryColor: const Color(0xFF00FFAA),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1C2128),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
      home: const ServerLoginScreen(),
    );
  }
}

// ==================== ۱. لاگین سرور ====================
class ServerLoginScreen extends StatefulWidget {
  const ServerLoginScreen({super.key});
  @override
  State<ServerLoginScreen> createState() => _ServerLoginScreenState();
}

class _ServerLoginScreenState extends State<ServerLoginScreen> {
  final _ipController = TextEditingController(text: "185.211.58.189");
  final _rootController = TextEditingController(text: "root");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.dns, size: 80, color: Color(0xFF00FFAA)),
              const SizedBox(height: 30),
              const Text('اتصال به سرور', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: _ipController, decoration: const InputDecoration(labelText: 'آی‌پی سرور')),
              const SizedBox(height: 16),
              TextField(controller: _rootController, decoration: const InputDecoration(labelText: 'نام کاربری سرور (root)')),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AppLoginScreen()));
                  },
                  child: const Text('اتصال', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ۲. لاگین اپلیکیشن (Javad) ====================
class AppLoginScreen extends StatefulWidget {
  const AppLoginScreen({super.key});
  @override
  State<AppLoginScreen> createState() => _AppLoginScreenState();
}

class _AppLoginScreenState extends State<AppLoginScreen> {
  final _userController = TextEditingController(text: "Javad");
  final _passController = TextEditingController(text: "Relpi");
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('http://185.211.58.189:8000/api/app/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'username': _userController.text, 'password': _passController.text}),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در اتصال به سرور')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text('ورود به پنل مدیریت', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(controller: _userController, decoration: const InputDecoration(labelText: 'نام کاربری')),
              const SizedBox(height: 16),
              TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: 'رمز عبور')),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA)),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.black) : const Text('ورود', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ۳. داشبورد اصلی ====================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<String> accounts = []; // شماره اکانت‌های اضافه شده

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RP Bot', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
      body: accounts.isEmpty 
          ? const Center(child: Text('هیچ اکانتی وجود ندارد. + را بزنید'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                return Card(
                  color: const Color(0xFF131A22),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(accounts[index], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Row(children: [
                      Icon(Icons.circle, color: Colors.greenAccent, size: 10),
                      SizedBox(width: 5),
                      Text('در حال اجرا', style: TextStyle(color: Colors.greenAccent)),
                    ]),
                    trailing: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AccountDetailScreen(phone: accounts[index])));
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        onPressed: () async {
          final newPhone = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAccountScreen()));
          if (newPhone != null) {
            setState(() { accounts.add(newPhone); });
          }
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

// ==================== ۴. افزودن اکانت ====================
class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});
  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;
  String _hash = "";

  Future<void> _handleRequest() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('http://185.211.58.189:8000/api/login/request'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'phone': _phoneController.text}),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        setState(() { _isOtpSent = true; _hash = data['hash']; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کد ارسال شد')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در اتصال')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _handleVerify() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('http://185.211.58.189:8000/api/login/verify'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'phone': _phoneController.text, 'code': _codeController.text, 'phone_code_hash': _hash}),
      );
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        Navigator.pop(context, _phoneController.text); // برگشت به داشبورد با شماره جدید
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در اتصال')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('افزودن اکانت')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'شماره تلفن با 0 (مثال: 09123456789)')),
            if (_isOtpSent) ...[
              const SizedBox(height: 16),
              TextField(controller: _codeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'کد تایید')),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA)),
                onPressed: _isLoading ? null : (_isOtpSent ? _handleVerify : _handleRequest),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.black) 
                  : Text(_isOtpSent ? 'تایید و ورود' : 'درخواست کد', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ۵. جزئیات اکانت (منوی عملیات) ====================
class AccountDetailScreen extends StatelessWidget {
  final String phone;
  const AccountDetailScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(phone)),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildBtn(context, 'اسپم', Icons.email, SpamScreen(phone: phone)),
          _buildBtn(context, 'تسک‌ها', Icons.settings, const TasksScreen()),
          _buildBtn(context, 'ریپلای', Icons.chat, const Center(child: Text('به زودی...'))),
          _buildBtn(context, 'فوروارد', Icons.forward, const Center(child: Text('به زودی...'))),
        ],
      ),
    );
  }

  Widget _buildBtn(BuildContext context, String title, IconData icon, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF131A22), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.withOpacity(0.3))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, size: 40, color: Colors.white), const SizedBox(height: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))],
        ),
      ),
    );
  }
}

// ==================== ۶. صفحه اسپم ====================
class SpamScreen extends StatefulWidget {
  final String phone;
  const SpamScreen({super.key, required this.phone});
  @override
  State<SpamScreen> createState() => _SpamScreenState();
}

class _SpamScreenState extends State<SpamScreen> {
  final _text = TextEditingController();
  final _target = TextEditingController();
  final _count = TextEditingController(text: "50");
  final _speed = TextEditingController(text: "1000");

  void _startSpam() async {
    try {
      final res = await http.post(
        Uri.parse('http://185.211.58.189:8000/api/task/start'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "account_phone": widget.phone,
          "task_id": DateTime.now().millisecondsSinceEpoch.toString(),
          "task_type": "spam",
          "target_chat": _target.text,
          "text": _text.text,
          "count": int.parse(_count.text),
          "speed": int.parse(_speed.text)
        }),
      );
      final data = jsonDecode(res.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      if(data['status'] == 'success') Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خطا در ارتباط با سرور')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیم اسپم')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _text, maxLines: 4, decoration: const InputDecoration(labelText: 'متن اسپم')),
            const SizedBox(height: 16),
            TextField(controller: _target, decoration: const InputDecoration(labelText: 'آیدی یا لینک گروه مقصد')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: _count, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'تعداد')),
                ),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _speed, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سرعت (ms)'))),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA)),
                onPressed: _startSpam,
                child: const Text('شروع اسپم', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ۷. صفحه تسک‌ها ====================
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final res = await http.get(Uri.parse('http://185.211.58.189:8000/api/tasks'));
      final data = jsonDecode(res.body);
      setState(() => tasks = data['tasks']);
    } catch (e) { print(e); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسک‌های فعال')),
      body: tasks.isEmpty 
          ? const Center(child: Text('هیچ تسکی در حال اجرا نیست'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, i) {
                final t = tasks[i];
                return Card(
                  color: const Color(0xFF131A22),
                  child: ListTile(
                    title: Text('${t['type']} - ${t['account']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        await http.post(Uri.parse('http://185.211.58.189:8000/api/task/stop/${t['id']}'));
                        _fetchTasks();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}