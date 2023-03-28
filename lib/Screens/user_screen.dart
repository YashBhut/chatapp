import 'package:chat_app/Screens/chat_screen.dart';
import 'package:chat_app/Screens/sign_in_screen.dart';
import 'package:chat_app/models/ChatRoomModel.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

import '../models/FirebaseHelper.dart';
import '../models/notification_services.dart';
import 'sign_in_screen.dart';

class User_Screen extends StatefulWidget {
  // final UserModel userModel;
  // final User firebaseUser;
  // final ChatRoomModel? chatroom;
  // final UserModel? userModel;

  const User_Screen({
    super.key,
    // this.chatroom,
    // this.userModel,
  });

  @override
  State<User_Screen> createState() => _User_ScreenState();
}

class _User_ScreenState extends State<User_Screen> {
  bool isClick = false;
  List<UserModel> datalist = [];
  List<UserModel> searchdata = [];
  TextEditingController search = TextEditingController();
  NotificationServices notificationServices = NotificationServices();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getUser();
    notificationServices.requestNotificationPermission();
    notificationServices.initLocalNotifications();
    // notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value){
      if (kDebugMode) {
        print('device token');
        print(value);
      }
    });
  }

  UserModel? userModel;
  // UserModel? targetModel;
  // var target;
  var user;
  var today = DateFormat.yMMMd().format(DateTime.now());

  getUser() async {
    user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    userModel = UserModel.fromMap(user.data());
    setState(() {});
  }

  // getTargetUser() async {
  //   var snapshot = await FirebaseFirestore.instance.collection("users").get();
  //   List<UserModel> targetlist = [];

  //   snapshot.docs.forEach((e) {
  //     if (e['uid'] != FirebaseAuth.instance.currentUser!.uid) {
  //       // print("e::${e['chatroomid']}");
  //       targetlist.add(e as UserModel);
  //     }
  //   });
  // }

  ChatRoomModel newMessage = ChatRoomModel(
    lasttime: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: appBar(),
      body: userModel == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(15),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .orderBy("lasttime", descending: true)
                      // .where(
                      //     "participants.${FirebaseAuth.instance.currentUser!.uid}",
                      //     isEqualTo: true)

                      // .orderBy(Timestamp.now().toDate().toString(),
                      //     descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      QuerySnapshot chatRoomSnapshot =
                          snapshot.data as QuerySnapshot;

                      if (chatRoomSnapshot.docs.length != 0) {
                        print(
                            "data:: ${(snapshot.data!.docs[0]['lasttime']).toDate().toString()}");

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: chatRoomSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                                chatRoomSnapshot.docs[index].data()
                                    as Map<String, dynamic>);
                            var lastdate = chatRoomModel.lasttime;
                            var chattime = DateFormat.jm().format(lastdate!);
                            var chatdate = DateFormat.yMMMd().format(lastdate);
                            var timeDate =
                                chatdate == today ? chattime : chatdate;

                            int unreadMessageCount =
                                chatRoomModel.lastMessageSendBy ==
                                        FirebaseAuth.instance.currentUser!.uid
                                    ? 0
                                    : chatRoomModel.unreadMessageCount ?? 0;
                            Map<String, dynamic> participants =
                                chatRoomModel.participants!;

                            List<String> participantKeys =
                                participants.keys.toList();
                            participantKeys
                                .remove(FirebaseAuth.instance.currentUser!.uid);
                            if (chatRoomModel.lastMessage != "") {
                              return FutureBuilder(
                                future: FirebaseHelper.getUserModelById(
                                    participantKeys[0]),
                                builder: (context, userData) {
                                  if (userData.connectionState ==
                                      ConnectionState.done) {
                                    if ((chatRoomModel.lastMessage.toString() !=
                                        "")) {
                                      UserModel targetUser =
                                          userData.data as UserModel;
                                      // bool uid=  chatRoomModel.participants?.containsKey(FirebaseAuth.instance.currentUser!.uid) as bool;
                                      bool user = (chatRoomModel.participants![
                                              FirebaseAuth
                                                  .instance.currentUser!.uid
                                                  .toString()] ==
                                          true);
                                      return user == false
                                          ? SizedBox()
                                          : ListTile(
                                              onTap: () async {
                                                getUser();
                                                setState(() {});
                                                Get.to(
                                                        Chat_Screen(
                                                            targetUser:
                                                                targetUser,
                                                            chatroom:
                                                                chatRoomModel,
                                                            userModel: userModel
                                                                as UserModel,
                                                            firebaseUser:
                                                                FirebaseAuth
                                                                        .instance
                                                                        .currentUser
                                                                    as User),
                                                        arguments: userModel
                                                            as UserModel)
                                                    ?.then((value) async {
                                                  var snapshot =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              "chatrooms")
                                                          .get();
                                                  List user = [];
                                                  snapshot.docs.forEach((e) {
                                                    if (e['chatroomid'] ==
                                                        chatRoomModel
                                                            .chatroomid) {
                                                      print(
                                                          "e::${e['chatroomid']}");
                                                      user.add(e);
                                                    }
                                                  });
                                                  if (user[0][
                                                          'lastmessagesendby'] !=
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid) {
                                                    chatRoomModel
                                                        .unreadMessageCount = 0;
                                                    FirebaseFirestore.instance
                                                        .collection("chatrooms")
                                                        .doc(chatRoomModel
                                                            .chatroomid)
                                                        .set(chatRoomModel
                                                            .toMap());
                                                    setState(() {});
                                                  }
                                                });
                                              },
                                              leading: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    targetUser.profilepic
                                                        .toString()),
                                                radius: 30,
                                                backgroundColor:
                                                    Colors.grey.shade300,
                                              ),
                                              title: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 6),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      targetUser.fullname
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                    Text(
                                                      timeDate.toString(),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              subtitle: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    chatRoomModel.lastMessage
                                                        .toString(),
                                                    // chatRoomModel.lastMessageS.toString(),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        letterSpacing: 0.7,
                                                        color: Colors.grey),
                                                  ),
                                                  unreadMessageCount == 0
                                                      ? SizedBox()
                                                      : Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 2,
                                                                  top: 2,
                                                                  left: 8,
                                                                  right: 8),
                                                          decoration:
                                                              const BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
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
                                                                      -1, -1),
                                                              end:
                                                                  AlignmentDirectional(
                                                                      -1, 1),
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  5),
                                                            ),
                                                          ),
                                                          margin:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 1),
                                                          child: Text(
                                                            '$unreadMessageCount',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ))
                                                ],
                                              ));
                                    } else {
                                      return Container();
                                    }
                                  } else {
                                    return Container();
                                  }
                                },
                              );
                            }
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(snapshot.error.toString()),
                        );
                      } else {
                        return
                            //  SizedBox();
                            const Center(
                          child: Text("No Chats"),
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
    );
  }

  AppBar appBar() {
    return AppBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25.0),
          bottomRight: Radius.circular(25.0),
        ),
      ),
      elevation: 0,
      toolbarHeight: 125,
      backgroundColor: Colors.white,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Messages',
                    style: TextStyle(color: Colors.black, fontSize: 25),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(
                height: 50,
                child: TextField(
                  controller: search,
                  onChanged: (value) {
                    searchField(value.toString());
                    setState(() {});
                  },
                  onTap: () {
                    setState(() {
                      isClick = true;
                    });
                  },
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    fillColor: const Color(0xFFF2F3F2),
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                    hintText: 'Search By Names',
                    hintStyle:
                        const TextStyle(color: Color(0xFF7C7C7C), fontSize: 18),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(15),
                      width: 18,
                      child: const Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void searchField(String value) {
    if (value.isEmpty) {
      datalist = searchdata;
      setState(() {});
    } else {
      datalist = searchdata
          .where((element) => element.fullname
              .toString()
              .replaceAll(' ', '')
              .toLowerCase()
              .contains(value.replaceAll(' ', '').toLowerCase()))
          .toList();
    }
    setState(() {});
  }
}
