import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lio/AuthenticationPages/homescreen.dart';
import 'package:lio/AuthenticationPages/login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return FutureBuilder(
      future: authProvider.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.hasData 
            ? HomePage() 
            : const LoginScreen();
      },
    );
  }
}