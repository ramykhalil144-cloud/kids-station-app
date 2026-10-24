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
  int _currentIndex = 0;
  final KidsStationFirebaseService _firebaseService = KidsStationFirebaseService();

  List<Map<String, dynamic>> _branches = [
    {
      'id': 'cairo_festival',
      'name': 'فرع كايرو فيستيفال سيتي - التجمع الخامسة',
      'city': 'القاهرة والتجمع',
      'crowdStatus': 'green',
      'crowdLabel': '🟢 هادئ',
      'prices': {'hour1': 250, 'hour2': 400, 'hour5': 800, 'birthday': 1500}
    },
    {
      'id': 'mall_of_arabia',
      'name': 'فرع مول العرب - 6 أكتوبر',
      'city': 'الجيزة وأكتوبر',
      'crowdStatus': 'yellow',
      'crowdLabel': '🟡 متوسط',
      'prices': {'hour1': 220, 'hour2': 380, 'hour5': 750, 'birthday': 1400}
    },
    {
      'id': 'city_stars',
      'name': 'فرع سيتي ستارز - مدينة نصر',
      'city': 'القاهرة والتجمع',
      'crowdStatus': 'orange',
      'crowdLabel': '🟠 نشط',
      'prices': {'hour1': 240, 'hour2': 390, 'hour5': 780, 'birthday': 1450}
    },
  ];

  String _selectedBranchId = 'cairo_festival';
  String _ticketType = 'hour2';
  int _childCount = 1;

  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _branchCityController = TextEditingController();
  final TextEditingController _price1HourController = TextEditingController(text: '250');
  final TextEditingController _price2HoursController = TextEditingController(text: '400');
  final TextEditingController _price5HoursController = TextEditingController(text: '800');
  final TextEditingController _priceBirthdayController = TextEditingController(text: '1500');

  Map<String, dynamic> get _selectedBranch {
    return _branches.firstWhere(
      (b) => b['id'] == _selectedBranchId,
      orElse: () => _branches.first,
    );
  }

  int get _calculatedTotalPrice {
    final prices = Map<String, dynamic>.from(_selectedBranch['prices'] ?? {});
    final basePrice = (prices[_ticketType] as num?)?.toInt() ?? 250;
    return basePrice * _childCount;
  }

  void _updateBranchCrowd(String branchId, String crowdStatus, String crowdLabel) {
    setState(() {
      final index = _branches.indexWhere((b) => b['id'] == branchId);
      if (index != -1) {
        _branches[index]['crowdStatus'] = crowdStatus;
        _branches[index]['crowdLabel'] = crowdLabel;
      }
    });
    _firebaseService.updateBranchCrowdStatus(branchId, crowdStatus, crowdLabel);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحديث حالة الازدحام إلى $crowdLabel')),
    );
  }

  void _saveBranchPrices() {
    final p1 = int.tryParse(_price1HourController.text) ?? 250;
    final p2 = int.tryParse(_price2HoursController.text) ?? 400;
    final p5 = int.tryParse(_price5HoursController.text) ?? 800;
    final pb = int.tryParse(_priceBirthdayController.text) ?? 1500;

    setState(() {
      final index = _branches.indexWhere((b) => b['id'] == _selectedBranchId);
      if (index != -1) {
        _branches[index]['prices'] = {
          'hour1': p1,
          'hour2': p2,
          'hour5': p5,
          'birthday': pb,
        };
      }
    });

    _firebaseService.updateBranchPrices(
      branchId: _selectedBranchId,
      price1Hour: p1,
      price2Hours: p2,
      price5Hours: p5,
      priceBirthday: pb,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ أسعار التذاكر الجديدة بنجاح في Firestore!')),
    );
  }

  void _addNewBranch() {
    final name = _branchNameController.text.trim();
    final city = _branchCityController.text.trim();
    if (name.isEmpty || city.isEmpty) return;

    final id = 'branch_${DateTime.now().millisecondsSinceEpoch}';
    final newBranch = {
      'id': id,
      'name': name,
      'city': city,
      'crowdStatus': 'green',
      'crowdLabel': '🟢 هادئ',
      'prices': {'hour1': 250, 'hour2': 400, 'hour5': 800, 'birthday': 1500},
    };

    setState(() {
      _branches.add(newBranch);
      _selectedBranchId = id;
      _branchNameController.clear();
      _branchCityController.clear();
    });

    _firebaseService.addNewBranch(newBranch);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إضافة الفرع الجديد "$name" بنجاح!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💡 كيدز ستيشن - التطبيق الموحد'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildBookingCalculatorTab(),
          _buildGateAdminTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'حاسبة الحجز',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: '🛂 بوابة الفرع',
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCalculatorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('اختر الفرع الحجم والمدينة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _selectedBranchId,
            isExpanded: true,
            items: _branches.map((b) {
              return DropdownMenuItem<String>(
                value: b['id'],
                child: Text('${b['name']} (${b['crowdLabel']})'),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedBranchId = val);
            },
          ),
          const SizedBox(height: 16),
          const Text('اختر نوع التذكرة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          RadioListTile<String>(
            title: Text('ساعة واحدة (${_selectedBranch['prices']['hour1']} ج.م)'),
            value: 'hour1',
            groupValue: _ticketType,
            onChanged: (v) => setState(() => _ticketType = v!),
          ),
          RadioListTile<String>(
            title: Text('ساعتين (${_selectedBranch['prices']['hour2']} ج.م)'),
            value: 'hour2',
            groupValue: _ticketType,
            onChanged: (v) => setState(() => _ticketType = v!),
          ),
          RadioListTile<String>(
            title: Text('5 ساعات (${_selectedBranch['prices']['hour5']} ج.م)'),
            value: 'hour5',
            groupValue: _ticketType,
            onChanged: (v) => setState(() => _ticketType = v!),
          ),
          RadioListTile<String>(
            title: Text('باقة عيد ميلاد (${_selectedBranch['prices']['birthday']} ج.م)'),
            value: 'birthday',
            groupValue: _ticketType,
            onChanged: (v) => setState(() => _ticketType = v!),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('عدد الأطفال: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _childCount > 1 ? () => setState(() => _childCount--) : null,
              ),
              Text('$_childCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setState(() => _childCount++),
              ),
            ],
          ),
          const Divider(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي الحسابي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('$_calculatedTotalPrice ج.م', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6D28D9))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGateAdminTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🛂 بوابة الفرع ولوحة التحكم اللحظي', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('التحكم اللحظي في حالة ازدحام الفروع:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  DropdownButton<String>(
                    value: _selectedBranchId,
                    isExpanded: true,
                    items: _branches.map((b) {
                      return DropdownMenuItem<String>(
                        value: b['id'],
                        child: Text(b['name']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedBranchId = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        onPressed: () => _updateBranchCrowd(_selectedBranchId, 'green', '🟢 هادئ'),
                        child: const Text('🟢 هادئ'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                        onPressed: () => _updateBranchCrowd(_selectedBranchId, 'yellow', '🟡 متوسط'),
                        child: const Text('🟡 متوسط'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                        onPressed: () => _updateBranchCrowd(_selectedBranchId, 'orange', '🟠 نشط'),
                        child: const Text('🟠 نشط'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚙️ قسم إعدادات نظام التشغيل لتعديل الأسعار:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(controller: _price1HourController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سعر تذكرة ساعة (ج.م)')),
                  TextField(controller: _price2HoursController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سعر تذكرة ساعتين (ج.م)')),
                  TextField(controller: _price5HoursController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سعر تذكرة 5 ساعات (ج.م)')),
                  TextField(controller: _priceBirthdayController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سعر باقة عيد ميلاد (ج.م)')),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveBranchPrices,
                      icon: const Icon(Icons.save),
                      label: const Text('حفظ تحديث الأسعار في Firestore'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('➕ إضافة فرع جديد مباشرة:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(controller: _branchNameController, decoration: const InputDecoration(labelText: 'اسم الفرع الجديد')),
                  TextField(controller: _branchCityController, decoration: const InputDecoration(labelText: 'المدينة / المنطقة')),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addNewBranch,
                      icon: const Icon(Icons.add_location_alt),
                      label: const Text('إضافة الفرع وتحديث القائمة و Firestore'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
