import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:google_fonts/google_fonts.dart';
// Import FTheme
import '../animations/looping_text_gradient_animation.dart';

class TitleWidgetLogo extends StatelessWidget {
  const TitleWidgetLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = FTheme.of(context).colors;

    return 
      Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Center(
          child: LoopingTextGradientAnimation( // Added child:
            text: 'SUNSEER',
            style: GoogleFonts.robotoCondensed(
              fontSize: 100,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              // The color property of TextStyle is used by ShaderMask, but the gradient will override it.
              // We set it to the theme's foreground color as a fallback or if ShaderMask is disabled.
              color: colors.foreground,
            ),
            duration: const Duration(seconds: 3),
            finalGradientColor: colors.foreground, // Simplified to use theme's foreground color
          ),
        ),
    );
  }
}
