import 'package:flutter/cupertino.dart';


class SelectedUser with ChangeNotifier {
  Set<String> selected = {};
  Map<String, String> selecteName = {};

  void addSelection({String email, String name}) {
    selected.add(email);
    selecteName[email] = name;
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

  List<Map<String, String>> getNameList(){
    List<Map<String, String>> list = [];
    selecteName.forEach((key, value) {list.add({key : value});});
    return list;
  }

  void deSelect({String email}){
    selected.remove(email);
    selecteName.remove(email);
    notifyListeners();
  }

  void clear() {
    selected.clear();
    selecteName.clear();
    notifyListeners();
  }

  bool get isEmpty{
    return selected.isEmpty;
  }
}
