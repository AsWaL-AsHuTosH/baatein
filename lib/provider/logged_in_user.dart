import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoggedInUser{
  String _email;
  String _name;
  
  //Initializing the curren user.
  Future<bool> initUser()async{
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
        if(auth.currentUser != null){
          _email =  auth.currentUser.email;
          _name =  await firestore
              .collection('users')
              .doc(auth.currentUser.email)
              .get()
              .then((value) => value.data()['name']);
              return true;
        }
        return false;
  }

  //Name getter
  String get name => _name;

  //Email getter
  String get email => _email;

  void clear(){
    _name = null;
    _email = null;
  }

}