import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class SelectedUser with ChangeNotifier {
  Set<String> _selectedChat = {};
  Map<String, String> _selectedChatName = {};
  Set<String> _selectedGroup = {};
  Map<String, String> _selectedGroupName = {};

  void addSelectionGroup({String id, String name}) {
    _selectedGroup.add(id);
    _selectedGroupName[id] = name;
    notifyListeners();
  }

  void addSelection({String email, String name}) {
    _selectedChat.add(email);
    _selectedChatName[email] = name;
    notifyListeners();
  }

  bool isAlreadySelectedGroup({String id}) {
    return _selectedGroup.contains(id);
  }

  bool isAlreadySelected({String email}) {
    return _selectedChat.contains(email);
  }

  List<String> getListChat() {
    List<String> list = [];
    _selectedChat.forEach((element) {
      list.add(element);
    });
    return list;
  }

  List<String> getListGroup() {
    List<String> list = [];
    _selectedGroup.forEach((element) {
      list.add(element);
    });
    return list;
  }

  List<Map<String, String>> getNameList() {
    List<Map<String, String>> list = [];
    _selectedChatName.forEach((key, value) {
      list.add({key: value});
    });
    return list;
  }

  Map<String, String> getMapChat() {
    return _selectedChatName;
  }

  Map<String, String> getMapGroup() {
    return _selectedGroupName;
  }

  void deSelectChat({String email}) {
    _selectedChat.remove(email);
    _selectedChatName.remove(email);
    notifyListeners();
  }

  void deSelectGroup({String id}) {
    _selectedGroup.remove(id);
    _selectedGroupName.remove(id);
    notifyListeners();
  }

  Future<void> clearChat() async {
    for (String email in getListChat()) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.email)
          .collection('friends')
          .doc(email)
          .update({'selected': false});
    }
    _selectedChat.clear();
    _selectedChatName.clear();
    notifyListeners();
  }

  Future<void> clearGroup()async {
    for (String id in getListGroup()) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.email)
          .collection('groups')
          .doc(id)
          .update({'selected': false});
    }
    _selectedGroup.clear();
    _selectedGroupName.clear();
    notifyListeners();
  }

  bool get isEmpty {
    return _selectedChat.isEmpty;
  }

  bool get isEmptyGroup {
    return _selectedGroup.isEmpty;
  }

  bool get nothingSelected {
    return _selectedGroup.isEmpty && _selectedChat.isEmpty;
  }
}
