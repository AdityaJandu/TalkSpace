import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:talk_space/screens/splash_screen.dart';
import 'firebase_options.dart';

// Global Object for device size screen (Media Querying)
late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Starting to full screen mode.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  //Setting Device Orientation that is Portrait Mode.
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    // After Orientation Setting Start App For Zero Glitches.
    _intializeFirebase();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TalkSpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
              color: Colors.black, fontWeight: FontWeight.normal, fontSize: 20),
          backgroundColor: Colors.white,
        ),
      ),
      home: SplashScreen(),
    );
  }
}

_intializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  var result = await FlutterNotificationChannel.registerNotificationChannel(
      description: 'For Showing Message Descriptions.',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats');
  log('\nNotification Channel Result  $result');
}
