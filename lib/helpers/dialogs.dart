import 'package:flutter/material.dart';
import 'package:talk_space/main.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text(
          msg,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: .5,
              wordSpacing: 1),
        ),
        backgroundColor: Colors.blue.withOpacity(.8),
        behavior: SnackBarBehavior.floating));
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }

  static void showMsgTranslated(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.deepOrange[100],
        title: Padding(
          padding: EdgeInsets.only(top: mq.height * .025),
          child: Text(
            'Translated Text',
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(48)),
        content: Padding(
          padding: EdgeInsets.only(top: mq.width * .05),
          child: SizedBox(
            width: mq.width * .5,
            height: mq.height * .12,
            child: Text(
              msg,
              maxLines: null,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
