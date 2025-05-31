import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> addInstallationData({
  required String name,
  required String panelPower,
  required String panelNumber,
  required String maximumVoltage,
  required String tilt,
  required String azimuth,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("User not logged in");

  final uid = user.uid;
  final installationData = {
    'name': name,
    'panelPower': double.tryParse(panelPower) ?? 0.0,
    'panelNumber': int.tryParse(panelNumber) ?? 0,
    'maximumVoltage': double.tryParse(maximumVoltage) ?? 0.0,
    'tilt': double.tryParse(tilt) ?? 0.0,
    'azimuth': double.tryParse(azimuth) ?? 0.0,
    'createdAt': FieldValue.serverTimestamp(),
  };

  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('instaliton')
      .add(installationData);
  
  print('succefully added');
}

Future<List<Map<String, dynamic>>> readInstallationData() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("User not logged in");
  
  final uid = user.uid;
  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('instaliton')
      .get();

  return querySnapshot.docs.map((doc) {
    final data = doc.data();
    data['docId'] = doc.id; // Added
    return data;
  }).toList();
}

Future<void> removeInstallationData(String docId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("User not logged in");
  
  final uid = user.uid;
  await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('instaliton')
      .doc(docId)
      .delete();
}

Stream<List<Map<String, dynamic>>> watchInstallationData() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception("User not logged in");
  }
  final uid = user.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('instaliton')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['docId'] = doc.id;
          return data;
        }).toList();
      });
}
