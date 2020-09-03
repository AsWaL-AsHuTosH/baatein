import 'package:flutter/cupertino.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class SelectedUser with ChangeNotifier {
  Set<String> selected = {};

  void addSelection({String email, StreamBuilder<QuerySnapshot> data}) {
    selected.add(email);
    notifyListeners();
  }

  bool isAlreadySelected({String email}) {
    return selected.contains(email);
  }

  List<String> getList() {
    List<String> list = [];
    selected.forEach((element) {list.add(element);});
    return list;
  }

  void deSelect({String email}){
    selected.remove(email);
    notifyListeners();
  }

  void clear() {
    selected.clear();
    notifyListeners();
  }

  bool get isEmpty{
    return selected.isEmpty;
  }
}
