import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bot Manager',
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
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00FFAA))),
        ),
      ),
      home: const ServerLoginScreen(),
    );
  }
}

// ==================== مدل‌های داده ====================
class BotAccount {
  final String phone;
  bool isRunning;
  BotAccount({required this.phone, this.isRunning = true});
}

class BotTask {
  String type;
  String target;
  int count;
  int speed;
  BotTask({required this.type, required this.target, required this.count, required this.speed});
}

// ==================== ۱. لاگین سرور ====================
class ServerLoginScreen extends StatelessWidget {
  const ServerLoginScreen({super.key});
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
              TextField(decoration: const InputDecoration(labelText: 'آی‌پی سرور')),
              const SizedBox(height: 16),
              TextField(decoration: const InputDecoration(labelText: 'نام کاربری سرور')),
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
    );
  }
}

// ==================== ۲. لاگین اپلیکیشن ====================
class AppLoginScreen extends StatelessWidget {
  const AppLoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text('ورود به پنل', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(decoration: const InputDecoration(labelText: 'نام کاربری')),
              const SizedBox(height: 16),
              TextField(obscureText: true, decoration: const InputDecoration(labelText: 'رمز عبور')),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA)),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen())),
                  child: const Text('ورود', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
  List<BotAccount> accounts = [BotAccount(phone: 'Javad⁵ R₣'), BotAccount(phone: 'Javad⁶ R₣')];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RP Bot', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          return Card(
            color: const Color(0xFF131A22),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(accounts[index].phone, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Row(children: [
                Icon(Icons.circle, color: accounts[index].isRunning ? Colors.greenAccent : Colors.red, size: 10),
                const SizedBox(width: 5),
                Text(accounts[index].isRunning ? 'در حال اجرا' : 'متوقف', style: TextStyle(color: accounts[index].isRunning ? Colors.greenAccent : Colors.red)),
              ]),
              trailing: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AccountDetailScreen(account: accounts[index])));
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        onPressed: () {
          // TODO: اتصال به API برای ارسال شماره و دریافت کد
          setState(() { accounts.add(BotAccount(phone: 'اکانت جدید')); });
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

// ==================== ۴. جزئیات اکانت و عملیات (عکس جدید شما) ====================
class AccountDetailScreen extends StatefulWidget {
  final BotAccount account;
  const AccountDetailScreen({super.key, required this.account});
  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.account.phone, style: const TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // دکمه حذف اکانت
            SizedBox(
              width: double.infinity, height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
                onPressed: () { /* TODO: حذف اکانت */ },
                child: const Text('حذف اکانت', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
            // دکمه‌های استارت و استاپ
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: widget.account.isRunning ? Colors.redAccent.withOpacity(0.2) : Colors.grey[800]),
                    onPressed: () => setState(() => widget.account.isRunning = false),
                    child: const Text('Stop Run', style: TextStyle(color: Colors.redAccent)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: widget.account.isRunning ? Colors.greenAccent.withOpacity(0.2) : Colors.grey[800]),
                    onPressed: () => setState(() => widget.account.isRunning = true),
                    child: const Text('Start Run', style: TextStyle(color: Colors.greenAccent)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Align(alignment: Alignment.centerRight, child: Text('عملیات‌ها', style: TextStyle(fontSize: 18, color: Colors.grey))),
            const SizedBox(height: 16),
            // دکمه‌های عملیات (ریپلای، اسپم، تسک‌ها، فوروارد)
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildOperationCard(context, 'ریپلای', Icons.chat_bubble, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReplyScreen()))),
                  _buildOperationCard(context, 'اسپم', Icons.email, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SpamScreen()))),
                  _buildOperationCard(context, 'تسک‌ها', Icons.settings, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TasksScreen()))),
                  _buildOperationCard(context, 'فوروارد', Icons.forward, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForwardScreen()))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF131A22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// ==================== ۵. صفحه اسپم ====================
class SpamScreen extends StatefulWidget {
  const SpamScreen({super.key});
  @override
  State<SpamScreen> createState() => _SpamScreenState();
}

