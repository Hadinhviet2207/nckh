import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nckh/viewmodels/forgot_password_viewmodel.dart';
import 'package:nckh/viewmodels/login_viewmodel.dart';
import 'package:nckh/viewmodels/register_viewmodel.dart';
import 'package:nckh/views/home/ChangePasswordScreen.dart';
import 'package:nckh/views/home/SettingsScreen.dart';
import 'package:nckh/views/home/account_screen.dart';
import 'package:nckh/views/home/edit_profile_screen.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'views/intro/intro_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(RockApp());
}

class RockApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Roboto'),
        home: Intro_HomeScreen(),
      ),
    );
  }
}
