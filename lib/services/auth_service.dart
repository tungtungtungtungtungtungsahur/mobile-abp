import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    required String username,
  }) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'ktpVerified': false,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        throw 'An account already exists for that email.';
      }
      throw e.message ?? 'An error occurred during sign up.';
    } catch (e) {
      throw 'An error occurred during sign up.';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided.';
      }
      throw e.message ?? 'An error occurred during sign in.';
    } catch (e) {
      throw 'An error occurred during sign in.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Update KTP verification status
  Future<void> updateKtpVerification(String userId, bool isVerified) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'ktpVerified': isVerified,
        'ktpVerifiedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update KTP verification status';
    }
  }
} 