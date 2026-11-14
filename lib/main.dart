import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

void main() {
  HttpOverrides.global = null;
  runApp(const MyApp());
}

const String SERVER_URL = 'http://185.211.58.189:8000';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Javad Bot',
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        primaryColor: const Color(0xFF00FFAA),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black54, 
          elevation: 0, 
          centerTitle: true,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF131A22).withOpacity(0.9), 
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00FFAA))),
        ),
      ),
      home: const ServerLoginScreen(),
    );
  }
}

// ==================== ویجت پس‌زمینه (عکس شما) ====================
class CustomBackground extends StatelessWidget {
  final Widget child;
  const CustomBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/bg.png', // مسیر عکس آپلود شده
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.4)), // لایه تیره برای خوانایی متن
        ),
        child,
      ],
    );
  }
}
// =========================================================

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
      body: CustomBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.dns, size: 80, color: Color(0xFF00FFAA)),
                const SizedBox(height: 30),
                const Text('اتصال به سرور', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 20),
                TextField(controller: _ipController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'آی‌پی سرور')),
                const SizedBox(height: 16),
                TextField(controller: _rootController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'نام کاربری سرور')),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA)),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AppLoginScreen())),
                    child: const Text('اتصال', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== ۲. لاگین اپلیکیشن ====================
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
        Uri.parse('$SERVER_URL/api/app/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'username': _userController.text, 'password': _passController.text}),
      ).timeout(const Duration(seconds: 10));
      
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: ${e.toString()}')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text('ورود به پنل مدیریت', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 30),
                TextField(controller: _userController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'نام کاربری')),
                const SizedBox(height: 16),
                TextField(controller: _passController, style: const TextStyle(color: Colors.white), obscureText: true, decoration: const InputDecoration(labelText: 'رمز عبور')),
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
  List<Map<String, String>> accounts = []; 
  int totalSent = 0;
  int runningTasks = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => _fetchStats());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStats() async {
    try {
      final res = await http.get(Uri.parse('$SERVER_URL/api/stats')).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          totalSent = data['total_sent'];
          runningTasks = data['running'];
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Javad Bot')),
      body: CustomBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard('$totalSent', 'Total sent', Icons.send, Colors.blue),
                    _buildStatCard('$runningTasks', 'Running', Icons.all_inclusive, Colors.cyan),
                    _buildStatCard('${accounts.length}', 'Accounts', Icons.sync, Colors.lightBlue),
                  ],
                ),
                const SizedBox(height: 30),
                const Text('اکانت‌های من', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                accounts.isEmpty 
                    ? const Center(child: Text('هیچ اکانتی اضافه نشده است.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: accounts.length,
                        itemBuilder: (context, index) {
                          final acc = accounts[index];
                          return Card(
                            color: const Color(0xFF131A22).withOpacity(0.9),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.green.withOpacity(0.3))),
                            child: ListTile(
                              leading: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
                              title: Text(acc['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Row(children: [
                                const Icon(Icons.circle, color: Colors.greenAccent, size: 10),
                                const SizedBox(width: 5),
                                Text(acc['phone']!, style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                              ]),
                              trailing: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => AccountDetailScreen(phone: acc['phone']!)));
                              },
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        onPressed: () async {
          final newAccount = await Navigator.push<Map<String, String>>(context, MaterialPageRoute(builder: (context) => const AddAccountScreen()));
          if (newAccount != null) {
            setState(() { accounts.add(newAccount); });
          }
        },
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color iconColor) {
    return Container(
      width: 105,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF131A22).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
        boxShadow: [BoxShadow(color: iconColor.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
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
        Uri.parse('$SERVER_URL/api/login/request'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'phone': _phoneController.text}),
      ).timeout(const Duration(seconds: 10));
      
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        setState(() { _isOtpSent = true; _hash = data['hash']; });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: ${e.toString()}')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _handleVerify() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('$SERVER_URL/api/login/verify'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'phone': _phoneController.text, 'code': _codeController.text, 'phone_code_hash': _hash}),
      ).timeout(const Duration(seconds: 10));
      
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        Navigator.pop(context, {
          'phone': _phoneController.text,
          'name': data['name'] ?? 'بدون نام'
        });
      } else {
        // نمایش دقیق خطای سرور (مثلا خطای 2FA یا ذخیره سشن)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data['message']),
          duration: const Duration(seconds: 5),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: ${e.toString()}')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('افزودن اکانت')),
      body: CustomBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                TextField(controller: _phoneController, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'شماره تلفن با 0 (مثال: 09123456789)')),
                if (_isOtpSent) ...[
                  const SizedBox(height: 16),
                  TextField(controller: _codeController, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'کد تایید')),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA)),
                    onPressed: _isLoading ? null : (_isOtpSent ? _handleVerify : _handleRequest),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.black) : Text(_isOtpSent ? 'تایید و ورود' : 'درخواست کد', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== ۵. منوی عملیات ====================
class AccountDetailScreen extends StatelessWidget {
  final String phone;
  const AccountDetailScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(phone)),
      body: CustomBackground(
        child: SafeArea(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildBtn(context, 'اسپم', Icons.email, SpamScreen(phone: phone)),
              _buildBtn(context, 'تسک‌ها', Icons.settings, const TasksScreen()),
              _buildBtn(context, 'ریپلای', Icons.chat, const Center(child: Text('به زودی...', style: TextStyle(color: Colors.white)))),
              _buildBtn(context, 'فوروارد', Icons.forward, ForwardScreen(phone: phone)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBtn(BuildContext context, String title, IconData icon, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF131A22).withOpacity(0.9), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.withOpacity(0.3))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, size: 40, color: Colors.white), const SizedBox(height: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))],
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
  final _count = TextEditingController(text: "50");
  final _speed = TextEditingController(text: "1000");
  String? _selectedChat;
  String? _selectedChatName;
  List<dynamic> _chats = [];
  bool _isLoadingChats = true;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    try {
      final res = await http.get(Uri.parse('$SERVER_URL/api/chats/${widget.phone}')).timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        setState(() { _chats = data['chats']; _isLoadingChats = false; });
      }
    } catch (e) { setState(() => _isLoadingChats = false); }
  }

  void _startSpam() async {
    if (_selectedChat == null) return;
    try {
      final res = await http.post(
        Uri.parse('$SERVER_URL/api/task/start'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "account_phone": widget.phone,
          "task_id": DateTime.now().millisecondsSinceEpoch.toString(),
          "task_type": "spam",
          "target_chat": _selectedChat,
          "target_chat_name": _selectedChatName,
          "text": _text.text,
          "count": int.parse(_count.text),
          "speed": int.parse(_speed.text)
        }),
      ).timeout(const Duration(seconds: 10));
      
      final data = jsonDecode(res.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      if(data['status'] == 'success') Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیم اسپم')),
      body: CustomBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(controller: _text, style: const TextStyle(color: Colors.white), maxLines: 4, decoration: const InputDecoration(labelText: 'متن اسپم')),
                const SizedBox(height: 16),
                _isLoadingChats 
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF131A22),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(labelText: 'انتخاب گروه مقصد'),
                      items: _chats.map((c) => DropdownMenuItem<String>(value: c['id'].toString(), child: Text(c['title']))).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedChat = val;
                          _selectedChatName = _chats.firstWhere((c) => c['id'].toString() == val)['title'];
                        });
                      },
                    ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _count, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'تعداد (0 = بی‌نهایت)'))),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: _speed, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سرعت (ms)'))),
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
        ),
      ),
    );
  }
}

