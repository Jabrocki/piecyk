import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseHandler {
  //Singelton
  static final FirebaseHandler instace = FirebaseHandler._constructor();
  FirebaseHandler._constructor();

  FirebaseFirestore db = FirebaseFirestore.instance;
}

