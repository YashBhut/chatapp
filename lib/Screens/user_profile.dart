import 'package:chat_app/Screens/sign_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usermodel.dart';

class User_Profile extends StatefulWidget {
  const User_Profile({super.key});

  @override
  State<User_Profile> createState() => _User_ProfileState();
}

class _User_ProfileState extends State<User_Profile> {
  Future<void> logout() async {
    await GoogleSignIn().disconnect();
    FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('isLog');
    Get.offAll(const Sign_In_Screen());
    Get.snackbar('Logout Succesfully', 'Success',
        snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(8));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  UserModel? data;
  var user;

  getUser() async {
    user = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    data = UserModel.fromMap(user.data());

    setState(() {});
    // print('Data of User: ${data?.data()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: data == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: Image.network(
                      data!.profilepic.toString(),
                    ).image,
                    backgroundColor: Colors.grey.shade300,
                    radius: 50,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Name : ${data!.fullname.toString()}',
                    style: const TextStyle(
                      wordSpacing: 0.5,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'email : ${data!.email}',
                    style: const TextStyle(
                      wordSpacing: 0.5,
                      fontSize: 18,
                    ),
                  ),
                ],
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
      // toolbarHeight: 5,
      backgroundColor: Colors.white,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'User Profile',
                    style: TextStyle(color: Colors.black, fontSize: 25),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.black,
                    ),
                    onPressed: logout,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