// ==================== ۷. صفحه فوروارد ====================
class ForwardScreen extends StatefulWidget {
  final String phone;
  const ForwardScreen({super.key, required this.phone});
  @override
  State<ForwardScreen> createState() => _ForwardScreenState();
}

class _ForwardScreenState extends State<ForwardScreen> {
  int _step = 1;
  final _linkController = TextEditingController();
  final _count = TextEditingController(text: "0");
  final _speed = TextEditingController(text: "1000");
  
  String? _sourceChat;
  String? _targetChat;
  String? _targetChatName;
  List<dynamic> _chats = [];
  bool _isLoadingChats = true;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    try {
      final res = await http.get(Uri.parse('$SERVER_URL/api/chats/${widget.phone}')).timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        setState(() { _chats = data['chats']; _isLoadingChats = false; });
      }
    } catch (e) { setState(() => _isLoadingChats = false); }
  }

  void _startForward() async {
    if (_sourceChat == null || _targetChat == null || _linkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لطفا همه فیلدها را پر کنید')));
      return;
    }
    try {
      final res = await http.post(
        Uri.parse('$SERVER_URL/api/task/start'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "account_phone": widget.phone,
          "task_id": DateTime.now().millisecondsSinceEpoch.toString(),
          "task_type": "forward",
          "source_chat": _sourceChat,
          "target_chat": _targetChat,
          "target_chat_name": _targetChatName,
          "message_link": _linkController.text,
          "count": int.parse(_count.text),
          "speed": int.parse(_speed.text)
        }),
      ).timeout(const Duration(seconds: 10));
      
      final data = jsonDecode(res.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      if(data['status'] == 'success') Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('فوروارد - مرحله $_step')),
      body: CustomBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _step == 1 ? _buildStep1() : _buildStep2(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        TextField(controller: _linkController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'لینک پیام برای فوروارد (مثال: https://splus.ir/c/25384148/3)')),
        const SizedBox(height: 16),
        _isLoadingChats ? const Center(child: CircularProgressIndicator()) : DropdownButtonFormField<String>(
          dropdownColor: const Color(0xFF131A22),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(labelText: 'گپ مبدا را انتخاب کنید'),
          items: _chats.map((c) => DropdownMenuItem<String>(value: c['id'].toString(), child: Text(c['title']))).toList(),
          onChanged: (val) => setState(() => _sourceChat = val),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA)),
            onPressed: () => setState(() => _step = 2),
            child: const Text('بعدی', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          dropdownColor: const Color(0xFF131A22),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(labelText: 'گپ مقصد را انتخاب کنید'),
          items: _chats.map((c) => DropdownMenuItem<String>(value: c['id'].toString(), child: Text(c['title']))).toList(),
          onChanged: (val) {
            setState(() {
              _targetChat = val;
              _targetChatName = _chats.firstWhere((c) => c['id'].toString() == val)['title'];
            });
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: TextField(controller: _count, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'تعداد (0 = بی‌نهایت)'))),
            const SizedBox(width: 16),
            Expanded(child: TextField(controller: _speed, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سرعت (ms)'))),
          ],
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA)),
            onPressed: _startForward,
            child: const Text('شروع فوروارد', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

// ==================== ۸. صفحه تسک‌ها ====================
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
      final res = await http.get(Uri.parse('$SERVER_URL/api/tasks')).timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body);
      setState(() => tasks = data['tasks']);
    } catch (e) { print(e); }
  }

  void _editTask(String taskId, int currentCount, int currentSpeed) {
    final countCtrl = TextEditingController(text: currentCount.toString());
    final speedCtrl = TextEditingController(text: currentSpeed.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131A22),
        title: const Text('ویرایش تسک', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: countCtrl, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'تعداد جدید')),
            const SizedBox(height: 10),
            TextField(controller: speedCtrl, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سرعت جدید (ms)')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await http.post(
                Uri.parse('$SERVER_URL/api/task/update/$taskId'),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({"count": int.parse(countCtrl.text), "speed": int.parse(speedCtrl.text)}),
              );
              Navigator.pop(context);
              _fetchTasks();
            },
            child: const Text('ذخیره', style: TextStyle(color: Color(0xFF00FFAA))),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('لغو', style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسک‌های فعال')),
      body: CustomBackground(
        child: SafeArea(
          child: tasks.isEmpty 
              ? const Center(child: Text('هیچ تسکی در حال اجرا نیست', style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, i) {
                    final t = tasks[i];
                    return Card(
                      color: const Color(0xFF131A22).withOpacity(0.9),
                      child: ListTile(
                        title: Text(t['chat_name'] ?? 'نامشخص', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('${t['type']} | تعداد: ${t['count']} | سرعت: ${t['speed']}', style: const TextStyle(color: Colors.grey)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () => _editTask(t['id'], t['count'], t['speed']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () async {
                                await http.post(Uri.parse('$SERVER_URL/api/task/stop/${t['id']}')).timeout(const Duration(seconds: 10));
                                _fetchTasks();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}