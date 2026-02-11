import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

/// Repository for authentication operations
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Send OTP to phone number
  Future<Either<Failure, String>> sendOtp({
    required String phoneNumber,
    required Function(String, int?) codeSent,
    required Function(FirebaseAuthException) verificationFailed,
  }) async {
    try {
      String verificationId = '';

      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification on Android
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          verificationFailed(e);
        },
        codeSent: (String verId, int? resendToken) {
          verificationId = verId;
          codeSent(verId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
        timeout: const Duration(seconds: 60),
      );

      return Right(verificationId);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure.fromCode(e.code));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  /// Verify OTP and sign in
  Future<Either<Failure, UserCredential>> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure.fromCode(e.code));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  /// Sign in with email and password
  Future<Either<Failure, UserCredential>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure.fromCode(e.code));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  /// Register with email and password
  Future<Either<Failure, UserCredential>> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure.fromCode(e.code));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  /// Create or update user profile in Firestore
  Future<Either<Failure, UserModel>> createUserProfile({
    required String userId,
    required String name,
    required String phoneNumber,
    String? email,
    String? photoUrl,
  }) async {
    try {
      final now = DateTime.now();
      final userDoc = _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId);

      final existingDoc = await userDoc.get();

      final user = UserModel(
        id: userId,
        name: name,
        phoneNumber: phoneNumber,
        email: email,
        photoUrl: photoUrl,
        createdAt: existingDoc.exists
            ? (existingDoc.data()?['createdAt'] as Timestamp?)?.toDate() ?? now
            : now,
        updatedAt: now,
      );

      await userDoc.set(user.toFirestore(), SetOptions(merge: true));

      return Right(user);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Get user profile from Firestore
  Future<Either<Failure, UserModel?>> getUserProfile(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!docSnapshot.exists) {
        return const Right(null);
      }

      return Right(UserModel.fromFirestore(docSnapshot));
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Update user profile
  Future<Either<Failure, UserModel>> updateUserProfile(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update(updatedUser.toFirestore());

      return Right(updatedUser);
    } on FirebaseException catch (e) {
      return Left(FirestoreFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Sign out
  Future<Either<Failure, void>> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  /// Sign in with Google
  Future<Either<Failure, UserCredential>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return const Left(AuthFailure(message: 'Google sign in cancelled'));
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return Right(userCredential);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure.fromCode(e.code));
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  /// Delete account
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .delete();

        // Delete the auth account
        await user.delete();
      }
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure.fromCode(e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
