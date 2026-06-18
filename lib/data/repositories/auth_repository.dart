import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../../core/constants/san_jeronimo_data.dart';

class AuthRepository extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  AuthRepository() {
    if (_auth.currentUser != null) {
      loadUserModel();
    }
  }

  UserModel? get userModel => _userModel;
  User? get currentUser => _auth.currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _auth.currentUser != null;
  String? get error => _error;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  Future<void> loadUserModel() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    _userModel = await _firestoreService.getUser(uid);
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _setError(null);
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await loadUserModel();
      return null;
    } on FirebaseAuthException catch (e) {
      final msg = _authErrorMessage(e.code);
      _setError(msg);
      return msg;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> loginWithGoogle() async {
    _setError(null);
    _setLoading(true);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return 'Inicio de sesión cancelado';
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;
      if (user != null) {
        final existing = await _firestoreService.getUser(user.uid);
        if (existing == null) {
          final newUser = UserModel(
            uid: user.uid,
            displayName: user.displayName ?? 'Usuario',
            email: user.email ?? '',
            photoUrl: user.photoURL ?? '',
            neighborhood: 'Centro',
            zone: 'Zona Centro',
            createdAt: Timestamp.now(),
          );
          await _firestoreService.createUser(newUser);
          _userModel = newUser;
        } else {
          _userModel = existing;
        }
      }
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      final msg = _authErrorMessage(e.code);
      _setError(msg);
      return msg;
    } catch (e) {
      _setError('Error al iniciar sesión con Google');
      return 'Error al iniciar sesión con Google';
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String displayName,
    required String neighborhood,
  }) async {
    _setError(null);
    _setLoading(true);
    try {
      final zone = kNeighborhoodToZone[neighborhood] ?? 'Zona Centro';
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) return 'Error al crear cuenta';

      await user.updateDisplayName(displayName);

      final newUser = UserModel(
        uid: user.uid,
        displayName: displayName,
        email: email,
        neighborhood: neighborhood,
        zone: zone,
        createdAt: Timestamp.now(),
      );
      await _firestoreService.createUser(newUser);
      _userModel = newUser;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      final msg = _authErrorMessage(e.code);
      _setError(msg);
      return msg;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _userModel = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateNeighborhood(String neighborhood) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final zone = kNeighborhoodToZone[neighborhood] ?? 'Zona Centro';
    await _firestoreService.updateUser(uid, {
      'neighborhood': neighborhood,
      'zone': zone,
    });
    _userModel = _userModel?.copyWith(neighborhood: neighborhood, zone: zone);
    notifyListeners();
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo';
      case 'invalid-email':
        return 'El correo no es válido';
      case 'weak-password':
        return 'La contraseña debe tener al menos 8 caracteres';
      case 'network-request-failed':
        return 'Sin conexión a internet';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'invalid-credential':
        return 'Credenciales incorrectas. Verifica tu correo y contraseña';
      default:
        return 'Error de autenticación ($code)';
    }
  }
}
