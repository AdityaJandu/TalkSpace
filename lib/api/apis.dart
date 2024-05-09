import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:talk_space/model/chat_user.dart';
import 'package:talk_space/model/message.dart';

class APIs {
  // For Authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // For Accessing Cloud FireStore Database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // For Accessing Firebase Storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // To Return Current User.
  static User get user => auth.currentUser!;

  // For storing Self Info:
  static late ChatUser me;

  // For Accessing Messaging {Push Notification}
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // For Getting Firebase Messaging Token
  static Future<void> getFirebaseMessagingToken() async {
    // Requesting User To Allow Notifications.
    await fMessaging.requestPermission();

    // Function To Get Token.
    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log("Push Token: $t");
      }
    });

    // For Handling Foreground Notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  // For Getting Push Notifications
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    // Using Try And Catch To Check For Exception And Complete Execution.
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.Name,
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "Some_Data": "User ID: ${me.id}",
        },
      };
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAwHyzwbA:APA91bHPH7oHdULhEYGugNoNRfojW9aYyxjCwsPrsRtSSuSNRaZdfA1LP80oPK-iUJsobIfo9fNZYWUHTBbIuFNYPlPON8RwYz2e_2YLyRnWru8-TwY5pnzJpS5h-0w5EauBIesUIohQ',
          },
          // Encoding Body To Json.
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nSendPushNotificationE: $e');
    }
  }

  // For Checking If User Exits Or Not?
  static Future<bool> userExists() async {
    return (await firestore.collection('Users').doc(user.uid).get()).exists;
  }

  // For Adding A New Chat-User For Our Conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      log('user Exists: ${data.docs.first.data()}');

      // User Exists And Not Himself.
      firestore
          .collection('Users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      // User Not Exists Or Is Himself.
      return false;
    }
  }

  // For creating a new user
  static Future<void> CreateUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        image: user.photoURL.toString(),
        lastSeen: time,
        createdAt: time,
        is_Online: false,
        pushToken: '',
        email: user.email.toString(),
        About: 'Hey, Im Using TalkSpace',
        Name: user.displayName.toString());

    return await firestore
        .collection('Users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // For getting all the Users from Firestore.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIDs) {
    log('User IDs: $userIDs');
    return firestore
        .collection('Users')
        .where('id', whereIn: userIDs.isEmpty ? [''] : userIDs)
        .snapshots();
  }

  // For getting ID of the known Users from Firestore Database.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersID() {
    return firestore
        .collection('Users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  //For Updating User Info.
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('Users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  // For Getting Current user info:
  static Future<void> getSelfInfo() async {
    await firestore.collection('Users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        // For Setting User Status To Active.
        APIs.updateActiveStatus(true);
        log('My Data: ${user.data()} ');
      } else {
        await CreateUser().then((value) => getSelfInfo());
      }
    });
  }

  //For Updating User Info.
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('Users')
        .doc(user.uid)
        .update({'Name': me.Name, 'About': me.About});
  }

  // For Updating Profile Pictures.
  static Future<void> updateProfilePicture(File file) async {
    // Getting Image File Extension For Consistency.
    final ext = file.path.split('.').last;
    log('Extension: ${ext}');
    // Storage Reference With Path.
    final ref = storage.ref().child('Profile Pictures/${user.uid}.$ext');
    // Uploading Images.
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    // Updating Firestore Database.
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('Users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  // For Getting Specific Information Of A User.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('Users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // For Updating Online Or Last Active Status.
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('Users').doc(user.uid).update({
      'is_Online': isOnline,
      'last_seen': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  /**************************    CHAT-SCREEN RELATED APIs    **************************************/

  // For Getting Conversation IDs
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // For Getting Messages All The Messages From A Specific Conversation From Firestore.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/Messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // For Sending Message.
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    // Message Sending Time Also Used As Message ID.
    final TIME = DateTime.now().millisecondsSinceEpoch.toString();
    // Message To Be Send.
    final Message message = Message(
        toID: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromID: user.uid,
        sent: TIME);
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/Messages/');

    await ref.doc().set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'Image'));
  }

  //For Updating Message Read Status.
  static Future<void> updateMessageReadTime(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromID)}/Messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // For Last Message Of User.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/Messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // For Sending Pictures From Gallery And Camera.
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    // Getting Image File Extension For Consistency.
    final ext = file.path.split('.').last;

    // Storage Reference With Path.
    final ref = storage.ref().child(
        'Images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    // Uploading Images.
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    // Updating Firestore Database.
    final ImageURL = await ref.getDownloadURL();
    await sendMessage(chatUser, ImageURL, Type.image);
  }

  //Delete Messages
  static Future<void> deleteMessage(Message message) async {
    log('deletedMessage: ${message}');
    await firestore
        .collection('chats/${getConversationID(message.toID)}/Messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //Update message
  static Future<void> updateMessage(
      Message message, String updatedMessage) async {
    log('updatedMessage: $updatedMessage');
    await firestore
        .collection('chats/${getConversationID(message.toID)}/Messages/')
        .doc(message.sent)
        .update({'msg': updatedMessage});
  }
}
