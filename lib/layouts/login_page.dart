import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:piecyk/providers/login_state.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<User?> login(BuildContext context) async {
  try {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    final user = userCredential.user;

    if (user != null) {
      debugPrint("Logged in anonymously as UID: ${user.uid}");
      return user;
    } else {
      final loginState = Provider.of<LoginState>(context, listen: false);
      loginState.user = user!;
      debugPrint("Anonymous login failed: No user returned");
      return null;
    }
  } on FirebaseAuthException catch (e) {
    debugPrint("FirebaseAuthException: ${e.code} - ${e.message}");
    return null;
  } catch (e) {
    debugPrint("Unexpected error during anonymous login: $e");
    return null;
  }
}

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: FScaffold(
        child: Center(
          child: FCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("../../resources/logo.png", width: 300, height: 300),
                const SizedBox(height: 24),
                Text('Welcome Back!', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text('Please log in to continue', textAlign: TextAlign.center),
                const SizedBox(height: 32),
                FButton.icon(onPress: () => login(context)
                , child: Text("Login")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
