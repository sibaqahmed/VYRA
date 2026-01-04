import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screen/main_screen.dart';
import 'features/meeting/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  runApp(const VyraApp());
}

class VyraApp extends StatelessWidget {
  const VyraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VYRA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // 🔥 AUTH STATE HANDLED ONCE — NO FLICKER
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // ⏳ Firebase still deciding
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // ❌ Not logged in
          if (!snapshot.hasData) {
            return const LoginScreen();
          }

          // ✅ Logged in — STABLE
          return const MainScreen();
        },
      ),
    );
  }
}
