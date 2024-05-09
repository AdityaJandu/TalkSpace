import 'dart:developer';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:talk_space/api/apis.dart';
import 'package:talk_space/helpers/dialogs.dart';
import 'package:talk_space/main.dart';
import 'package:talk_space/model/chat_user.dart';
import 'package:talk_space/screens/profile_screen.dart';
import 'package:talk_space/widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  // For Storing All Users.
  List<ChatUser> _list = [];
  // For Searching Particular User or Groups.
  final List<ChatUser> _searchList = [];
  // For Storing Search Status.
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    // For Updating User Active Status According To Lifecycle Events.
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        // Resumed --> Active Or Online.
        if (message.toString().contains('resumed')) {
          APIs.updateActiveStatus(true);
        }

        // Paused --> Inactive Or Offline.
        if (message.toString().contains('paused')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Using Query for Sizing According to the Device used.
    mq = MediaQuery.of(context).size;
    return GestureDetector(
      // For Hiding Keyboard on Tapping Screen at Anyplace.
      onTap: () => FocusScope.of(context).unfocus(),
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            // AppBar.
            appBar: AppBar(
              backgroundColor: Color.fromARGB(255, 161, 159, 159),
              // Title of Home Screen.
              title: _isSearching
                  ? TextField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search By Name, Email.....',
                      ),
                      autofocus: true,
                      style: TextStyle(fontSize: 17, letterSpacing: .5),
                      // When Search Text Changes Then Update Search List.
                      onChanged: (value) {
                        // Implementation Of Search Logic:
                        _searchList.clear();
                        for (var i in _list) {
                          if (i.Name.toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              i.email
                                  .toLowerCase()
                                  .contains(value.toLowerCase())) {
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      },
                    )
                  : Padding(
                      padding: EdgeInsets.only(left: mq.width * .018),
                      child: Text(
                        'TalkSpace',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.deepPurple[700],
                        ),
                      ),
                    ),
              actions: [
                // Search Button.
                IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(_isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : CupertinoIcons.search)),
                // More Features Button.
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfileScreen(user: APIs.me)));
                    },
                    icon: const Icon(Icons.more_vert))
              ],
            ),
            // Floating add {To add new users} button and it's padding.
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 13, right: 8),
              child: FloatingActionButton(
                  onPressed: () {
                    _addNewUser();
                  },
                  child: const Icon(Icons.add_rounded)),
            ),
            // Adding Body To Home-Screen.
            body: StreamBuilder(
                stream: APIs.getMyUsersID(),

                // Get IDs Of Only Known Users.
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    // If data is loading.
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                    // return const Center(child: CircularProgressIndicator());

                    // If some or all data is loaded then show it.
                    case ConnectionState.active:
                    case ConnectionState.done:
                      return StreamBuilder(
                        stream: APIs.getAllUsers(
                            snapshot.data?.docs.map((e) => e.id).toList() ??
                                []),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            // If data is loading.
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              return const Center(
                                  child: CircularProgressIndicator());

                            // If some or all data is loaded then show it.
                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;

                              _list = data
                                      ?.map((e) => ChatUser.fromJson(e.data()))
                                      .toList() ??
                                  [];

                              if (_list.isNotEmpty) {
                                // List is not empty; that means user exists.
                                return ListView.builder(
                                    itemCount: _isSearching
                                        ? _searchList.length
                                        : _list.length,
                                    padding:
                                        EdgeInsets.only(top: mq.height * .002),
                                    physics: BouncingScrollPhysics(),
                                    itemBuilder: ((context, index) {
                                      return ChatUserCard(
                                          user: _isSearching
                                              ? _searchList[index]
                                              : _list[index]);
                                    }));
                              } else {
                                // List is empty, so that means no user found.
                                return const Center(
                                    child: Text(
                                  "No Connections Found!",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 247, 23, 86)),
                                ));
                              }
                          }
                        },
                      );
                  }
                })),
      ),
    );
  }

  // The Dialog For Adding Chat-user To Chat.
  void _addNewUser() {
    String email = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.deepOrange[50],
        contentPadding:
            EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),

        // Title Of The Alert Dialog.
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.person_add_alt, color: Colors.deepPurple[300], size: 28),
            Text(
              'Add User To Chat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),

        // Content Of The Alert Dialog.
        content: TextFormField(
          textAlign: TextAlign.center,
          maxLines: null,
          onChanged: (value) => email = value,
          style: TextStyle(fontSize: 16, color: Colors.black),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            hintText: 'Add Email Address',
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: mq.width * .03),
              child: Icon(
                Icons.email,
                color: Colors.green,
              ),
            ),
            hintStyle: TextStyle(
              fontSize: 16,
              color: Colors.deepPurple[400],
            ),
          ),
        ),

        // Buttons.
        actions: [
          MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              onPressed: () {
                //Removing The Alert Dialog Without Any Change.
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: 18, color: Colors.red),
              )),
          MaterialButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            onPressed: () async {
              //Hide The Alert Dialog.
              Navigator.pop(context);
              if (email.isNotEmpty) {
                await APIs.addChatUser(email).then(
                  (value) {
                    if (!value) {
                      Dialogs.showSnackbar(context, 'User doesn\'t exists.');
                    }
                  },
                );
              }
            },
            child: Text(
              "Add",
              style: TextStyle(
                fontSize: 18,
                color: Colors.deepPurple.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
