import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:forui/widgets/button.dart';
import 'package:google_fonts/google_fonts.dart';
import '../animations/text_gradient_animation.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  Future logOut() async {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextGradientAnimation(
          text: 'SUNSEER',
          style: GoogleFonts.robotoCondensed(
            fontSize: 44,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
          duration: const Duration(
            seconds: 3,
          ), // You can adjust the animation duration here
        ),
        FTappable(onPress: logOut, child: Icon(FIcons.logOut)),
      ],
    );
  }
}
