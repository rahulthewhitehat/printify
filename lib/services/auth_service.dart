import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      //print('Error signing in: $e');
      rethrow;
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);

      // Check if user exists in Firestore, if not, create new user doc
      final userExists = await _firestore.collection('students').doc(result.user?.uid).get();
      if (!userExists.exists) {
        // navigate to  create account page
      }
      return result.user;
    } catch (e) {
      //print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Create a new user with email and password
  Future<User?> createUserWithEmailAndPassword(
      String email,
      String password,
      Map<String, dynamic> userData,
      ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore in the role-specific collection
      await _createUserInFirestore(result.user, userData);
      return result.user;

    } catch (e) {
      //print('Detailed Error creating user: $e');
      rethrow;
    }
  }

  // Create user document in Firestore in the role-specific collection
  Future<void> _createUserInFirestore(
      User? user,
      Map<String, dynamic> userData,
      ) async {
    if (user != null) {

      // Sanitize user data
      userData = {
        ...userData,
        'isVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'email': user.email,
      };

      // Create document in role-specific members collection
      await _firestore
          .collection('students')
          .doc(user.uid)
          .set(userData);

    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      //print('Error sending verification email: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      //print('Error sending password reset email: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    return await _auth.signOut();
  }

  Future<void> updateUserProfile(
      String uid,
      Map<String, dynamic> userData
      ) async {
    try {
      // Determine the collection based on role
      final userDoc = _firestore.collection('students').doc(uid);

      // Update the user document
      await userDoc.update(userData);

    } catch (e) {
      //print('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<bool> getUserVerificationStatus(String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('students').doc(userId).get();
      if (doc.exists) {
        return doc.get('isVerified') as bool;
      }
      return false; // Default
    } catch (e) {
      print('Error getting user role: $e');
      return false;
    }
  }
}