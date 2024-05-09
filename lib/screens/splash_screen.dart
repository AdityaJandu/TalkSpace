import "dart:developer";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:talk_space/api/apis.dart";
import "package:talk_space/main.dart";
import "package:talk_space/screens/auth/login_screen.dart";
import "package:talk_space/screens/home_screen.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      // Exit Full Screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          statusBarColor: Colors.transparent));
      // Check If User Already Logged In.
      if (APIs.auth.currentUser != null) {
        log('\nUser: ${APIs.auth.currentUser}');
        // Navigate to Home Screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
      // If Not Logged In Then.
      else {
        // Navigate to Login Screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context)
        .size; // Never mentioned in main file, for relative positioning according to the device.

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 154, 187, 215),
      body: Stack(children: [
        // For widgets ; Core Concept: Overlaying widgets(Layering widgets on top of each other).
        // App Icon on the Splash Screen.
        Positioned(
            top: mq.height * .15,
            right: mq.width * .25,
            width: mq.width * .50,
            child: Image.asset('images/chatting.png')),
        // Made in India and Heart Emoji.
        Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            left: mq.width * .25,
            child: const Text(
              'MADE IN INDIA WITH ❤️',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0)),
            ))
      ]),
    );
  }
}
