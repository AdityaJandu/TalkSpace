import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_space/api/apis.dart';
import 'package:talk_space/helpers/dialogs.dart';
import 'package:talk_space/main.dart';
import 'package:talk_space/model/chat_user.dart';
import 'package:talk_space/screens/auth/login_screen.dart';

// Profile Screen --> To Show Signed In User Info And Update The Info At Firebase.

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  // For Bottom Sheet For Picking A Profile Picture.
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .025, bottom: mq.height * .05),
            children: [
              const Text(
                // Label To Indicate Pick Picture.
                'Pick A Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),

              // For Adding Some Space.
              SizedBox(height: mq.height * .01),
              // Buttons.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pick From Gallery Button.
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0.2,
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          log('Image Path: ${image.path} ');
                          setState(() {
                            _image = image.path;
                          });
                          // For Updating The Profile Picture.
                          APIs.updateProfilePicture(File(_image!));
                          // For Hiding Bottom Sheet.
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/add-image.png')),

                  // Take A Picture From Camera.
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0.2,
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          log('Image Path: ${image.path} ');
                          setState(() {
                            _image = image.path;
                          });
                          // For Updating The Profile Picture.
                          APIs.updateProfilePicture(File(_image!));
                          // For Hiding Bottom Sheet.
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.png'))
                ],
              )
            ],
          );
        });
  }

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
            title: const Text('Profile Screen'),
            centerTitle: true,
          ),
          // Floating Log-Out button and it's padding.
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 13, right: 8),
            child: FloatingActionButton.extended(
              onPressed: () async {
                // For Showing Progress Dialogs.
                Dialogs.showProgressBar(context);

                await APIs.updateActiveStatus(false);

                await APIs.auth.signOut().then((value) async {
                  // Sign Out From App:
                  await GoogleSignIn().signOut().then((value) => {
                        // For Hiding Progress Dialogs.
                        Navigator.pop(context),
                        // For Moving to Home-Screen.
                        Navigator.pop(context),

                        APIs.auth = FirebaseAuth.instance,

                        // Replacing Home-Screen to Login-Screen.
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => LoginScreen()))
                      });
                });
              },
              icon: const Icon(Icons.logout_outlined),
              label: const Text("Logout"),
            ),
          ),
          // Adding Body To Home-Screen.
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // For Adding Some Space.{Horizontally and Vertically}
                    SizedBox(width: mq.width, height: mq.width * .18),
                    Stack(
                      children: [
                        _image != null
                            ? // Profile Picture.
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: Image.file(
                                  File(_image!),
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  fit: BoxFit.cover,
                                ),
                              )
                            :
                            // Profile Picture.
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
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

                        // Edit Button Over Profile Picture.
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                              elevation: 0.7,
                              onPressed: () {
                                _showBottomSheet();
                              },
                              shape: CircleBorder(),
                              color: Color.fromARGB(255, 139, 253, 247),
                              child: Icon(
                                Icons.edit,
                                color: Color.fromARGB(185, 252, 16, 181),
                              )),
                        )
                      ],
                    ),

                    // For Adding Some Space Between Profile Picture And Email Id.
                    SizedBox(height: mq.width * .03),

                    Text(widget.user.email,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 18)),

                    // For Adding Some Space.
                    SizedBox(height: mq.width * .05),

                    // Form Field for Name Section.
                    TextFormField(
                      initialValue: widget.user.Name,
                      onSaved: (val) => APIs.me.Name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          hintText: 'Eg: Aditya Aditya',
                          labelText: 'Name',
                          labelStyle: TextStyle(fontSize: 15.5)),
                    ),

                    // For Adding Some Space.
                    SizedBox(height: mq.width * .03),

                    // Form Field for About Section.
                    TextFormField(
                      initialValue: widget.user.About,
                      onSaved: (val) => APIs.me.About = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.info_outline,
                            color: Colors.blue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          hintText: 'Eg: I`m busy',
                          labelText: 'About',
                          labelStyle: TextStyle(fontSize: 15.5)),
                    ),

                    // For Adding Some Space.
                    SizedBox(height: mq.width * .04),

                    // Update Profile Button.
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          minimumSize: Size(mq.width * .5, mq.height * .055),
                          backgroundColor: Color.fromARGB(255, 214, 139, 255),
                          foregroundColor: Color.fromARGB(255, 186, 255, 250)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) {
                            Dialogs.showSnackbar(
                                context, 'Profile Updated Successfully!');
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.edit,
                        size: 24,
                      ),
                      label: const Text(
                        'Update',
                        style: TextStyle(fontSize: 17),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
