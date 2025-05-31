import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseHandler {
  //Singelton
  static final FirebaseHandler instace = FirebaseHandler._constructor();
  FirebaseHandler._constructor();

  FirebaseFirestore db = FirebaseFirestore.instance;
}
