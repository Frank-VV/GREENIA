import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:camera/camera.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/report_repository.dart';
import '../data/repositories/schedule_repository.dart';
import '../data/services/waste_classifier_service.dart';
import '../core/theme/app_theme.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/home/home_screen.dart';
import 'routes.dart';
import 'theme_provider.dart';

class GreenWatchApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  final WasteClassifierService classifierService;

  const GreenWatchApp({
    super.key,
    required this.cameras,
    required this.classifierService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthRepository()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<ReportRepository>(create: (_) => ReportRepository()),
        Provider<ScheduleRepository>(create: (_) => ScheduleRepository()),
        Provider<WasteClassifierService>.value(value: classifierService),
        Provider<List<CameraDescription>>.value(value: cameras),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'GreenWatch',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          routes: AppRoutes.routes,
          home: const _AuthGate(),
          builder: (context, child) => OfflineBanner(child: child!),
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<AuthRepository>().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              'GreenWatch',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 32),
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class OfflineBanner extends StatelessWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final results = snapshot.data ?? [ConnectivityResult.wifi];
        final isOffline = results.every((r) => r == ConnectivityResult.none);
        return Column(
          children: [
            if (isOffline)
              Material(
                color: Theme.of(context).colorScheme.error,
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sin conexión a internet',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
