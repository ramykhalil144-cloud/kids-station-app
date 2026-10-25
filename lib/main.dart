import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/firebase_service.dart';

void main() {
  runApp(const KidsStationApp());
}

class KidsStationApp extends StatelessWidget {
  const KidsStationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'كيدز ستيشن مصر | Kids Station Egypt',
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
        fontFamily: 'Cairo',
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final firebaseService = KidsStationFirebaseService.instance;
  int _currentIndex = 0;

  final List<String> _roles = [
    '1. Super Admin',
    '2. Operations Admin',
    '3. Branch Manager',
    '4. Receptionist',
    '5. Hall Supervisor',
    '6. Security Officer',
    '7. Accountant',
    '8. Customer Support',
  ];
  String _selectedRole = '1. Super Admin';

  final Map<String, String> _bracelets = {
    'WB-201': 'نشط',
    'WB-202': 'متاح',
    'WB-203': 'نشط',
    'WB-204': 'متاح',
  };

  String _currentPhotoCode = 'VPH-2026-8841';
  bool _staffDeclaration = false;
  bool _entryActivated = false;

  final List<Map<String, String>> _suggestions = [
    {'id': '#SUG-2026-001', 'title': 'مقترح تطوير فرع المعادي', 'content': 'زيادة عدد المشرفين في منطقة الألعاب الحركية'},
    {'id': '#SUG-2026-002', 'title': 'شكوى سرية خاصة بالأمان', 'content': 'تحديث بروتوكول تسليم الأطفال في الفترات المزدحمة'},
  ];
  final TextEditingController _sugController = TextEditingController();

  String _notificationStatus = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كيدز ستيشن - بوابة الفرع والإدارة v3.0'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: '🛂 بوابة الفرع',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'الأطفال والزيارات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'المقترحات السرية',
          ),
        ],
      ),
      body: _buildCurrentTab(),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _buildBranchPortalTab();
      case 1:
        return _buildChildrenVisitsTab();
      case 2:
        return _buildSuggestionsTab();
      default:
        return _buildBranchPortalTab();
    }
  }

  Widget _buildBranchPortalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('اختيار الدور الوظيفي (RBAC):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    items: _roles.map((role) {
                      return DropdownMenuItem(value: role, child: Text(role));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('الصلاحية الحالية: $_selectedRole', style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('التحقق الإلزامي التقاط صورة الزيارة (Child & Companion Photo):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.camera_alt, color: Colors.indigo),
                        const SizedBox(width: 8),
                        Text('رمز الصورة: $_currentPhotoCode', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('إقرار الموظف المسؤول بسلامة ومطابقة الصورة مع الطفل والمرافق'),
                    value: _staffDeclaration,
                    onChanged: (val) => setState(() => _staffDeclaration = val ?? false),
                  ),
                  ElevatedButton.icon(
                    onPressed: _staffDeclaration
                        ? () => setState(() => _entryActivated = true)
                        : null,
                    icon: const Icon(Icons.check_circle),
                    label: Text(_entryActivated ? 'تم تفعيل الدخول بنجاح' : 'تفعيل الدخول'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('إدارة دورة حياة الأساور الذكية (Bracelets):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._bracelets.entries.map((entry) {
                    return ListTile(
                      title: Text('أسورة رقم: ${entry.key}'),
                      subtitle: Text('الحالة: ${entry.value}'),
                      trailing: entry.value == 'نشط'
                          ? ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _bracelets[entry.key] = 'متاح';
                                });
                              },
                              child: const Text('تحرير الأسورة'),
                            )
                          : const Chip(label: Text('جاهزة للاستخدام'), backgroundColor: Colors.greenAccent),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('تنبيهات أولياء الأمور:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _notificationStatus = 'تم إرسال تنبيه الـ 10 دقائق التلقائي لولي الأمر بنجاح';
                      });
                    },
                    icon: const Icon(Icons.add_alarm),
                    label: const Text('تنبيه الـ 10 دقائق'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  ),
                  if (_notificationStatus.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(_notificationStatus, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenVisitsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.child_care, size: 64, color: Colors.purple),
          SizedBox(height: 16),
          Text('قائمة الأطفال والزيارات النشطة بفرع كيدز ستيشن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSuggestionsTab() {
    bool isAuthorized = _selectedRole.startsWith('1.') || _selectedRole.startsWith('2.');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('صندوق المقترحات والشكاوى السرية للإدارة العليا (#SUG-...):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _sugController,
            decoration: const InputDecoration(
              labelText: 'إضافة مقترح أو شكوى سرية جديدة',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              if (_sugController.text.isNotEmpty) {
                setState(() {
                  _suggestions.add({
                    'id': '#SUG-2026-00${_suggestions.length + 1}',
                    'title': 'مقترح سرّي من $_selectedRole',
                    'content': _sugController.text,
                  });
                  _sugController.clear();
                });
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('إرسال إلى الإدارة العليا'),
          ),
          const Divider(height: 32),
          if (!isAuthorized)
            const Card(
              color: Colors.amberAccent,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('⚠️ محتوى المقترحات السرية محمي ومخصص فقط لـ Super Admin و Operations Admin.', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final sug = _suggestions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.lock, color: Colors.red),
                      title: Text('${sug['id']} - ${sug['title']}'),
                      subtitle: Text(sug['content'] ?? ''),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
