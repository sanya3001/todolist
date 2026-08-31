import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nexowa_core/nexowa_core.dart'
    hide NotificationService;
import 'package:provider/provider.dart';

import 'package:todolist/providers/todo_provider.dart';
import 'package:todolist/view/screens/splash_screen.dart';
import 'package:todolist/services/notification_service.dart';
import 'package:todolist/services/firebase_messaging_service.dart';

import 'config/di_container.dart' as di;
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase Messaging background handler
  FirebaseMessaging.onBackgroundMessage(
    FirebaseMessagingService.firebaseMessagingBackgroundHandler,
  );

  // Firebase Messaging initialize
  await FirebaseMessagingService.init();

  await di.init();

  // Existing local notification service
  await NotificationService.initNotification();

  runApp(
    ChangeNotifierProvider(
      create: (_) => TodoProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NexowaCore.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}