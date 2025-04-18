import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:printify/providers/order_provider.dart';
import 'package:printify/providers/upload_provider.dart';
import 'package:printify/screens/auth/login_screen.dart';
import 'package:printify/splash_screen.dart';
import 'package:provider/provider.dart';
import '/config/theme.dart';
import '/providers/auth_provider.dart';
import '/services/auth_service.dart';
import '/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => UploadProvider()),
      ],
      child: MaterialApp(
        title: 'Printify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/settings': (context) => SettingsScreen(),
          '/login': (context) => LoginScreen(),
        },
      ),
    );
  }
}