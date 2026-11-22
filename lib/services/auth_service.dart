import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 로그인한 사용자
  User? get currentUser => _auth.currentUser;

  // 로그인 상태 확인
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 회원가입
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // 로그인
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
