import 'package:flutter/cupertino.dart';


class SelectedUser with ChangeNotifier {
  Set<String> _selected = {};
  Map<String, String> _selectedName = {};

  void addSelection({String email, String name}) {
    _selected.add(email);
    _selectedName[email] = name;
    notifyListeners();
  }

  bool isAlreadySelected({String email}) {
    return _selected.contains(email);
  }

  List<String> getList() {
    List<String> list = [];
    _selected.forEach((element) {list.add(element);});
    return list;
  }

  List<Map<String, String>> getNameList(){
    List<Map<String, String>> list = [];
    _selectedName.forEach((key, value) {list.add({key : value});});
    return list;
  }

  void deSelect({String email}){
    _selected.remove(email);
    _selectedName.remove(email);
    notifyListeners();
  }

  void clear() {
    _selected.clear();
    _selectedName.clear();
    notifyListeners();
  }

  bool get isEmpty{
    return _selected.isEmpty;
  }
}
