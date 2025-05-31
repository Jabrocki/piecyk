import 'package:flutter/material.dart';
import 'package:forui/forui.dart'; // Import forui

class VerticalButtonList extends StatelessWidget {
  const VerticalButtonList({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Added SingleChildScrollView
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding( // Added Padding
            padding: const EdgeInsets.all(8.0), // Added padding value
            child: FButton( 
              onPress: () {
                // Action for button 1
                print('Button 1 pressed');
              },
              child: const Text('Button 1'),
            ),
          ), // Spacing between buttons
          Padding( // Added Padding
            padding: const EdgeInsets.all(8.0), // Added padding value
            child: FButton(
              onPress: () {
                // Action for button 2
                print('Button 2 pressed');
              },
              child: const Text('Button 2'),
            ),
          ),
          Padding( // Added Padding
            padding: const EdgeInsets.all(8.0), // Added padding value
            child: FButton(
              onPress: () {
                // Action for button 3
                print('Button 3 pressed');
              },
              child: const Text('Button 3'),
            ),
          ),
          // Add more buttons as needed
        ],
      ),
    );
  }
}