import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../models/ChatRoomModel.dart';
import '../models/MessagesModel.dart';
import '../models/notification_services.dart';
import '../models/usermodel.dart';

class Chat_Screen extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const Chat_Screen(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<Chat_Screen> createState() => _Chat_ScreenState();
}

class _Chat_ScreenState extends State<Chat_Screen> {
  TextEditingController _controller = TextEditingController();
  bool emojiShowing = false;
  late ChatRoomModel _chatRoomModel;
  int counter = 0;
  NotificationServices notificationServices = NotificationServices();
  @override
  void initState() {
    get();
    super.initState();
    _chatRoomModel = widget.chatroom;
    if (_chatRoomModel.lastMessageSendBy !=
        FirebaseAuth.instance.currentUser!.uid) {
      _chatRoomModel.unreadMessageCount = 0;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(_chatRoomModel.chatroomid)
          .set(_chatRoomModel.toMap());
    }
  }

  get() async {
    var snapshot =
        await FirebaseFirestore.instance.collection("chatrooms").get();
    List user = [];
    snapshot.docs.forEach((e) {
      if (e['chatroomid'] == _chatRoomModel.chatroomid) {
        print("e::${e['chatroomid']}");
        user.add(e);
      }
    });
    print("Count::${user[0]['unreadmessagecount']}");
    _chatRoomModel.unreadMessageCount = user[0]['unreadmessagecount'];
  }

  _onEmojiSelected(Emoji emoji) {
    _controller
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
  }

  _onBackspacePressed() {
    _controller
      ..text = _controller.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
  }

  void sendMessage() async {
    String msg = _controller.text.trim();
    _controller.clear();

    if (msg != "") {
      notificationServices.getDeviceToken().then((value) async {
        var data = {
          'to': widget.targetUser.pushToken.toString(),
          // 'to': 'd6giDUjTSIKs76P7TQPnaD:APA91bEYrQJaI76LrvEKj98xzBTWhAYj--oAbVUE3YuRLMWcDzJiYwTIyaJTvsRvLFLcnjMDmVf2YKjE1ejS8UgnZUyiVf81_xVZrEjv6YvGHtTEyFSiGAo02DYsxo4Jb5fJYmqOpWOs',
          'priority': 'high',
          'notification': {
              'title': widget.userModel.fullname,
              'body': msg,
          },
          'android': {
            'notification': {
              // 'title': widget.userModel.fullname,
              // 'body': msg,
              // 'android_channel_id': "Messages",
              // 'count': 10,
              // 'notification_count': 12,
              // 'badge': 12,
              // "click_action": 'asif',
              'icon':'stock_ticker_update',
              'color': '#eeeeee',
            },
          },

          // 'data': {
          // 'type': 'msj',
          //   'id': 'asif1245',
          // }
        };
        print("data::::::: ${data}");
        await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
            body: jsonEncode(data),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization':
                  'key=AAAAJqDzyL8:APA91bEEAjOKadPOMON5P2d49W_7MDpfUpw4CQcuUJmD1rGZckSJFp35UPC-D6Qzk-VYg5yHd-yzNkEg5k-PrrMY1Cq4K4sxBDtm-xkxIquUUXP0tjf6QET8_Yd_kWxL8GxQzzXXurJn'
            });
        print("NOTIFICATIONSENT:::");
      });
      // Send Message
      counter = counter + 1;
      MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      _chatRoomModel.lastMessage = msg;
      _chatRoomModel.lasttime = DateTime.now();
      var snapshot =
          await FirebaseFirestore.instance.collection("chatrooms").get();
      List user = [];
      snapshot.docs.forEach((e) {
        if (e['chatroomid'] == _chatRoomModel.chatroomid) {
          print("e::${e['chatroomid']}");
          user.add(e);
        }
      });
      print("Count::${user[0]['unreadmessagecount']}");
      _chatRoomModel.unreadMessageCount = user[0]['unreadmessagecount'];
      _chatRoomModel.lastMessageSendBy = FirebaseAuth.instance.currentUser!.uid;
      // DateFormat('hh:mm a').format(DateTime.now()).toString();
      print('READ: ${_chatRoomModel.unreadMessageCount}');
      _chatRoomModel.unreadMessageCount = _chatRoomModel.lastMessageSendBy ==
              FirebaseAuth.instance.currentUser!.uid
          ? (widget.chatroom.unreadMessageCount ?? 0) + 1
          : 0;
      _chatRoomModel.lastMessageSendBy = widget.userModel.uid;

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(_chatRoomModel.chatroomid)
          .set(_chatRoomModel.toMap());

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(_chatRoomModel.chatroomid)
          .set(_chatRoomModel.toMap());

