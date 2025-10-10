import 'package:flutter/material.dart';
import 'package:instagram_clone/pages/auth/login_screen.dart';
import 'package:instagram_clone/utils/widgets/util_widgets.dart';

class RegisterEmailScreen extends StatelessWidget {
  const RegisterEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 12,
            child: Text(
              "What's your email?",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              "Enter the email on which you can be contacted.No one will see this on your profile.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              label: Text("Email"),
              fillColor: Colors.transparent,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              label: Text("Password"),
              fillColor: Colors.transparent,
            ),
          ),
          SizedBox(height: 16),
          Text("You may get emails from us for security and login purposes"),
          SizedBox(height: 16),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 48,
            child: UtilWidgets.getOutlinedButton(
              () {},
              "Next",
              context,
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              borderColor: Colors.blue,
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 48,
            child: UtilWidgets.getOutlinedButton(
              () {},
              "Sign up with phone",
              context,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: Text(
              "I already have an account",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
