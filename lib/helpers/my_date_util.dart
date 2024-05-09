import 'package:flutter/material.dart';

class MyDateUtil {
  // For Getting Formatted Time ......Time From MilliSecondsFromEpoch To String.
  static String getFormattedTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  // Get Formatted Time For Send And Read.
  static String getMessageTime(
      {required BuildContext context, required String time}) {
    final DateTime Send = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    final formattedTime = TimeOfDay.fromDateTime(Send).format(context);
    if (now.day == Send.day &&
        now.month == Send.month &&
        now.year == Send.year) {
      return formattedTime;
    }
    return now.year == Send.year
        ? '$formattedTime - ${Send.day} ${_getMonth(Send)}'
        : '$formattedTime - ${Send.day} ${_getMonth(Send)} ${Send.year}';
  }

  // For Getting Last Message Time.
  static String getLastMessageTime(
      {required BuildContext context,
      required String time,
      bool showYear = false}) {
    final DateTime Send = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if (now.day == Send.day &&
        now.month == Send.month &&
        now.year == Send.year) {
      return showYear
          ? '${Send.day} ${_getMonth(Send)} ${Send.year}'
          : TimeOfDay.fromDateTime(Send).format(context);
    }
    return showYear
        ? '${Send.day} ${_getMonth(Send)} ${Send.year}'
        : '${Send.day} ${_getMonth(Send)}';
  }

  //
  static String getLastActiveTime(
      {required BuildContext context, required String lastSeen}) {
    final int i = int.tryParse(lastSeen) ?? -1;
    // If Last Seen Is Not Avaliable.
    if (i == -1) return 'Last seen not avaliable';
    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return 'Last seen today at $formattedTime';
    }
    if ((now.difference(time).inHours / 24).round() == 1) {
      return 'Last seen yesterday at $formattedTime';
    }
    String month = _getMonth(time);
    return 'Last seen on ${time.day} $month on $formattedTime';
  }

  // For Getting Correct Format Of Month.
  static String _getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'Aug';
      case 9:
        return 'Sept';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'NA';
  }
}