      print("Message Sent!");
    }
  }

  UserModel data = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (emojiShowing != false) {
          setState(() {
            emojiShowing = !emojiShowing;
          });
        }
      },
      child: WillPopScope(
        //if emojis are shown & back button is pressed then hide emojis
        //or else simple close current screen on back button click
        onWillPop: () {
          if (emojiShowing) {
            setState(() => emojiShowing = !emojiShowing);
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF1F1F1),
          appBar: appbar(),
          body: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                )),
            height: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("chatrooms")
                          .doc(widget.chatroom.chatroomid)
                          .collection("messages")
                          .orderBy("createdon", descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            QuerySnapshot dataSnapshot =
                                snapshot.data as QuerySnapshot;

                            return dataSnapshot.docs.isEmpty
                                ? const Center(
                                    child: Text(
                                      "Say hi 👋 ",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 25),
                                    ),
                                  )
                                : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    reverse: true,
                                    shrinkWrap: true,
                                    itemCount: dataSnapshot.docs.length,
                                    itemBuilder: (context, index) {
                                      MessageModel currentMessage =
                                          MessageModel.fromMap(
                                              dataSnapshot.docs[index].data()
                                                  as Map<String, dynamic>);
                                      var Date = DateTime.parse(
                                          currentMessage.createdon.toString());

                                      // 12 Hour format:
                                      var date = DateFormat('hh:mm a')
                                          .format(Date); // 12/31/2000, 10:00 PM

                                      return Row(
                                        mainAxisAlignment:
                                            (currentMessage.sender ==
                                                    widget.userModel.uid)
                                                ? MainAxisAlignment.end
                                                : MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  (currentMessage.sender ==
                                                          widget.userModel.uid)
                                                      ? CrossAxisAlignment.end
                                                      : CrossAxisAlignment
                                                          .start,
                                              children: [
                                                Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                      minWidth: 70,
                                                      maxWidth: 200,
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 15,
                                                      horizontal: 15,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      gradient: (currentMessage
                                                                  .sender ==
                                                              widget.userModel
                                                                  .uid)
                                                          ? const LinearGradient(
                                                              colors: [
                                                                Color.fromARGB(
                                                                    255,
                                                                    114,
                                                                    102,
                                                                    221),
                                                                Color(
                                                                    0xff39D2C0),
                                                              ],
                                                              stops: [0, 1],
                                                              begin:
                                                                  AlignmentDirectional(
                                                                      -1, 1),
                                                              end:
                                                                  AlignmentDirectional(
                                                                      1, -1),
                                                            )
                                                          : null,
                                                      // borderRadius: BorderRadius.only(),
                                                      color: (currentMessage
                                                                  .sender !=
                                                              widget.userModel
                                                                  .uid)
                                                          ? Colors.grey.shade200
                                                          : null,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        bottomLeft: (currentMessage
                                                                    .sender ==
                                                                widget.userModel
                                                                    .uid)
                                                            ? const Radius
                                                                .circular(25)
                                                            : const Radius
                                                                .circular(0),
                                                        topLeft: const Radius
                                                            .circular(25),
                                                        topRight: const Radius
                                                            .circular(25),
                                                        bottomRight: (currentMessage
                                                                    .sender !=
                                                                widget.userModel
                                                                    .uid)
                                                            ? const Radius
                                                                .circular(25)
                                                            : const Radius
                                                                .circular(0),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      currentMessage.text
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        letterSpacing: 0.8,
                                                        color: (currentMessage
                                                                    .sender !=
                                                                widget.userModel
                                                                    .uid)
                                                            ? Colors.black
                                                            : Colors.white,
                                                      ),
                                                    )),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      date,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black38,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 7,
                                                    ),
                                                    (currentMessage.sender ==
                                                            widget
                                                                .userModel.uid)
                                                        ? const Icon(
                                                            Icons
                                                                .done_all_rounded,
                                                            color: Colors.blue,
                                                            size: 18,
                                                          )
                                                        : const SizedBox(),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                          } else {
                            return const Center(
                              child: Text(
                                "An error occured! Please check your internet connection.",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black),
                              ),
                            );
                          }
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 20, top: 8, right: 11, left: 11),
                  child: Container(
                    // height: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.shade200),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  // color: Colors.amber,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xff4B39EF),
                                      Color(0xff39D2C0),
                                    ],
                                    stops: [0, 1],
                                    begin: AlignmentDirectional(1, -1),
                                    end: AlignmentDirectional(-1, 1),
                                  ),
                                  borderRadius: BorderRadius.circular(15)),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                              )),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              cursorColor: Colors.grey,
                              maxLines: null,
                              style: const TextStyle(fontSize: 18),
                              onTap: () {
                                if (emojiShowing != false) {
                                  setState(() {
                                    emojiShowing = !emojiShowing;
                                  });
                                }
                              },
                              onSubmitted: (value) {
                                print(value);

                                sendMessage();
                              },
                              textInputAction: TextInputAction.send,
                              decoration: const InputDecoration(
                                // contentPadding: const EdgeInsets.all(10),
                                fillColor: Color(0xFFF2F3F2),
                                // filled: true,
                                // border: OutlineInputBorder(
                                //     borderRadius: BorderRadius.circular(15),
                                //     borderSide: BorderSide.none),
                                border: InputBorder.none,
                                hintText: 'Type a message',
                                hintStyle: TextStyle(
                                    color: Color(0xFF7C7C7C), fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          IconButton(
                              onPressed: () async {
                                // setState(() {

                                // });

                                if (!emojiShowing) {
                                  FocusScope.of(context).unfocus();
                                  await Future.delayed(
                                      const Duration(milliseconds: 20));
                                }

                                setState(() {
                                  emojiShowing = !emojiShowing;
                                });
                              },
                              icon: Icon(
                                Icons.emoji_emotions_outlined,
                                size: 30,
                                color: Colors.grey.shade500,
                              )),
                          const SizedBox(
                            width: 8,
                          ),
                          InkWell(
                            onTap: () {
                              sendMessage();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              // height: 25,
                              // width: 25,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade200),
                              child: Icon(
                                Icons.send,
                                size: 26,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Offstage(
                  offstage: !emojiShowing,
                  child: SizedBox(
                    height: 250,
                    child: EmojiPicker(
                        onEmojiSelected: (Category category, Emoji emoji) {
                          _onEmojiSelected(emoji);
                        },
                        onBackspacePressed: _onBackspacePressed,
                        config: Config(
                            columns: 7,
                            // Issue: https://github.com/flutter/flutter/issues/28894
                            emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                            verticalSpacing: 0,
                            horizontalSpacing: 0,
                            gridPadding: EdgeInsets.zero,
                            initCategory: Category.RECENT,
                            bgColor: const Color(0xFFF2F2F2),
                            indicatorColor: Colors.blue,
                            iconColor: Colors.grey,
                            iconColorSelected: Colors.blue,
                            progressIndicatorColor: Colors.blue,
                            backspaceColor: Colors.blue,
                            skinToneDialogBgColor: Colors.white,
                            skinToneIndicatorColor: Colors.grey,
                            enableSkinTones: true,
                            showRecentsTab: true,
                            recentsLimit: 28,
                            replaceEmojiOnLimitExceed: false,
                            noRecents: const Text(
                              'No Recents',
                              style: TextStyle(
                                  fontSize: 20, color: Colors.black26),
                              textAlign: TextAlign.center,
                            ),
                            tabIndicatorAnimDuration: kTabScrollDuration,
                            categoryIcons: const CategoryIcons(),
                            buttonMode: ButtonMode.MATERIAL)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar appbar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: 85,
      title: Text(
          // data.fullname.toString(),
          widget.targetUser.fullname.toString(),
          style: const TextStyle(color: Colors.black)),
      leading: InkWell(
        onTap: () async {
          var snapshot =
              await FirebaseFirestore.instance.collection("chatrooms").get();
          List user = [];
          snapshot.docs.forEach((e) {
            if (e['chatroomid'] == _chatRoomModel.chatroomid) {
              print("e::${e['chatroomid']}");
              user.add(e);
            }
          });
          print("Count::${user[0]['unreadmessagecount']}");
          // _chatRoomModel.unreadMessageCount = user[0]['unreadmessagecount'];
          // _chatRoomModel.lastMessageSendBy=FirebaseAuth.instance.currentUser!.uid;

          if (user[0]['lastmessagesendby'] !=
              (FirebaseAuth.instance.currentUser!.uid)) {
            _chatRoomModel.unreadMessageCount = 0;
            FirebaseFirestore.instance
                .collection("chatrooms")
                .doc(_chatRoomModel.chatroomid)
                .set(_chatRoomModel.toMap());
            Get.back();
          } else {
            Get.back();
          }
        },
        child: const Icon(Icons.chevron_left_outlined,
            color: Colors.black, size: 30),
      ),
      actions: [
        IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.error_outline_outlined,
              color: Colors.black,
            )),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}
