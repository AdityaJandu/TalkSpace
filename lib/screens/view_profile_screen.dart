import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:talk_space/helpers/my_date_util.dart';
import 'package:talk_space/main.dart';
import 'package:talk_space/model/chat_user.dart';

// Profile Screen --> To Show Signed In User Info And Update The Info At Firebase.

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreen();
}

// View Profile Screen To View Profile Of A User
class _ViewProfileScreen extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // Using Query for Sizing According to the Device used.
    mq = MediaQuery.of(context).size;
    return GestureDetector(
      // For Hiding Keyboard on Tapping Screen at Anyplace.
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          // AppBar.
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 161, 159, 159),
            // Title of Home Screen.
            title: Text(widget.user.Name),
            centerTitle: true,
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Joined On: ',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              Text(
                  MyDateUtil.getLastMessageTime(
                      context: context,
                      time: widget.user.createdAt,
                      showYear: true),
                  style: const TextStyle(color: Colors.black87, fontSize: 18)),
            ],
          ),

          // Adding Body To Home-Screen.
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // For Adding Some Space.{Horizontally and Vertically}
                  SizedBox(width: mq.width, height: mq.width * .18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                        width: mq.height * .2,
                        height: mq.height * .2,
                        fit: BoxFit.cover,
                        imageUrl: widget.user.image,
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(CupertinoIcons.person,
                                  color: Colors.white),
                            )),
                  ),

                  // For Adding Some Space Between Profile Picture And Email Id Of User.
                  SizedBox(height: mq.width * .05),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Email: ',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      Text(widget.user.email,
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 18)),
                    ],
                  ),
                  // For Adding Some Space Between Email Id And Name Of User.
                  SizedBox(height: mq.width * .02),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'About: ',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      Text(widget.user.About,
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
