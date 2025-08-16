import 'package:adv_todo_app/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:adv_todo_app/controller/todo_controller.dart';

import 'views/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Advanced Todo',
      theme: ThemeData(
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Container(),
      //HomeView(),
      home: HomeView(),
      initialBinding: BindingsBuilder(() {
        Get.put(TodoController());
      }),
    );
  }
}
