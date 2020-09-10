class LoggedInUser{
  String _email;
  String _name;
  
  //Initializing the curren user.
  Future<void> initUser({String email, String name})async{
    this._email = email;
    this._name = name;
  }

  //Name getter
  String get name => _name;

  //Email getter
  String get email => _email;

}