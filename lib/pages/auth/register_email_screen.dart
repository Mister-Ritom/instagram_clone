import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconic/iconic.dart';
import 'package:instagram_clone/pages/auth/login_screen.dart';
import 'package:instagram_clone/riverpod/user_notifier.dart';
import 'package:instagram_clone/utils/widgets/util_widgets.dart';

class RegisterEmailScreen extends StatefulWidget {
  const RegisterEmailScreen({super.key});

  @override
  State<RegisterEmailScreen> createState() => _RegisterEmailScreenState();
}

class _RegisterEmailScreenState extends State<RegisterEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  bool _isSubmitting = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 8) {
      return "Must be at least 8 characters long";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Must contain at least one number";
    }
    return null;
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final provider = ProviderScope.containerOf(
        context,
      ).read(userProvider.notifier);
      final success = await provider.createUser(email, password);
      if (!success) {
        return;
      }
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Account created for $email")));
        //Only pop as riverpod would change auth screen to home
        Navigator.pop(context);
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width - 12,
              child: Text(
                "What's your email?",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                "Enter the email on which you can be contacted. No one will see this on your profile.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              validator: _validateEmail,
              decoration: const InputDecoration(
                labelText: "Email",
                fillColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              validator: _validatePassword,
              obscureText: _hidePassword,
              decoration: InputDecoration(
                labelText: "Password",
                fillColor: Colors.transparent,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  },
                  icon: Icon(_hidePassword ? Iconic.eye : Iconic.eye_crossed),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "You may get emails from us for security and login purposes",
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 48,
              child: UtilWidgets.getOutlinedButton(
                _isSubmitting ? null : _createAccount,
                _isSubmitting ? "Creating..." : "Next",
                context,
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                borderColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
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
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
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
      ),
    );
  }
}
