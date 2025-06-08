import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stonelens/camera_screen.dart';
import 'package:stonelens/image_search_camera_screen.dart';
import 'package:stonelens/viewmodels/forgot_password_viewmodel.dart';
import 'package:stonelens/viewmodels/login_viewmodel.dart';
import 'package:stonelens/viewmodels/register_viewmodel.dart';
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
        home: ImageSearchCameraScreen(),
      ),
    );
  }
}
