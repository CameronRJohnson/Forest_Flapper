import 'package:firebase_auth/firebase_auth.dart';
import '../models/player.dart';
import 'database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Convert Firebase User to Player model
  Player? _userFromFirebaseUser(User? user) {
    return user != null ? Player(uid: user.uid) : null;
  }

  // Auth change user stream
  Stream<Player?> get player {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Sign in anonymously
  Future<Player?> signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  // Sign in with email and password
  Future<Player?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  // Send password reset email
  Future<bool> changePassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true; // Email sent successfully
    } catch (e) {
      return false; // Error occurred
    }
  }

  // Register with email and password
  Future<Player?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // Create a new document for the user with the uid
      await DatabaseService(uid: user!.uid).updateUserData('A New Player', 0);

      return _userFromFirebaseUser(user);
    } catch (e) {
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return;
    }
  }
}
