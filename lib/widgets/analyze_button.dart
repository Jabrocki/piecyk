import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AnalyzeButton extends StatelessWidget {
  const AnalyzeButton({super.key});

  void _launchYoutube() async {
    const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _launchYoutube,
      icon: const Icon(Icons.analytics),
      label: const Text('Analyze your installation'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
