import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_space/api/apis.dart';
import 'package:talk_space/helpers/my_date_util.dart';
import 'package:talk_space/main.dart';
import 'package:talk_space/model/chat_user.dart';
import 'package:talk_space/model/message.dart';
import 'package:talk_space/screens/view_profile_screen.dart';
import 'package:talk_space/widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // For Storing The Messages.
  List<Message> _list = [];

  // For Handling Message Text Changes.
  final _textController = TextEditingController();

  // _showEmoji --> For Checking Weather To Show Emoji
  // _isUploading --> Hide It And Other One Is To Check Weather Image(s) Are Uploading Or Not.
  bool _showEmoji = false, _isUploading = false;

  // For Blocking and unblocking user.
  // bool _isBlock = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: () {
          // If Emojis Are Shown And Back Button Is Pressed Hide Those Emojis On First Back Rather Than Exiting Chat Screen.
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 179, 178, 176),
            flexibleSpace: _appBar(),
          ),
          backgroundColor: Color.fromARGB(255, 201, 233, 255),
          body: Padding(
            padding: EdgeInsets.only(bottom: mq.height * 0.011),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        // If data is loading.
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                        // If some or all data is loaded then show it.
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;

                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          // if (_isBlock) {
                          //   // To Block Any User.
                          //   return const Center(
                          //     child: Text(
                          //       "User is blocked ... Unblock to chat",
                          //       style: TextStyle(
                          //           fontSize: 20,
                          //           fontWeight: FontWeight.w600,
                          //           color: Colors.redAccent),
                          //     ),
                          //   );} else

                          if (_list.isNotEmpty) {
                            // List is not empty; that means user exists.
                            return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: mq.height * .002),
                              physics: BouncingScrollPhysics(),
                              itemBuilder: ((context, index) {
                                return MessageCard(message: _list[index]);
                              }),
                            );
                          } else {
                            // List is empty, so that means no user found.
                            return const Center(
                              child: Text(
                                "Start Chatting Now👋!!",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 249, 83, 147)),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),

                // Progress Indicator Just To Show File{Image} Is Uploading
                if (_isUploading)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: mq.width * .015, right: mq.width * .06),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // Adding Chat Input Function.
                _chatInput(),

                // For Showing Emojis From Package --> {Emoji-Picker}
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController:
                          _textController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                      config: Config(
                        bgColor: const Color.fromARGB(255, 201, 233, 255),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.20 : 1.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // AppBar for Our Chat-Screen.
  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewProfileScreen(user: widget.user),
          ),
        );
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final _list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

          return Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User Profile Picture.
              Padding(
                padding: EdgeInsets.only(
                  top: mq.width * .099,
                  left: mq.width * .13,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .2),
                  child: CachedNetworkImage(
                    width: mq.height * .05,
                    height: mq.height * .05,
                    imageUrl:
                        _list.isNotEmpty ? _list[0].image : widget.user.image,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(
                        CupertinoIcons.person,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding:
                    EdgeInsets.only(top: mq.width * .095, left: mq.width * .04),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // For User's Name.
                    Text(
                      _list.isNotEmpty ? _list[0].Name : widget.user.Name,
                      style: TextStyle(
                          fontSize: 17,
                          color: Color.fromARGB(255, 43, 42, 42),
                          fontWeight: FontWeight.w500),
                    ),

                    // For User's Last-Seen.
                    Text(
                      _list.isNotEmpty
                          ? _list[0].is_Online
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                  context: context, lastSeen: _list[0].lastSeen)
                          : MyDateUtil.getLastActiveTime(
                              context: context, lastSeen: widget.user.lastSeen),
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 43, 42, 42),
                          fontWeight: FontWeight.w400),
                    )
                  ],
                ),
              ),

              //  Button to block and unblock
              // _isBlock
              //     ? Padding(
              //         padding: EdgeInsets.only(
              //             top: mq.width * .095, right: mq.width * .1),
              //         child: IconButton(
              //           onPressed: () {
              //             setState(() {
              //               // _isBlock = !_isBlock;
              //             });
              //           },
              //           icon: const Icon(
              //             Icons.block_flipped,
              //             color: Colors.green,
              //           ),
              //         ),
              //       )
              //     :
              // Padding(
              //   padding:
              //       EdgeInsets.only(top: mq.width * .095, right: mq.width * .1),
              //   child: IconButton(
              //     onPressed: () {
              //       setState(
              //         () {
              //           // _isBlock = !_isBlock;
              //         },
              //       );
              //     },
              //     icon: const Icon(
              //       Icons.block,
              //       color: Colors.red,
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }

// Chat Input Card For Chat-Screen.
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: mq.width * .0115, vertical: mq.width * .015),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                // Emoji Button.
                IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() => _showEmoji = !_showEmoji);
                  },
                  icon: Icon(Icons.emoji_emotions),
                  color: Color.fromARGB(255, 52, 187, 255),
                  iconSize: 28,
                ),

                // For Some Space
                SizedBox(width: mq.width * .01),

                Expanded(
                    child: TextField(
                  controller: _textController,
                  maxLines: null,
                  onTap: () {
                    if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                  },
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                      hintText: 'Type Your Message...',
                      hintStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontSize: 16),
                      border: InputBorder.none),
                )),

                // Gallery Button.
                IconButton(
                  onPressed: () async {
                    // The Package Image Picker To Pick Multiple Image(s) From Gallery.
                    final ImagePicker picker = ImagePicker();
                    final List<XFile>? images =
                        await picker.pickMultiImage(imageQuality: 70);
                    //Uploading And Sending Image(s) One By One.
                    for (var i in images!) {
                      // For Progress Indicator Just To Show File Is Uploading.
                      setState(() => _isUploading = true);
                      // For Sending The Picture(s) You Want To Send.
                      await APIs.sendChatImage(widget.user, File(i.path));
                      // After Each File Is Uploaded Remove Indicator.
                      setState(() => _isUploading = false);
                    }
                  },
                  icon: Icon(Icons.image),
                  color: Color.fromARGB(255, 52, 187, 255),
                  iconSize: 26,
                ),

                // Camera Button.
                IconButton(
                  onPressed: () async {
                    // The Package Image Picker To Pick Image From Camera.
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 70);
                    if (image != null) {
                      // For Progress Indicator Just To Show File Is Uploading.
                      setState(() => _isUploading = true);
                      // For Sending The Picture You Want To Send.
                      await APIs.sendChatImage(widget.user, File(image.path));
                      // After Each File Is Uploaded Remove Indicator.
                      setState(() => _isUploading = false);
                    }
                  },
                  icon: Icon(Icons.camera_enhance),
                  color: Color.fromARGB(255, 52, 187, 255),
                  iconSize: 26,
                ),

                // For Some Space
                SizedBox(width: mq.width * .01)
              ]),
            ),
          ),

          // Send Message Button.
          MaterialButton(
            shape: CircleBorder(),
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            color: Colors.green,
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                _list.isEmpty
                    // On first message {add user to my_user collection of chat-user}
                    ? APIs.sendFirstMessage(
                        widget.user, _textController.text, Type.text)
                    // Simply send a message
                    : APIs.sendMessage(
                        widget.user, _textController.text, Type.text);
                _textController.text = '';
              }
            },
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          )
        ],
      ),
    );
  }
}
