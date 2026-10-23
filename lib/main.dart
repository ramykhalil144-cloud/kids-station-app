import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const KidsStationApp());
}

class KidsStationApp extends StatelessWidget {
  const KidsStationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'كيدز ستاشن | Kids Station Egypt',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6D28D9),
          primary: const Color(0xFF6D28D9),
          secondary: const Color(0xFFEC4899),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: const KidsStationHomeScreen(),
    );
  }
}

class KidsStationHomeScreen extends StatefulWidget {
  const KidsStationHomeScreen({super.key});

  @override
  State<KidsStationHomeScreen> createState() => _KidsStationHomeScreenState();
}

class _KidsStationHomeScreenState extends State<KidsStationHomeScreen> {
  int _tab = 0;
  int _points = 450;
  String _selectedBranch = 'فرع القاهرة الجديدة (التسعين الشمالي)';
  String _selectedPkg = 'ساعتين لعب (440 ج.م)';

  final List<Map<String, dynamic>> _branches = [
    {'name': 'فرع القاهرة الجديدة (التسعين الشمالي)', 'area': 'التجمع الخامس', 'price': 240, 'status': 'هادئ الآن 🟢', 'phone': '01000455777'},
    {'name': 'فرع الشيخ زايد (أمريكانا بلازا)', 'area': 'الشيخ زايد', 'price': 240, 'status': 'متوسط 🟡', 'phone': '01115020502'},
    {'name': 'فرع الشيخ زايد (ذا هب مول سوديك)', 'area': 'الشيخ زايد', 'price': 210, 'status': 'هادئ الآن 🟢', 'phone': '01115020502'},
    {'name': 'فرع مدينة نصر (توكانو كومبليكس)', 'area': 'مدينة نصر', 'price': 240, 'status': 'نشط الآن 🟠', 'phone': '01103273001'},
    {'name': 'فرع المعادي (زهراء المعادي)', 'area': 'المعادي', 'price': 240, 'status': 'هادئ الآن 🟢', 'phone': '01115020502'},
    {'name': 'فرع مدينتي (Madinaty)', 'area': 'مدينتي', 'price': 240, 'status': 'متوسط 🟡', 'phone': '01115020502'},
    {'name': 'فرع مدينة الرحاب', 'area': 'الرحاب', 'price': 240, 'status': 'هادئ الآن 🟢', 'phone': '01115020502'},
    {'name': 'فرع مدينة العبور', 'area': 'العبور', 'price': 240, 'status': 'هادئ الآن 🟢', 'phone': '01115020502'},
  ];

  final List<Map<String, String>> _tickets = [
    {'id': 'KS-88412', 'branch': 'فرع القاهرة الجديدة (التسعين الشمالي)', 'pkg': 'ساعتين لعب (440 ج.م)', 'child': 'آدم (6 سنوات)', 'wb': 'WB-204', 'pin': '4829'},
  ];

  @override
  Widget build(BuildContext context) {
    final views = [_buildBranches(), _buildBooking(), _buildTickets(), _buildGateAdmin()];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4C1D95),
        foregroundColor: Colors.white,
        title: const Text('كيدز ستاشن مصر | Kids Station', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text('⭐ $_points نقطة', style: const TextStyle(color: Color(0xFFFCD34D), fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      body: views[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.location_on), label: 'دليل الفروع'),
          NavigationDestination(icon: Icon(Icons.confirmation_number), label: 'حجز تذكرة'),
          NavigationDestination(icon: Icon(Icons.qr_code_2), label: 'تذاكري'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'بوابة الفرع'),
        ],
      ),
    );
  }

  Widget _buildBranches() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _branches.length,
      itemBuilder: (ctx, i) {
        final b = _branches[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(b['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${b['area']} • ${b['status']} • يبدأ من ${b['price']} ج.م'),
            trailing: FilledButton(
              onPressed: () => setState(() {
                _selectedBranch = b['name'];
                _tab = 1;
              }),
              child: const Text('احجز الآن'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBooking() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('الحجز الإلكتروني الفوري 🎟️', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedBranch,
          items: _branches.map((b) => DropdownMenuItem<String>(value: b['name'], child: Text(b['name']))).toList(),
          onChanged: (v) => setState(() => _selectedBranch = v!),
          decoration: const InputDecoration(labelText: 'اختر الفرع', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedPkg,
          items: const [
            DropdownMenuItem(value: 'ساعة لعب (240 ج.م)', child: Text('ساعة لعب (240 ج.م)')),
            DropdownMenuItem(value: 'ساعتين لعب (440 ج.م)', child: Text('ساعتين لعب (440 ج.م)')),
            DropdownMenuItem(value: 'باقة 5 ساعات VIP (650 ج.م)', child: Text('باقة 5 ساعات VIP (650 ج.م)')),
          ],
          onChanged: (v) => setState(() => _selectedPkg = v!),
          decoration: const InputDecoration(labelText: 'اختر الباقة', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {
            final id = 'KS-${10000 + Random().nextInt(89999)}';
            final wb = 'WB-${200 + Random().nextInt(700)}';
            final pin = '${1000 + Random().nextInt(8999)}';
            setState(() {
              _tickets.insert(0, {'id': id, 'branch': _selectedBranch, 'pkg': _selectedPkg, 'child': 'آدم وفريدة', 'wb': wb, 'pin': pin});
              _points += 45;
              _tab = 2;
            });
          },
          icon: const Icon(Icons.check_circle),
          label: const Text('تأكيد الحجز وإصدار تذكرة الـ QR'),
        ),
      ],
    );
  }

  Widget _buildTickets() {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _tickets.length,
      itemBuilder: (ctx, i) {
        final t = _tickets[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.qr_code_2, size: 42, color: Color(0xFF6D28D9)),
            title: Text('${t['id']} • ${t['branch']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${t['pkg']} • أسورة: ${t['wb']} • كود الاستلام: ${t['pin']}'),
          ),
        );
      },
    );
  }

  Widget _buildGateAdmin() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('لوحة تحكم بوابة الفرع وربط Firebase 🛂🔥', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('الأطفال المتواجدون داخل الفرع والأساور الذكية:'),
        const SizedBox(height: 10),
        ..._tickets.map((t) => Card(
              child: ListTile(
                leading: const Icon(Icons.watch, color: Colors.teal),
                title: Text('أسورة ${t['wb']} • ${t['child']}'),
                subtitle: Text('تذكرة ${t['id']} • كود أمان الاستلام: ${t['pin']}'),
                trailing: const Chip(label: Text('نشط بالداخل 🟢')),
              ),
            )),
      ],
    );
  }
}
