import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:talk_space/api/apis.dart';
import 'package:talk_space/helpers/my_date_util.dart';
import 'package:talk_space/main.dart';
import 'package:talk_space/model/chat_user.dart';
import 'package:talk_space/model/message.dart';
import 'package:talk_space/screens/chat_screen.dart';
import 'package:talk_space/widgets/dialogs/profile_dialog.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // Last Message Information.
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: mq.width * .03, vertical: 4),
        color: Color.fromARGB(255, 255, 255, 255),
        elevation: 1.4,

        //shadowColor: const Color.fromARGB(255, 118, 167, 251),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatScreen(user: widget.user)));
            },
            child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final _list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (_list.isNotEmpty) _message = _list[0];

                return ListTile(
                  // User Profile Pictures.
                  leading: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) => ProfileDialog(user: widget.user));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .3),
                      child: CachedNetworkImage(
                          width: mq.height * .058,
                          height: mq.height * .058,
                          imageUrl: widget.user.image,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Icon(CupertinoIcons.person,
                                    color: Colors.white),
                              )),
                    ),
                  ),

                  // User Name.
                  title: Text(widget.user.Name),

                  // Last Message If Exists Or About Of User.
                  subtitle: Text(
                    _message != null
                        ? _message!.type == Type.image
                            ? 'Image'
                            : _message!.msg
                        : widget.user.About,
                    maxLines: 1,
                  ),

                  // Users Last Message Time.
                  trailing: _message == null
                      ? Icon(
                          Icons.circle,
                          color: const Color.fromARGB(255, 94, 252, 176),
                          size: 20,
                        )
                      : Text(
                          MyDateUtil.getLastMessageTime(
                              context: context, time: _message!.sent),
                          style: TextStyle(color: Colors.black54),
                        ),
                );
              },
            )));
  }
}
