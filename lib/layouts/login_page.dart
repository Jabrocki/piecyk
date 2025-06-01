import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:piecyk/providers/login_state.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        print("Anonymous login failed: No user returned");
        return null;
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      return null;
    } catch (e) {
      print("Unexpected error during anonymous login: $e");
      return null;
    }
  }

  Future<void> logInWithGoogle() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            "373524011059-qeq8pr6pilu3ogm5s01l1d05udcups1o.apps.googleusercontent.com", // Correct clientId
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print("Google Sign-In canceled");
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      print("Google login successful");
    } catch (error) {
      print("Error during Google login: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: FScaffold(
        child: Center(
          child: SizedBox(
            width: 500,
            height: 600,
            child: FCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "../../resources/logo.png",
                    width: 300,
                    height: 300,
                  ),
                  const SizedBox(height: 24),
                  Text('Welcome Back!', 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600
                  ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please log in to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w400
                    ),
                  ),
                  const SizedBox(height: 32),
                  FButton(
                    onPress: () => login(context),
                    child: Text("Login as guest"),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey, thickness: 0.5),
                      ),
                      Text("Or use", style: TextStyle(fontSize: 10, color: Colors.grey),),
                      Expanded(
                        child: Divider(color: Colors.grey, thickness: 0.5),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  FButton(
                    onPress: logInWithGoogle,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "../../resources/google.png", // Replace with the correct path to your asset
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text("Login with Google"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
