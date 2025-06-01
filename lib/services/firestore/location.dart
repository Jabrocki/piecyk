import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> initOrUpdateLocation(double latitude, double longitude) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception("User not authenticated");
  }

  final userDocRef = FirebaseFirestore.instance.collection('locations').doc(user.uid);

  try {
    await userDocRef.set({
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // Merge to update if it exists
  } catch (e) {
    throw Exception("Failed to initialize or update location: $e");
  }
}

Future<Map<String, dynamic>?> downloadLocationData() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception("User not authenticated");
  }

  final userDocRef = FirebaseFirestore.instance.collection('locations').doc(user.uid);

  try {
    final snapshot = await userDocRef.get();
    if (snapshot.exists) {
      return snapshot.data(); // Return the document data
    } else {
      return null; // Document does not exist
    }
  } catch (e) {
    throw Exception("Failed to download location data: $e");
  }
}
