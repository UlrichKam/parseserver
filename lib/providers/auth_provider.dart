import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class Auth with ChangeNotifier {
  ParseUser? _user;

  ParseUser? get user => _user;

  void authenticate(ParseUser user) {
    _user = user;
    notifyListeners();
  }
}