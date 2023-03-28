import 'package:chat_app/Screens/all_user_screen.dart';
import 'package:chat_app/Screens/user_screen.dart';
import 'package:chat_app/Screens/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class Main_Screen extends StatefulWidget {
  const Main_Screen({super.key});

  @override
  State<Main_Screen> createState() => _Main_ScreenState();
}

class _Main_ScreenState extends State<Main_Screen> {
  int _currentIndex = 0;
  LinearGradient linearGradient = const LinearGradient(
    colors: [
      Color(0xff39D2C0),
      Color(0xff4B39EF),
    ],
    stops: [0, 1],
    begin: AlignmentDirectional(1, -1),
    end: AlignmentDirectional(-1, 1),
  );

  // final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: linearGradient,
          ),
          height: 70,
          width: 70,
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: () {
              Get.to(All_User_Screen(),);
              setState(() {
                
              _currentIndex=0;
              });
            },
            child: const Icon(Icons.message),
          )),
      body: _currentIndex == 0 ? User_Screen() : User_Profile(),
      bottomNavigationBar: bottombar(),
    );
  }

  Widget bottombar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ),
      child: SizedBox(
        height: 70,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          // fixedColo  r: Colors.grey,
          // unselectedIconTheme: const IconThemeData(color: Colors.grey),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Color(0xFF53B175),
          backgroundColor: Colors.white,
          // selectedItemColor: Colors.white,
          // unselectedItemColor: Colors.white.withOpacity(.60),
          // selectedFontSize: 14,
          unselectedFontSize: 14,

          items: [
            BottomNavigationBarItem(
              label: 'Favorites',
              icon: Icon(
                Icons.home_outlined,
                size: 30,
                color: _currentIndex == 0 ? Colors.black54 : Colors.grey,
              ),
            ),
            BottomNavigationBarItem(
              label: 'News',
              icon: Icon(
                Icons.person_2_outlined,
                size: 30,
                color: _currentIndex == 1 ? Colors.black54 : Colors.grey,
              ),
            ),
          ],
          onTap: (index) {
            _currentIndex = index;
            setState(() {});
          },
        ),
      ),
    );
  }
}
