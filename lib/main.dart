import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:printify/models/user_model.dart';
import 'package:printify/splash_screen.dart';
import 'package:provider/provider.dart';
import '/config/theme.dart';
import '/providers/auth_provider.dart';
import '/services/auth_service.dart';
import '/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  );
  //copyDocument();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
      ],
      child: MaterialApp(
        title: 'Printify',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/settings': (context) => SettingsScreen(),
        },
      ),
    );
  }
}