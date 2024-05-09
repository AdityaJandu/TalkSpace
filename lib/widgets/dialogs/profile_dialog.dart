import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:talk_space/main.dart';
import 'package:talk_space/model/chat_user.dart';
import 'package:talk_space/screens/view_profile_screen.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
      content: SizedBox(
          width: mq.width * .6,
          height: mq.height * .35,
          child: Stack(
            children: [
              // User Profile Picture.
              Positioned(
                top: mq.height * .07,
                left: mq.width * .0865,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.width * .25),
                  child: CachedNetworkImage(
                      width: mq.width * .5,
                      fit: BoxFit.cover,
                      imageUrl: user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(CupertinoIcons.person,
                                color: Colors.white),
                          )),
                ),
              ),
              //User Name.
              Positioned(
                left: mq.width * .045,
                top: mq.width * .045,
                width: mq.width * .45,
                child: Text(
                  user.Name,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
              ),

              Positioned(
                right: 8,
                top: 8,
                child: MaterialButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ViewProfileScreen(user: user)));
                  },
                  minWidth: 0,
                  padding: EdgeInsets.zero,
                  shape: CircleBorder(),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
              )
            ],
          )),
    );
  }
}
