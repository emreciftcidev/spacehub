import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; 
import 'screens/home_screen.dart'; 
import 'package:uzay_bilgi_kartlari/screens/onboarding.dart'; 

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpaceHub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(), 
      routes: {
        '/home': (context) => HomeScreen(), 
        '/onboarding': (context) => OnboardingPage(), 
      },
    );
  }
}
