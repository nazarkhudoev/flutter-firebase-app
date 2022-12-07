import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/cupertino.dart';

@immutable //their internal will neve been changed
class AuthUser {
  final String? email;
  final bool isEmailVerified;
  const AuthUser({required this.email, required this.isEmailVerified});

  factory AuthUser.fromFirebase(User user) =>
      AuthUser(email: user.email, isEmailVerified: user.emailVerified);
}
