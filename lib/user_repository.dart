import 'package:flutter/foundation.dart';

class UserRepository extends ChangeNotifier {
  String _userName = '';
  String _userEmail = '';
  String _avatarPath = '';
  bool _darkMode = false;

  UserRepository._private();
  static final UserRepository instance = UserRepository._private();

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get avatarPath => _avatarPath;
  bool get darkMode => _darkMode;

  void setUser({required String userName, required String userEmail}) {
    _userName = userName;
    _userEmail = userEmail;
    notifyListeners();
  }

  void updateProfile({String? userName, String? userEmail}) {
    if (userName != null) _userName = userName;
    if (userEmail != null) _userEmail = userEmail;
    notifyListeners();
  }

  void setAvatar(String path) {
    _avatarPath = path;
    notifyListeners();
  }

  void toggleDarkMode() {
    _darkMode = !_darkMode;
    notifyListeners();
  }

  void clear() {
    _userName = '';
    _userEmail = '';
    notifyListeners();
  }
}
