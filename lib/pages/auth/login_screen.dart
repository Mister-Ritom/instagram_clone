import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/pages/auth/register_email_screen.dart';
import 'package:instagram_clone/riverpod/user_notifier.dart';
import 'package:instagram_clone/utils/reusable/util_vars.dart';
import 'package:instagram_clone/utils/reusable/util_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final email = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      final provider = ProviderScope.containerOf(
        context,
      ).read(userProvider.notifier);
      final success = await provider.login(email, password);
      if (!success) {
        return;
      }
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Logged in with $email")));
        //Only pop as riverpod would change auth screen to home
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            SizedBox(height: 128),
            Image.asset(UtilVars.appIcon, width: 96, height: 96),
            SizedBox(height: 48),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: "Username, email, or mobile number",
                      fillColor: Colors.transparent,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your username or email";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      fillColor: Colors.transparent,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 8 characters";
                      }
                      if (!RegExp(r'\d').hasMatch(value)) {
                        return "Password must contain at least one number";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 48,
                    child: UtilWidgets.getOutlinedButton(
                      _submit,
                      _isSubmitting ? "Loggin in,,," : "Log in",
                      context,
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      borderColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            TextButton(onPressed: () {}, child: Text("Forgotten password?")),
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
    );
  }
}
