import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lio/AuthenticationPages/auth_wrapper.dart';
import 'package:lio/AuthenticationPages/login_screen.dart';
import 'package:lio/AuthenticationPages/register_screen.dart';
import 'AuthenticationPages/homescreen.dart';
import 'providers/auth_provider.dart'; 
import 'providers/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Add this
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'HomeScheduler',
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepPurple,
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.deepPurple,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Colors.deepPurple,
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.deepPurple,
            appBarTheme: AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.deepPurple[800],
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.deepPurple[800],
            ),
          ),
          themeMode: themeProvider.themeMode, // Use provider's theme mode
          initialRoute: '/',
          routes: {
            '/': (context) => const AuthWrapper(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => HomePage(),
          },
        );
      },
    );
  }
}
