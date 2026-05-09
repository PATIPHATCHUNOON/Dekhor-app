// main.dart — จุดเริ่มต้นของแอป

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/schedule/providers/schedule_provider.dart';
import 'features/todo/providers/todo_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th', null);
  runApp(
    // MultiProvider — ทำให้ทุกหน้าเข้าถึง provider ได้
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // เพิ่ม provider อื่นๆ ทีหลังที่นี่
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: const DekHorApp(),
    ),
  );
}