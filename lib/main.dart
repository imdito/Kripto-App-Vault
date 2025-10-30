import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'LoginRegister/login_register_view.dart';
import 'LoginRegister/signin_up_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kripto App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Color(0xFF117f4e),
      ),
      home: Registerview(),
    );
  }
}