class _SpamScreenState extends State<SpamScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیم اسپم')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(maxLines: 4, decoration: const InputDecoration(labelText: 'متن اسپم')),
            const SizedBox(height: 16),
            TextField(decoration: const InputDecoration(labelText: 'آیدی یا لینک گروه مقصد')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'تعداد ارسال'))),
                const SizedBox(width: 16),
                Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سرعت (میلی‌ثانیه)'))),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA)),
                onPressed: () { /* TODO: ارسال دستور به سرور */ Navigator.pop(context); },
                child: const Text('شروع اسپم', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ۶. صفحه ریپلای (دو نوع) ====================
class ReplyScreen extends StatefulWidget {
  const ReplyScreen({super.key});
  @override
  State<ReplyScreen> createState() => _ReplyScreenState();
}

class _ReplyScreenState extends State<ReplyScreen> {
  int _selectedTab = 0; // 0 = لینک، 1 = ممبر

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیم ریپلای')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // دکمه‌های تغییر تب
            Row(
              children: [
                Expanded(child: ChoiceChip(label: const Text('ریپلای روی لینک'), selected: _selectedTab == 0, onSelected: (v) => setState(() => _selectedTab = 0))),
                const SizedBox(width: 10),
                Expanded(child: ChoiceChip(label: const Text('ریپلای روی ممبر'), selected: _selectedTab == 1, onSelected: (v) => setState(() => _selectedTab = 1))),
              ],
            ),
            const SizedBox(height: 20),
            
            // فرم بر اساس تب انتخاب شده
            if (_selectedTab == 0) ...[
              TextField(decoration: const InputDecoration(labelText: 'لینک پیام مورد نظر')),
              const SizedBox(height: 16),
              TextField(maxLines: 3, decoration: const InputDecoration(labelText: 'متن ریپلای')),
            ] else ...[
              TextField(decoration: const InputDecoration(labelText: 'لینک گروه برای لود ممبرها')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'انتخاب ممبر'),
                items: ['کاربر ۱', 'کاربر ۲', 'کاربر ۳'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) {},
              ),
              const SizedBox(height: 16),
              TextField(maxLines: 3, decoration: const InputDecoration(labelText: 'متن ریپلای')),
            ],
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'تعداد'))),
                const SizedBox(width: 16),
                Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سرعت'))),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA)),
                onPressed: () { /* TODO */ Navigator.pop(context); },
                child: const Text('ذخیره و شروع', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ۷. صفحه فوروارد ====================
class ForwardScreen extends StatefulWidget {
  const ForwardScreen({super.key});
  @override
  State<ForwardScreen> createState() => _ForwardScreenState();
}

class _ForwardScreenState extends State<ForwardScreen> {
  int _step = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('فوروارد - مرحله $_step')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _step == 1 ? _buildStep1() : _buildStep2(),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'گپ مبدا را انتخاب کنید'),
          items: ['گروه A', 'کانال B', 'گروه C'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) {},
        ),
        const SizedBox(height: 16),
        TextField(decoration: const InputDecoration(labelText: 'لینک پیام برای فوروارد')),
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
          decoration: const InputDecoration(labelText: 'گپ مقصد را انتخاب کنید'),
          items: ['گروه X', 'کانال Y', 'گروه Z'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) {},
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity, height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFAA)),
            onPressed: () { /* TODO */ Navigator.pop(context); },
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
  // لیست تسک‌های تستی
  List<BotTask> tasks = [
    BotTask(type: 'اسپم', target: 'گروه تست', count: 50, speed: 100),
    BotTask(type: 'ریپلای', target: 'کاربر احمد', count: 20, speed: 200),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسک‌های فعال')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            color: const Color(0xFF131A22),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text('${task.type} - ${task.target}', style: const TextStyle(color: Colors.white)),
              subtitle: Text('تعداد: ${task.count} | سرعت: ${task.speed}', style: const TextStyle(color: Colors.grey)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () { /* TODO: باز کردن صفحه ویرایش */ },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      setState(() => tasks.removeAt(index));
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}