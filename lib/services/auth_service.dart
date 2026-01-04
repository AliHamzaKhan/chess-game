import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';
import 'firestore_service.dart';

class AuthService extends GetxService with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  
  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<AppUser?> appUser = Rx<AppUser?>(null);

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addObserver(this);
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _handleAuthChanged);
  }

  @override
  void onClose() {
    if (firebaseUser.value != null) {
      _firestoreService.updateOnlineStatus(firebaseUser.value!.uid, false);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (firebaseUser.value != null) {
      if (state == AppLifecycleState.resumed) {
        _firestoreService.updateOnlineStatus(firebaseUser.value!.uid, true);
      } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
        _firestoreService.updateOnlineStatus(firebaseUser.value!.uid, false);
      }
    }
  }

  void _handleAuthChanged(User? user) async {
    if (user != null) {
      AppUser? existingUser = await _firestoreService.getUser(user.uid);
      if (existingUser == null) {
        final newUser = AppUser(
            id: user.uid,
            username: user.isAnonymous 
                ? 'Guest ${user.uid.substring(0, 4)}' 
                : (user.displayName ?? 'Player ${user.uid.substring(0, 4)}'),
            email: user.email ?? '',
            photoUrl: user.photoURL ?? ''
        );
        await _firestoreService.createUser(newUser);
        appUser.value = newUser;
      } else {
        appUser.value = existingUser;
      }
      _firestoreService.updateOnlineStatus(user.uid, true);
      Get.offAllNamed('/home');
    } else {
      appUser.value = null;
      Get.offAllNamed('/login');
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> initGoogleSignIn() async {
    await _googleSignIn.initialize(
      // clientId: clientId, // optional on Android
      // serverClientId: serverClientId, // REQUIRED for Firebase
    );

    _googleSignIn.authenticationEvents.listen(
      _onAuthEvent,
      onError: (value){},
    );

    // Try silent login first
    await _googleSignIn.attemptLightweightAuthentication();
  }

  Future<void> _onAuthEvent(
      GoogleSignInAuthenticationEvent event,
      ) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    if (user == null) return;

    // 🔥 Get tokens for Firebase
    final GoogleSignInAuthentication auth =
    await user.authentication;

    final OAuthCredential credential =
    GoogleAuthProvider.credential(
      idToken: auth.idToken,
      accessToken: auth.idToken,
    );

    // 🔥 Sign in to Firebase
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      Get.snackbar('Google Sign-In Error', e.toString());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }




  Future<void> signInAsGuest() async {
    try {
      final UserCredential cred = await _auth.signInAnonymously();
      // _handleAuthChanged will trigger, but we need to ensure profile creation logic handles it.
      // The current logic in _handleAuthChanged checks Firestore.
      // For anonymous users, we should probably set a default name immediately if it's new.
      // But _handleAuthChanged will do it. 
      // Let's just return here.
    } catch (e) {
      Get.snackbar('Login Error', e.toString());
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
      try {
          await _auth.signInWithEmailAndPassword(email: email, password: password);
      } catch (e) {
          Get.snackbar('Login Error', e.toString());
      }
  }
  
  Future<void> signUpWithEmail(String email, String password, String username) async {
      try {
          UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
          if (cred.user != null) {
             await cred.user!.updateDisplayName(username);
             // _handleAuthChanged will catch this from the stream, but we might need to manually create the user doc here if stream fires too fast? 
             // The stream handler checks DB, it wont find it, so it creates it.
             // But updateDisplayName is async. 
             // We can force create here to be safe.
             final newUser = AppUser(
                id: cred.user!.uid,
                username: username,
                email: email,
                photoUrl: ''
             );
             await _firestoreService.createUser(newUser);
          }
      } catch (e) {
          Get.snackbar('Signup Error', e.toString());
      }
  }

  Future<void> signOut() async {
    if (firebaseUser.value != null) {
      await _firestoreService.updateOnlineStatus(firebaseUser.value!.uid, false);
    }
    await _auth.signOut();
  }
  Future<void> signOutGoogle() async {
    if (firebaseUser.value != null) {
      await _firestoreService.updateOnlineStatus(firebaseUser.value!.uid, false);
    }
    await GoogleSignIn.instance.disconnect();
    await FirebaseAuth.instance.signOut();
  }

}
