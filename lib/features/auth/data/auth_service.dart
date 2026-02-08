import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Đăng ký bằng Email + Password
  Future<User?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    String role = 'user', // Thêm tham số role, mặc định là 'user'
  }) async {
    try {
      // Validate
      if (email.trim().isEmpty || password.isEmpty) {
        throw FirebaseAuthException(
            code: 'invalid-input', message: 'Email hoặc mật khẩu rỗng');
      }
      if (password.length < 6) {
        throw FirebaseAuthException(
            code: 'weak-password', message: 'Mật khẩu quá yếu');
      }

      if (kDebugMode) {
        print('SignUp: Creating user with email: $email, role: $role');
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );

      User? user = result.user;

      if (user != null) {
        if (kDebugMode) {
          print('SignUp: User created, saving to Firestore: ${user.uid}');
        }
        // Lưu thông tin user lên Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'role': role, // Lưu role vào Firestore
          'photoUrl': '',
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'fcmToken': '',
        });

        // Cập nhật displayName
        await user.updateDisplayName(name.trim());
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('SignUp Error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    } catch (e) {
      if (kDebugMode) {
        print('SignUp Generic Error: $e');
      }
      throw Exception('Lỗi đăng ký: ${e.toString()}');
    }
  }

  // Đăng nhập Email
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (email.trim().isEmpty || password.isEmpty) {
        throw FirebaseAuthException(
            code: 'invalid-input', message: 'Email hoặc mật khẩu rỗng');
      }

      if (kDebugMode) {
        print('SignIn: Logging in with email: $email');
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      // Cập nhật trạng thái online
      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).update({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }

      return result.user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('SignIn Error: ${e.code} - ${e.message}');
      }
      throw _handleAuthException(e);
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('SignOut Error: $e');
      }
    }
  }

  // Xử lý lỗi
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Mật khẩu quá yếu, phải ít nhất 6 ký tự';
      case 'email-already-in-use':
        return 'Email này đã được dùng để đăng ký';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu sai';
      case 'operation-not-allowed':
        return 'Email/Password chưa được bật trong Firebase Console';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu, vui lòng thử lại sau';
      default:
        return 'Lỗi: ${e.message ?? "Không xác định"}';
    }
  }

  // Đăng nhập bằng Google
  Future<User?> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        print('Google SignIn: Starting...');
      }

      // Sign out trước để force chọn tài khoản
      await _googleSignIn.signOut();

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        if (kDebugMode) {
          print('Google SignIn: User cancelled');
        }
        return null;
      }

      if (kDebugMode) {
        print('Google SignIn: User selected: ${googleUser.email}');
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (kDebugMode) {
        print('Google SignIn: Got authentication tokens');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        if (kDebugMode) {
          print('Google SignIn: Firebase auth successful, uid: ${user.uid}');
        }

        // Check if user document exists in Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Create new user document
          if (kDebugMode) {
            print('Google SignIn: Creating new user document');
          }
          
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName ?? googleUser.displayName ?? 'User',
            'email': user.email ?? googleUser.email,
            'photoUrl': user.photoURL ?? googleUser.photoUrl ?? '',
            'role': 'user',
            'isOnline': true,
            'lastSeen': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
            'fcmToken': '',
            'authProvider': 'google',
          });
        } else {
          // Update existing user
          if (kDebugMode) {
            print('Google SignIn: Updating existing user');
          }
          
          await _firestore.collection('users').doc(user.uid).update({
            'isOnline': true,
            'lastSeen': FieldValue.serverTimestamp(),
            'photoUrl': user.photoURL ?? googleUser.photoUrl ?? userDoc.data()?['photoUrl'] ?? '',
            'name': user.displayName ?? googleUser.displayName ?? userDoc.data()?['name'] ?? 'User',
          });
        }

        if (kDebugMode) {
          print('Google SignIn: Success!');
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Google SignIn FirebaseAuth Error: ${e.code} - ${e.message}');
      }
      throw Exception(_handleAuthException(e));
    } catch (e) {
      if (kDebugMode) {
        print('Google SignIn Error: $e');
      }
      throw Exception('Lỗi đăng nhập Google: ${e.toString()}');
    }
  }

  // Đăng xuất Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      await signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Google SignOut Error: $e');
      }
    }
  }
}
