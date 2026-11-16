import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

void main() {
  HttpOverrides.global = null;
  runApp(const MyApp());
}

const String SERVER_URL = 'http://80.244.7.90:8000'; 

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
          backgroundColor: Colors.black54, elevation: 0, centerTitle: true,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: const Color(0xFF131A22).withOpacity(0.9), 
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00FFAA))),
        ),
      ),
      home: const AppLoginScreen(),
    );
  }
}

class CustomBackground extends StatelessWidget {
  final Widget child;
  const CustomBackground({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Image.asset('assets/bg.png', fit: BoxFit.cover)),
        Positioned.fill(child: Container(color: Colors.black.withOpacity(0.6))),
        child,
      ],
    );
  }
}

// ==================== ۱. لاگین اپلیکیشن ====================
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
      
      final data = jsonDecode(utf8.decode(res.bodyBytes));
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
                const Icon(Icons.security, size: 80, color: Color(0xFF00FFAA)),
                const SizedBox(height: 20),
                const Text('ورود به پنل مدیریت', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 30),
                TextField(controller: _userController, readOnly: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'نام کاربری', prefixIcon: Icon(Icons.person, color: Colors.grey))),
                const SizedBox(height: 16),
                TextField(controller: _passController, readOnly: true, obscureText: true, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'رمز عبور', prefixIcon: Icon(Icons.lock, color: Colors.grey))),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA)),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.black) : const Text('ورود به پنل', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
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

// ==================== ۲. داشبورد ====================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> accounts = []; 
  int totalSent = 0;
  int runningTasks = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => _fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final resAcc = await http.get(Uri.parse('$SERVER_URL/api/accounts')).timeout(const Duration(seconds: 5));
      final resStats = await http.get(Uri.parse('$SERVER_URL/api/stats')).timeout(const Duration(seconds: 5));
      
      if (resAcc.statusCode == 200 && resStats.statusCode == 200) {
        final dataAcc = jsonDecode(utf8.decode(resAcc.bodyBytes));
        final dataStats = jsonDecode(utf8.decode(resStats.bodyBytes));
        setState(() { 
          accounts = dataAcc['accounts'] ?? [];
          totalSent = dataStats['total_sent'] ?? 0;
          runningTasks = dataStats['running'] ?? 0;
        });
      }
    } catch (e) {}
  }

  Future<void> _deleteAccount(String phone) async {
    bool confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131A22),
        title: const Text('حذف اکانت', style: TextStyle(color: Colors.white)),
        content: Text('آیا از حذف اکانت $phone مطمئن هستید؟', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('لغو', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف', style: TextStyle(color: Colors.redAccent))),
        ],
      )
    ) ?? false;

    if (confirm) {
      await http.post(
        Uri.parse('$SERVER_URL/api/accounts/delete'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'phone': phone}),
      );
      _fetchData();
    }
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
                const Text('اکانت‌های متصل', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                accounts.isEmpty 
                    ? const Center(child: Text('هیچ اکانتی اضافه نشده است.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: accounts.length,
                        itemBuilder: (context, index) {
                          final acc = accounts[index];
                          bool isActive = acc['status'] == 'active';
                          
                          return Card(
                            color: const Color(0xFF131A22).withOpacity(0.9),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16), 
                              side: BorderSide(color: isActive ? Colors.green.withOpacity(0.5) : Colors.redAccent.withOpacity(0.5))
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isActive ? Colors.green.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                                child: Icon(Icons.person, color: isActive ? Colors.greenAccent : Colors.redAccent),
                              ),
                              title: Text(acc['name'] ?? acc['phone'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Row(children: [
                                Icon(Icons.circle, color: isActive ? Colors.greenAccent : Colors.redAccent, size: 10),
                                const SizedBox(width: 5),
                                Text(isActive ? 'فعال' : 'اعتبار باطل شده', style: TextStyle(color: isActive ? Colors.greenAccent : Colors.redAccent, fontSize: 12)),
                              ]),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.grey),
                                    onPressed: () => _deleteAccount(acc['phone']),
                                  ),
                                  const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
                                ],
                              ),
                              onTap: () {
                                if (isActive) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AccountDetailScreen(phone: acc['phone']!)));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('این اکانت از ربات خارج شده است.')));
                                }
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
          bool? added = await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => const AddAccountScreen()));
          if (added == true) _fetchData(); 
        },
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color iconColor) {
    return Container(
      width: 105, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF131A22).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ==================== ۳. منوی عملیات ====================
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
            crossAxisCount: 2, padding: const EdgeInsets.all(16), crossAxisSpacing: 16, mainAxisSpacing: 16,
            children: [
              _buildBtn(context, 'اسپم', Icons.email, SpamScreen(phone: phone)),
              _buildBtn(context, 'تسک‌ها', Icons.settings, TasksScreen(phone: phone)),
              _buildBtn(context, 'فوروارد', Icons.forward, ForwardScreen(phone: phone)),
              _buildBtn(context, 'ریپلای', Icons.reply, ReplyScreen(phone: phone)),
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

// ==================== ۴. صفحه ریپلای ====================
class ReplyScreen extends StatefulWidget {
  final String phone;
  const ReplyScreen({super.key, required this.phone});
  @override
  State<ReplyScreen> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  String _replyType = "user"; // پیش‌فرض روی کاربر
  final _linkController = TextEditingController();
  final _textController = TextEditingController();
  final _countController = TextEditingController(text: "1"); // تعداد پاسخ برای هر پیام
  final _speedController = TextEditingController(text: "1000");

  String? _selectedChatId;
  String? _selectedChatName;
  String? _selectedMemberId;
  String? _selectedMemberName;
  
  List<dynamic> _chats = [];
  bool _isLoadingChats = true;
  List<dynamic> _members = [];
  bool _isLoadingMembers = false;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    setState(() => _isLoadingChats = true);
    try {
      final res = await http.get(Uri.parse('$SERVER_URL/api/chats/${widget.phone}')).timeout(const Duration(seconds: 15));
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (data['status'] == 'success') setState(() { _chats = data['chats']; });
    } catch (e) {}
    setState(() => _isLoadingChats = false);
  }

  Future<void> _fetchMembers() async {
    if (_selectedChatId == null) return;
    setState(() { _isLoadingMembers = true; _members = []; });
    try {
      final res = await http.get(Uri.parse('$SERVER_URL/api/members/${widget.phone}/$_selectedChatId')).timeout(const Duration(seconds: 30));
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (data['status'] == 'success') {
        setState(() { _members = data['members']; });
        _showMemberSelectionBottomSheet();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'خطا در دریافت ممبرها')));
      }
    } catch (e) {}
    setState(() => _isLoadingMembers = false);
  }

  void _showMemberSelectionBottomSheet() {
    String searchQuery = "";
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131A22),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _members.where((m) => m['name'].toString().toLowerCase().contains(searchQuery.toLowerCase())).toList();
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('انتخاب کاربر برای ریپلای', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'جستجو...', prefixIcon: Icon(Icons.search, color: Colors.grey)),
                    onChanged: (val) => setModalState(() => searchQuery = val),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filtered.isEmpty 
                      ? const Center(child: Text('یافت نشد', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final m = filtered[i];
                            return ListTile(
                              leading: const Icon(Icons.person, color: Colors.cyanAccent),
                              title: Text(m['name'], style: const TextStyle(color: Colors.white)),
                              subtitle: Text(m['username'] != "" ? "@${m['username']}" : m['id'], style: const TextStyle(color: Colors.grey)),
                              onTap: () {
                                setState(() { _selectedMemberId = m['id'].toString(); _selectedMemberName = m['name']; });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }

  void _startReply() async {
    if (_replyType == "link" && _linkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لینک پیام را وارد کنید')));
      return;
    }
    if (_replyType == "user" && _selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کاربر را انتخاب کنید')));
      return;
    }
    if (_textController.text.isEmpty || _selectedChatId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('متن و گروه را وارد کنید')));
      return;
    }

    try {
      final taskType = _replyType == "link" ? "reply_link" : "reply_user";
      final res = await http.post(
        Uri.parse('$SERVER_URL/api/task/start'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "account_phone": widget.phone, "task_id": DateTime.now().millisecondsSinceEpoch.toString(),
          "task_type": taskType, 
          "target_chat": _selectedChatId, 
          "target_chat_name": _selectedChatName,
          "text": _textController.text, 
          "message_link": _replyType == "link" ? _linkController.text : null,
          "target_member": _replyType == "user" ? _selectedMemberId : null,
          "count": int.parse(_countController.text), 
          "speed": int.parse(_speedController.text)
        }),
      ).timeout(const Duration(seconds: 10));
      
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      if(data['status'] == 'success') Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطا: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیم ریپلای')),
      body: CustomBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('متن ریپلای:', style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController, maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(hintText: 'متن پاسخ خودکار...'),
                ),
                const SizedBox(height: 20),
                
                // انتخاب نوع ریپلای
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('روی لینک پیام', style: TextStyle(color: Colors.white, fontSize: 14)),
                        value: "link", groupValue: _replyType,
                        activeColor: const Color(0xFF00FFAA),
                        onChanged: (val) => setState(() => _replyType = val!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('روی کاربر گروه', style: TextStyle(color: Colors.white, fontSize: 14)),
                        value: "user", groupValue: _replyType,
                        activeColor: const Color(0xFF00FFAA),
                        onChanged: (val) => setState(() => _replyType = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_replyType == "link") ...[
                  const Text('لینک پیام هدف:', style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(controller: _linkController, style: const TextStyle(color: Colors.white, direction: TextDirection.ltr), decoration: const InputDecoration(hintText: 'https://splus.ir/c/123...')),
                  const SizedBox(height: 16),
                ],

                // انتخاب گروه
                const Text('گروه مقصد:', style: TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  dropdownColor: const Color(0xFF131A22), 
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(hintText: 'انتخاب کنید...'),
                  value: _selectedChatId,
                  items: _chats.map((c) => DropdownMenuItem<String>(value: c['id'].toString(), child: Text(c['title']))).toList(),
                  onChanged: (val) {
                    setState(() { 
                      _selectedChatId = val; 
                      _selectedChatName = _chats.firstWhere((c) => c['id'].toString() == val)['title'];
                      _selectedMemberId = null; _selectedMemberName = null; 
                    });
                  },
                ),
                const SizedBox(height: 16),

                // انتخاب کاربر (اگر حالت user باشد)
                if (_replyType == "user") ...[
                  const Text('کاربر هدف (برای مانیتور کردن):', style: TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _isLoadingMembers ? null : () {
                      if (_members.isEmpty) _fetchMembers(); else _showMemberSelectionBottomSheet();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF131A22), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade800)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_selectedMemberName ?? 'انتخاب کاربر...', style: TextStyle(color: _selectedMemberName != null ? Colors.white : Colors.grey)),
                          _isLoadingMembers ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00FFAA))) : const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _countController, 
                        style: const TextStyle(color: Colors.white), 
                        keyboardType: TextInputType.number, 
                        decoration: const InputDecoration(labelText: 'تعداد پاسخ برای هر پیام')
                      )
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _speedController, 
                        style: const TextStyle(color: Colors.white), 
                        keyboardType: TextInputType.number, 
                        decoration: const InputDecoration(labelText: 'سرعت (ms)')
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA)), 
                    onPressed: _startReply,
                    child: const Text('شروع ریپلای', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
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

// ==================== ۵. افزودن اکانت ====================
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
      ).timeout(const Duration(seconds: 15));
      
      final data = jsonDecode(utf8.decode(res.bodyBytes));
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
      ).timeout(const Duration(seconds: 15));
      
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (data['status'] == 'success') {
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), duration: const Duration(seconds: 5)));
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
                TextField(controller: _phoneController, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'شماره تلفن با 0')),
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
  List<dynamic> _chats = [];
  bool _isLoadingChats = true;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    setState(() => _isLoadingChats = true);
    try {
      final res = await http.get(Uri.parse('$SERVER_URL/api/chats/${widget.phone}')).timeout(const Duration(seconds: 15));
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (data['status'] == 'success') setState(() { _chats = data['chats']; });
    } catch (e) {}
    setState(() => _isLoadingChats = false);
  }

  void _startSpam() async {
    if (_selectedChat == null) return;
    try {
      final res = await http.post(
        Uri.parse('$SERVER_URL/api/task/start'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "account_phone": widget.phone, "task_id": DateTime.now().millisecondsSinceEpoch.toString(),
          "task_type": "spam", "target_chat": _selectedChat, "text": _text.text, 
          "count": int.parse(_count.text), "speed": int.parse(_speed.text)
        }),
      ).timeout(const Duration(seconds: 10));
      
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      if(data['status'] == 'success') Navigator.pop(context);
    } catch (e) {}
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
                _isLoadingChats && _chats.isEmpty
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF131A22), style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'گروه مقصد'), value: _selectedChat,
                      items: _chats.map((c) => DropdownMenuItem<String>(value: c['id'].toString(), child: Text(c['title']))).toList(),
                      onChanged: (val) => setState(() => _selectedChat = val),
                    ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _count, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'تعداد'))),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: _speed, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سرعت (ms)'))),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA)), onPressed: _startSpam,
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
  List<dynamic> _chats = [];
  bool _isLoadingChats = true;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    setState(() => _isLoadingChats = true);
    try {
      final res = await http.get(Uri.parse('$SERVER_URL/api/chats/${widget.phone}')).timeout(const Duration(seconds: 15));
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      if (data['status'] == 'success') setState(() { _chats = data['chats']; });
    } catch (e) {}
    setState(() => _isLoadingChats = false);
  }

  void _startForward() async {
    if (_sourceChat == null || _targetChat == null || _linkController.text.isEmpty) return;
    try {
      final res = await http.post(
        Uri.parse('$SERVER_URL/api/task/start'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "account_phone": widget.phone, "task_id": DateTime.now().millisecondsSinceEpoch.toString(),
          "task_type": "forward", "source_chat": _sourceChat, "target_chat": _targetChat,
          "message_link": _linkController.text, "count": int.parse(_count.text), "speed": int.parse(_speed.text)
        }),
      ).timeout(const Duration(seconds: 10));
      
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
      if(data['status'] == 'success') Navigator.pop(context);
    } catch (e) {}
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
        TextField(controller: _linkController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'لینک پیام برای فوروارد')),
        const SizedBox(height: 16),
        _isLoadingChats && _chats.isEmpty
          ? const CircularProgressIndicator()
          : DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF131A22), style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'گپ مبدا'), value: _sourceChat,
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
          dropdownColor: const Color(0xFF131A22), style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'گپ مقصد'), value: _targetChat,
          items: _chats.map((c) => DropdownMenuItem<String>(value: c['id'].toString(), child: Text(c['title']))).toList(),
          onChanged: (val) => setState(() => _targetChat = val),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: TextField(controller: _count, style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'تعداد'))),
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
  final String phone;
  const TasksScreen({super.key, required this.phone});
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
      final res = await http.get(Uri.parse('$SERVER_URL/api/tasks')).timeout(const Duration(seconds: 15));
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      List allTasks = data['tasks'];
      setState(() { tasks = allTasks.where((t) => t['account'] == widget.phone).toList(); });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تسک‌های ${widget.phone}')),
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
                        subtitle: Text('نوع: ${t['type']} | تعداد: ${t['count']} | سرعت: ${t['speed']}', style: const TextStyle(color: Colors.grey)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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