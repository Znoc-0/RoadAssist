import 'package:flutter/material.dart';
import 'auth_selector.dart';
import 'homeUser.dart';
import 'homeSeller.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pump Registration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthSelectorScreen(),
      // home:SellerHomeScreen(  emailId: '', )
    );
  }
}

