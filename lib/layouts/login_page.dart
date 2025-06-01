import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:piecyk/providers/login_state.dart';
import 'package:piecyk/widgets/title_widget_logo.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:piecyk/providers/theme_provider.dart';
import 'package:piecyk/theme/forui_theme_adapter.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Future<User?> login(BuildContext context) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final user = userCredential.user;

      if (user != null) {
        debugPrint("Logged in anonymously as UID: \${user.uid}");
        return user;
      } else {
        final loginState = Provider.of<LoginState>(context, listen: false);
        loginState.user = user!; // This will cause a null error if user is null.
        print("Anonymous login failed: No user returned");
        return null;
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: \${e.code} - \${e.message}");
      return null;
    } catch (e) {
      print("Unexpected error during anonymous login: \$e");
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
      print("Error during Google login: \$error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final FColors currentFColors = themeProvider.isDarkMode
        ? darkFColors
        : lightFColors;

    // Get the FStyle from the ambient FTheme.
    // This context needs to have an FTheme ancestor for FTheme.of(context).style to work.
    final FStyle ambientFStyle = FTheme.of(context).style;

    final FThemeData currentFThemeData = FThemeData(
      colors: currentFColors,
      style: ambientFStyle, // Use the style from the ambient theme
    );

    return FTheme(
      data: currentFThemeData,
      child: Builder(builder: (BuildContext context) {
        // FTheme.of(context) here will use currentFThemeData
        final theme = FTheme.of(context);
        final colors = theme.colors;
        // final style = theme.style; // This is ambientFStyle

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
                      TitleWidgetLogo(),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome Back!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.foreground, // Use colors from FTheme
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please log in to continue',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.mutedForeground), // Use colors from FTheme
                      ),
                      const SizedBox(height: 32),
                      FButton(
                        style: FButtonStyle.outline,
                        onPress: () => login(context), // context here is the Builder's context
                        child: Text("Login as guest"),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: colors.border, thickness: 0.5),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text("Or", style: TextStyle(color: colors.mutedForeground)),
                          ),
                          Expanded(
                            child: Divider(color: colors.border, thickness: 0.5),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      FButton(
                        onPress: logInWithGoogle,
                        style: FButtonStyle.outline, // Changed to secondary style
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              "../../resources/google.png",
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            Text("Login with Google"),
                          ],
                        ),
                      ),
                      SizedBox(height: 25),
                      Container(
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.only(bottom: 8), // Add some padding
                        child: IconButton(
                          icon: Icon(
                            themeProvider.isDarkMode
                                ? Icons.dark_mode
                                : Icons.light_mode,
                          ),
                          tooltip: 'Toggle theme',
                          onPressed: () {
                            // themeProvider is captured from the outer scope.
                            themeProvider.toggleTheme();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
