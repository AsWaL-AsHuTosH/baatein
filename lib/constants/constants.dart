

const String kInvalidUser = "[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.";
const String kWrongPassword = "[firebase_auth/wrong-password] The password is invalid or the user does not have a password.";
const String kEmailInUse = "[firebase_auth/email-already-in-use] The email address is already in use by another account.";

const String kInvalidUserWarning = 'There is no user record corresponding to provided data!';
const String kWrongPasswordWarning = 'Invalid password!';
const String kEmailInUseWarning = 'The email address is already in use by another account!';

const String kNoProfilePic = 'https://firebasestorage.googleapis.com/v0/b/baatein-7d689.appspot.com/o/blank-profile-picture-973460_1280.png?alt=media&token=f031bd7c-4065-4616-bb2c-bb6777d1258a';


String chatIdGenerator(String user1, String user2){
  return user1.compareTo(user2) > 0 ? user1 + '+' + user2 : user2 + '+' + user1;
}