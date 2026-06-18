import 'package:flutter/material.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/auth/register_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/education/waste_detail_screen.dart';
import '../presentation/scanner/scan_result_screen.dart';
import '../presentation/community/create_report_screen.dart';
import '../presentation/community/report_detail_screen.dart';
import '../presentation/profile/profile_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String wasteDetail = '/waste-detail';
  static const String scanResult = '/scan-result';
  static const String createReport = '/create-report';
  static const String reportDetail = '/report-detail';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        home: (_) => const HomeScreen(),
        profile: (_) => const ProfileScreen(),
        wasteDetail: (ctx) => WasteDetailScreen(
              categoryKey: ModalRoute.of(ctx)!.settings.arguments as String,
            ),
        scanResult: (ctx) => ScanResultScreen(
              arguments: ModalRoute.of(ctx)!.settings.arguments
                  as ScanResultArguments,
            ),
        createReport: (_) => const CreateReportScreen(),
        reportDetail: (ctx) => ReportDetailScreen(
              reportId: ModalRoute.of(ctx)!.settings.arguments as String,
            ),
      };
}
