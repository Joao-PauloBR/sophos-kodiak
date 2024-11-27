import 'package:flutter/material.dart';
import 'package:sophos_kodiak/screens/login_screen.dart';

class SophosKodiak extends StatelessWidget {
  const SophosKodiak({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sophos Kodiak',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
