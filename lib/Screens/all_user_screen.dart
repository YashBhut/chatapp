import 'package:chat_app/Screens/chat_screen.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../main.dart';
import '../models/ChatRoomModel.dart';
import 'sign_in_screen.dart';

class All_User_Screen extends StatefulWidget {
  // final UserModel? userModel;
  // final User? firebaseUser;

  const All_User_Screen({
    super.key,
  });

  @override
  State<All_User_Screen> createState() => _All_User_ScreenState();
}

class _All_User_ScreenState extends State<All_User_Screen> {
  bool isClick = false;
  List<UserModel> datalist = [];
  List<UserModel> searchdata = [];
  TextEditingController search = TextEditingController();

  Future<ChatRoomModel?> getChatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${FirebaseAuth.instance.currentUser!.uid}",
            isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      // Fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;
      print(" Chatroom already Created!");
    } else {
      // Create a new one
      ChatRoomModel newChatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        lasttime: DateTime.now(),
        participants: {
          FirebaseAuth.instance.currentUser!.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;

      print("New Chatroom Created!");
    }

    return chatRoom;
  }

  UserModel? userModel;
  var user;

  getUser() async {
    user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    userModel = UserModel.fromMap(user.data());
    // print('Data of User: ${data?.data()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: appBar(),
      
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          // search.clear();
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          //  -
          //     200 -
          //     AppBar().preferredSize.height,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('fullname', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  List<UserModel> list = [];
                  if (snapshot.hasData) {
                    list = [];
                    final data = snapshot.data?.docs;
                    list =
                        data!.map((e) => UserModel.fromMap(e.data())).toList();
                    print('Data : ${list[0]}');
                    if (isClick == false) {
                      datalist = list;
                      searchdata = list;
                    }
                    return datalist == []
                        ? const Center(
                            child: Text("Data is not available"),
                          )
                        : search.text.trim().isEmpty && datalist.length - 1 == 0
                            ? const Center(
                                child: Text("Data is not available"),
                              )
                            : ListView.builder(
                                // shrinkWrap: true,
                                itemCount: datalist.length,
                                itemBuilder: (context, index) {
                                  return datalist[index].uid ==
                                          FirebaseAuth.instance.currentUser!.uid
                                      ? const SizedBox()
                                      : Padding(
                                          padding: const EdgeInsets.all(7.0),
                                          child: InkWell(
                                            onTap: () async {
                                              getUser();
                                              ChatRoomModel? chatroomModel =
                                                  await getChatroomModel(
                                                      datalist[index]);

                                              if (chatroomModel != null) {
                                                Get.off(
                                                    Chat_Screen(
                                                      chatroom: chatroomModel
                                                          as ChatRoomModel,
                                                      targetUser:
                                                          datalist[index],
                                                      firebaseUser: FirebaseAuth
                                                          .instance
                                                          .currentUser as User,
                                                      userModel: userModel
                                                          as UserModel,
                                                    ),
                                                    arguments: datalist[index]);
                                              }
                                            },
                                            child: Card(
                                              elevation: 0,
                                              color: Colors.transparent,
                                              child: Row(
                                                children: [
                                                  Column(
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundImage:
                                                            Image.network(
                                                          datalist[index]
                                                              .profilepic
                                                              .toString(),
                                                        ).image,
                                                        radius: 30,
                                                        backgroundColor: Colors
                                                            .grey.shade300,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        datalist[index]
                                                            .fullname
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                      const SizedBox(
                                                        height: 8,
                                                      ),
                                                      Text(
                                                        datalist[index]
                                                            .email
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            letterSpacing: 0.7),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                });
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),
        ),
      ),
      // bottomNavigationBar: bottombar(),
    );
  }

  AppBar appBar() {
    return AppBar(
      automaticallyImplyLeading: false,
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
                    'Users',
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
                    hintText: 'Search By Name',
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
              .contains(value..replaceAll(' ', '').toLowerCase()))
          .toList();
    }
    setState(() {});
  }
}
