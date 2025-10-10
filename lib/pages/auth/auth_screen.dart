import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iconic/iconic.dart';
import 'package:instagram_clone/pages/auth/login_screen.dart';
import 'package:instagram_clone/pages/auth/register_email_screen.dart';
import 'package:instagram_clone/utils/widgets/profile_picture.dart';
import 'package:instagram_clone/utils/widgets/util_vars.dart';
import 'package:instagram_clone/utils/widgets/util_widgets.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text("English (US)"),
              SizedBox(height: 32),
              Image.asset(UtilVars.appIcon, width: 96, height: 96),
              SizedBox(height: 16),
              //A list of saved logins... not implemented yet
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    getLoginItem(
                      "john",
                      "https://images.unsplash.com/photo-1496345875659-11f7dd282d1d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTZ8fHJhbmRvbSUyMHBlcnNvbnxlbnwwfHwwfHx8MA%3D%3D",
                      context,
                    ),
                    getLoginItem(
                      "michael",
                      "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8cmFuZG9tJTIwcGVyc29ufGVufDB8fDB8fHww",
                      context,
                    ),
                    getLoginItem("ritomg1", null, context),
                  ],
                ),
              ),
              SizedBox(height: 8),
              UtilWidgets.getOutlinedButton(
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                "Use another profile",
                context,
              ),

              const Spacer(),

              UtilWidgets.getOutlinedButton(
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RegisterEmailScreen(),
                    ),
                  );
                },
                "Create new account",
                context,
                foregroundColor: Colors.blue,
                borderColor: Colors.blue,
              ),

              SizedBox(height: 8),
              Text(
                UtilVars.copyright,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getLoginItem(String username, String? img, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          //Divider color from main theme
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: () {},
        leading: SizedBox(
          width: 42,
          height: 42,
          child: ProfilePicture(img: img),
        ),
        title: Text(username),
        subtitle: Row(
          children: [
            Container(
              width: 4,
              height: 4,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(100)),
              ),
            ),
            Text("${Random().nextInt(999)} notifications"),
          ],
        ),
        trailing: Icon(Iconic.angle_small_right_straight),
      ),
    );
  }
}
