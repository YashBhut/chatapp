import 'package:chat_app/Screens/main_screen.dart';
import 'package:chat_app/Screens/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usermodel.dart';

class Sign_In_Screen extends StatefulWidget {
  const Sign_In_Screen({super.key});

  @override
  State<Sign_In_Screen> createState() => _Sign_In_ScreenState();
}

class _Sign_In_ScreenState extends State<Sign_In_Screen> {
  String? tokenId ;
 @override
  void initState()  {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance; // Change here
    _firebaseMessaging.getToken().then((token){
      print("token is $token");
   tokenId =token;

  });
}
  bool isLod = false;
  googleLogin() async {
    setState(() {
      isLod = true;
    });
    print("googleLogin method Called");
    GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      var reslut = await _googleSignIn.signIn();
      if (reslut == null) {
        setState(() {
          isLod = false;
        });
        return;
      } else {
        final userData = await reslut.authentication;
        final credential = GoogleAuthProvider.credential(
            accessToken: userData.accessToken, idToken: userData.idToken);
        var finalResult =
            await FirebaseAuth.instance.signInWithCredential(credential);

        // String uid = finalResult.user!.uid;
        String uids = FirebaseAuth.instance.currentUser!.uid;
        UserModel newUser = UserModel(
            uid: uids,
            email: reslut.email,
            fullname: reslut.displayName,
            profilepic: reslut.photoUrl,
            pushToken: tokenId
            );

        await FirebaseFirestore.instance
            .collection("users")
            .doc(uids)
            .set(newUser.toMap())
            .then((value) async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLog', true);
          Get.offAll(Main_Screen());
          setState(() {
            isLod = false;
          });
          Get.snackbar('Login Succesfully', 'Success',
              snackPosition: SnackPosition.BOTTOM, margin: EdgeInsets.all(8));
          print("Result $reslut");
          print(reslut.displayName);
          print(reslut.email);
          print(reslut.photoUrl);
        });
      }
    } catch (error) {
      setState(() {
        isLod = false;
      });
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:tokenId==''?CircularProgressIndicator(): isLod == true
            ? CircularProgressIndicator()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                      onPressed: () {
                        googleLogin();
                      },
                      // icon: const FaIcon(FontAwesomeIcons.google),
                      icon: Image.asset(
                        'assets/images/googlelogo.png',
                        scale: 35,
                      ),
                      style: ButtonStyle(
                          elevation: MaterialStatePropertyAll<double>(0.0),
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              Colors.grey.shade300),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ))),
                      // style: ElevatedButton.styleFrom(primary: Colors.white38,shape: CircleBorder(side: BorderSide(style: ))),
                      label: const Text(
                        'Google Login',
                        style: TextStyle(color: Colors.black),
                      ))
                  // ElevatedButton(
                  //     child: const Text('Google Login'), onPressed: googleLogin),
                ],
              ),
      ),
    );
  }
}
