import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class SniffSocialFirebaseUser {
  SniffSocialFirebaseUser(this.user);
  User user;
  bool get loggedIn => user != null;
}

SniffSocialFirebaseUser currentUser;
bool get loggedIn => currentUser?.loggedIn ?? false;
Stream<SniffSocialFirebaseUser> sniffSocialFirebaseUserStream() => FirebaseAuth
    .instance
    .authStateChanges()
    .debounce((user) => user == null && !loggedIn
        ? TimerStream(true, const Duration(seconds: 1))
        : Stream.value(user))
    .map<SniffSocialFirebaseUser>(
        (user) => currentUser = SniffSocialFirebaseUser(user));
