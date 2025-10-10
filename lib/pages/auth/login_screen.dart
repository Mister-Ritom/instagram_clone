import 'package:flutter/material.dart';
import 'package:instagram_clone/pages/auth/register_email_screen.dart';
import 'package:instagram_clone/utils/widgets/util_vars.dart';
import 'package:instagram_clone/utils/widgets/util_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Only used for back button and safe area
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(height: 128),
          Image.asset(UtilVars.appIcon, width: 96, height: 96),
          SizedBox(height: 48),
          TextField(
            decoration: InputDecoration(
              label: Text("Username,email address or mobile number"),
              fillColor: Colors.transparent,
            ),
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              label: Text("Password"),
              fillColor: Colors.transparent,
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 48,
            child: UtilWidgets.getOutlinedButton(
              () {},
              "Log in",
              context,
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              borderColor: Colors.blue,
            ),
          ),
          SizedBox(height: 16),
          TextButton(onPressed: () {}, child: Text("Forgotten password?")),
          const Spacer(),
          UtilWidgets.getOutlinedButton(
            () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => RegisterEmailScreen()),
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
    );
  }
}
