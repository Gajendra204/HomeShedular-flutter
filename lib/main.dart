import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lio/AuthenticationPages/OTP.dart';
import 'package:lio/AuthenticationPages/auth_wrapper.dart';
import 'package:lio/AuthenticationPages/login_screen.dart';
import 'package:lio/AuthenticationPages/register_screen.dart';
import 'AuthenticationPages/verifySuccess.dart';
import 'AuthenticationPages/homescreen.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart'; // <-- Ensure this file exists

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KIBU',
      theme: ThemeData.light(), // Light theme
      darkTheme: ThemeData.dark(), // Dark theme
      themeMode: ThemeMode.dark, // Force dark mode for all screens
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) =>
            const HomePage(), // Fixed route name to include forward slash
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomePage(),
    );
  }
}
