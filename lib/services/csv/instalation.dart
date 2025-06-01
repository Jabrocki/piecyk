import 'dart:html' as html;
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> downloadInstallationCSV() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("User not logged in");

  final uid = user.uid;
  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('instaliton')
      .get();

  // Prepare CSV header
  final List<String> header = [
    'Name',
    'Panel Power (kW)',
    'Panel Number',
    'Maximum Voltage (V)',
    'Tilt (degrees)',
    'Azimuth (degrees)',
    'Created At',
  ];

  // Prepare CSV rows
  final List<List<String>> rows = querySnapshot.docs.map((doc) {
    final data = doc.data();
    return [
      (data['name'] ?? '').toString(),
      (data['panelPower'] ?? 0.0).toString(),
      (data['panelNumber'] ?? 0).toString(),
      (data['maximumVoltage'] ?? 0.0).toString(),
      (data['tilt'] ?? 0.0).toString(),
      (data['azimuth'] ?? 0.0).toString(),
      (data['createdAt'] != null)
          ? (data['createdAt'] as Timestamp).toDate().toIso8601String()
          : '',
    ];
  }).toList();

  // Generate CSV content
  final StringBuffer csvContent = StringBuffer();
  csvContent.writeln(header.join(',')); // Add header
  for (final row in rows) {
    csvContent.writeln(row.join(',')); // Add rows
  }

  // Convert CSV content to Uint8List
  final csvBytes = Uint8List.fromList(csvContent.toString().codeUnits);

  // Create a Blob and download the file using dart:html
  final blob = html.Blob([csvBytes]); // Ensure the correct Blob class is used
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..target = '_self' // Ensure the download happens in the same tab
    ..download = 'installation_data.csv';
  anchor.click();
  html.Url.revokeObjectUrl(url);
}
