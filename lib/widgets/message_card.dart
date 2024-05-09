import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:talk_space/api/apis.dart';
import 'package:talk_space/helpers/dialogs.dart';
import 'package:talk_space/helpers/my_date_util.dart';
import 'package:talk_space/main.dart';
import 'package:talk_space/model/message.dart';
import 'package:talk_space/translation/translation_services.dart';

class MessageCard extends StatefulWidget {
  final Message message;

  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromID;

    return InkWell(
        onLongPress: () {
          _showBottomSheet(isMe);
        },
        child: isMe ? _greenMessage() : _blueMessage());
  }

  // For Sender Or Another User Message.
  Widget _blueMessage() {
    // Update Last Seen Message if Sender And Receiver Are Different.
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadTime(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Message Content.
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                vertical: mq.height * .01, horizontal: mq.width * .04),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 168, 218, 251),
                border: Border.all(color: Colors.blueAccent, width: 1.3),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text

                // Show Text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 17, color: Colors.black87),
                  )

                // Show Image
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.black26,
                            ),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.image, size: 70)),
                  ),
          ),
        ),

        // For Message Time.
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: TextStyle(
                fontSize: 13.2,
                fontWeight: FontWeight.normal,
                color: Colors.black54),
          ),
        ),
      ],
    );
  }

  // For Our Or User Message.
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // For Adding Some Space.
            SizedBox(width: mq.width * .04),

            if (widget.message.read.isNotEmpty)
              Icon(
                Icons.done_all_rounded,
                color: Colors.blueAccent,
                size: 20,
              ),

            // For Adding Some Space.
            SizedBox(width: mq.width * .01),

            // For Text Send Time.
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: TextStyle(
                  fontSize: 13.2,
                  fontWeight: FontWeight.normal,
                  color: Colors.black54),
            ),
          ],
        ),

        // Message Content.
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                vertical: mq.height * .01, horizontal: mq.width * .04),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 156, 248, 159),
                border: Border.all(color: Colors.lightGreen, width: 1.3),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type == Type.text

                // Show Text
                ? Text(
                    widget.message.msg,
                    style: TextStyle(fontSize: 17, color: Colors.black87),
                  )

                // Show Image
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.black26,
                            ),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.image, size: 70)),
                  ),
          ),
        ),
      ],
    );
  }

  // Bottom Sheet On Long Pressing The Messages.
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(shrinkWrap: true, children: [
            // Divider.
            Container(
              alignment: Alignment.center,
              height: 4,
              margin: EdgeInsets.symmetric(
                  vertical: mq.height * .015, horizontal: mq.width * .371),
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 99, 99, 99),
                  borderRadius: BorderRadius.circular(10)),
            ),

            // Copy Text.
            widget.message.type == Type.image
                ? _optionItems(
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Save Image',
                    onTap: () async {
                      try {
                        await GallerySaver.saveImage(widget.message.msg,
                                albumName: "TalkSpace")
                            .then((success) {
                          // Hiding Bottom Sheet.
                          Navigator.pop(context);

                          // SnackBar Showing Msg Copied.
                          if (success != null && success)
                            Dialogs.showSnackbar(
                                context, 'Image Successfully Saved!');
                        });
                      } catch (e) {
                        log('Error While Saving Image $e');
                      }
                    })
                : _optionItems(
                    icon: const Icon(
                      Icons.copy_all_rounded,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Copy Text',
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        // Hiding Bottom Sheet.
                        Navigator.pop(context);

                        // SnackBar Showing Msg Copied.
                        Dialogs.showSnackbar(context, 'Text Copied');
                      });
                    }),

            // Separator Or Divider.
            Divider(
              color: Colors.black54,
              endIndent: mq.width * .04,
              indent: mq.width * .04,
            ),

            // Edit Text.
            if (widget.message.type == Type.text && isMe)
              _optionItems(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: 26,
                  ),
                  name: 'Edit Text',
                  onTap: () {
                    // Hiding Bottom Sheet.
                    Navigator.pop(context);

                    // Updating Messages.
                    _showMessageUpdateDialog();
                  }),

            //Delete Option.
            if (isMe)
              _optionItems(
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 26,
                  ),
                  name: 'Delete Message',
                  onTap: () async {
                    // For hiding bottom sheet
                    Navigator.pop(context);

                    // For deleting msg which isn't working yet.
                    await APIs.deleteMessage(widget.message);
                  }),

            // Translation Using Google Translator.
            _optionItems(
                icon: const Icon(Icons.translate, color: Colors.green),
                name: "Translate",
                onTap: () async {
                  //for hiding bottom sheet
                  Navigator.pop(context);
                  String translatedMessage =
                      await TranslationService.translateToHindi(
                          widget.message.msg);
                  log(translatedMessage);
                  Dialogs.showMsgTranslated(context, translatedMessage);
                }),

            if (isMe)
              // Separator Or Divider.
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

            //Sent Time.
            _optionItems(
                icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                name:
                    'Sent Time: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)} ',
                onTap: () {}),

            // Read Time.
            _optionItems(
                icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                name: widget.message.read.isEmpty
                    ? 'Not Seen Yet'
                    : 'Read Time: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                onTap: () {}),
          ]);
        });
  }

  // The Dialog For Updating Messages.
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding:
                  EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 25),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23)),

              // Title Of The Alert Dialog.
              title: Row(children: [
                Icon(Icons.message, color: Colors.blue, size: 28),
                Text(
                  '  Update Message',
                  style: TextStyle(fontSize: 20),
                )
              ]),

              // Content Of The Alert Dialog.
              content: TextFormField(
                maxLines: null,
                initialValue: updatedMsg,
                onChanged: (value) => updatedMsg = value,
                style: TextStyle(fontSize: 16, color: Colors.black),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),

              // Buttons.
              actions: [
                MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    onPressed: () {
                      //Removing The Alert Dialog Without Any Change.
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                    )),
                MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    onPressed: () {
                      //Hide The Alert Dialog.
                      Navigator.pop(context);
                      APIs.updateMessage(widget.message, updatedMsg);
                    },
                    child: Text(
                      "Update",
                      style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                    ))
              ],
            ));
  }
}

class _optionItems extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _optionItems(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * .015,
            bottom: mq.height * .015),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text("      $name",
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16.8,
                        letterSpacing: .4,
                        fontWeight: FontWeight.w500)))
          ],
        ),
      ),
    );
  }
}
