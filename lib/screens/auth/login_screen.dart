import "dart:io";
import "dart:developer";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:talk_space/api/apis.dart";
import "package:talk_space/helpers/dialogs.dart";
import "package:talk_space/main.dart";
import "package:talk_space/screens/home_screen.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  _handleGoogleButtonClick() {
    // For Showing Progress Bar
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async {
      // For removing Progress Bar
      Navigator.pop(context);
      if (user != null) {
        log("\nuser: ${user.user}");
        log('\nuserAdditionalInfo: ${user.additionalUserInfo}');

        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await APIs.CreateUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup("Google.com");
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log("\n_signInWithGoogle: $e");
      Dialogs.showSnackbar(context, 'Something went wrong (Check Internet!!!)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context)
        .size; // Never mentioned in main file, for relative positioning according to the device.
    return Scaffold(
      // AppBar.
      appBar: AppBar(
        // No leading Icon or Title.
        automaticallyImplyLeading: false,
        // Title of Home Screen.
        title: const Text('Let us Talk on TalkSpace'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 176, 250, 233),
      ),
      backgroundColor: Color.fromARGB(255, 164, 212, 252),
      body: Stack(
        children: [
          // For widgets ; Core Concept: Overlaying widgets(Layering widgets on top of each other).
          // Animated icon on login screen.
          AnimatedPositioned(
              top: mq.height * .15,
              right: _isAnimate ? mq.width * .25 : -mq.width * .5,
              width: mq.width * .50,
              duration: Duration(milliseconds: 1400),
              child: Image.asset('images/chatting.png')),
          // Google Login screen.
          Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .07,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 233, 233, 233),
                elevation: 1,
              ),
              onPressed: () {
                _handleGoogleButtonClick();
              },
              icon: Image.asset('images/google.png', height: mq.height * .05),
              label: RichText(
                // For styling our text.
                text: const TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w500),
                    children: [TextSpan(text: 'Login with Google')]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
