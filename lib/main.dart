import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'routes/app_pages.dart';
import 'utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID');

  runApp(const TeknoTodayApp());
}

class TeknoTodayApp extends StatelessWidget {
  const TeknoTodayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TeknoToday Indonesia',

      debugShowCheckedModeBanner: false,

      initialRoute: AppPages.initial,

      getPages: AppPages.routes,

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: AppColors.background,

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
      ),
    );
  }
}
