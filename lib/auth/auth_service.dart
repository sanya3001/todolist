import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleInitialized = false;

  // Email & Password Login
  Future<User?> loginWithEmail(
      String email,
      String password,
      ) async {
    try {
      final UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<User?> createAccountWithEmail(
      String email,
      String password,
      ) async {
    try {
      final UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Google Login
  Future<User?> loginWithGoogle() async {
    try {
      // Initialize Google Sign-In ek j var
      if (!_googleInitialized) {
        //await _googleSignIn.initialize();
        await _googleSignIn.initialize(
          serverClientId: '96198658949-vbmgeqhsjeirjdhrq0q0ece30j15at61.apps.googleusercontent.com',
        );
        _googleInitialized = true;
      }

      // Start Google sign-in
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Get Google authentication information
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create Firebase credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential result =
      await _firebaseAuth.signInWithCredential(
        credential,
      );

      return result.user;
    } on FirebaseAuthException {
      rethrow;
    } on GoogleSignInException {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}