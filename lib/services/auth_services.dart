import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      // Log detail untuk debugging
      // ignore: avoid_print
      print('Auth error (signIn) code=${e.code} message=${e.message}');
      throw _handleAuthException(e);
    } on MissingPluginException catch (_) {
      throw 'Autentikasi tidak didukung di platform ini. Jalankan di Android/iOS/Web.';
    } catch (e) {
      throw 'Terjadi kesalahan: ${e.toString()}';
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      // Log detail untuk debugging
      // ignore: avoid_print
      print('Auth error (register) code=${e.code} message=${e.message}');
      throw _handleAuthException(e);
    } on MissingPluginException catch (_) {
      throw 'Autentikasi tidak didukung di platform ini. Jalankan di Android/iOS/Web.';
    } catch (e) {
      throw 'Terjadi kesalahan: ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      await currentUser?.reload();
    } catch (e) {
      throw Exception('Gagal memperbarui nama: ${e.toString()}');
    }
  }

  // Handle auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter)';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah';
      case 'user-disabled':
        return 'Akun dinonaktifkan, hubungi admin.';
      case 'invalid-credential':
        return 'Kredensial tidak valid. Periksa email/password.';
      case 'unauthorized-domain':
        return 'Domain tidak diizinkan. Tambahkan domain ke Firebase → Authentication → Settings → Authorized domains.';
      case 'invalid-api-key':
        return 'API key tidak valid untuk proyek ini.';
      case 'app-not-authorized':
        return 'Aplikasi belum diotorisasi dengan proyek Firebase ini.';
      case 'configuration-not-found':
        return 'Konfigurasi penyedia tidak ditemukan. Aktifkan Email/Password di Firebase Console → Authentication → Sign-in method.';
      case 'internal-error':
        return 'Terjadi kendala di server. Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}
