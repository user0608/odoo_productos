import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odoo_productos/config_screen.dart';
import 'package:odoo_productos/home_screen.dart';
import 'package:odoo_productos/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getInitialRoute() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? sessionId = prefs.getString('odoo_session_id');
  return (sessionId != null && sessionId.isNotEmpty) ? '/' : '/login';
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String> _initialRoute;

  @override
  void initState() {
    super.initState();
    _initialRoute = getInitialRoute();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _initialRoute,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        final initialLocation = snapshot.data!;
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/login',
              builder: (context, state) => const LoginScreen(),
            ),
            GoRoute(
              path: '/config',
              builder: (context, state) => const ConfigScreen(),
            ),
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
          initialLocation: initialLocation,
        );
        return MaterialApp.router(
          routerConfig: router,
          title: 'Odoo Products App',
        );
      },
    );
  }
}

void main() {
  runApp(const MyApp());
}
