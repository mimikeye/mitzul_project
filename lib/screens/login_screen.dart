import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import '../services/google_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final FocusNode _idFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _rememberId = false;
  bool _autoLogin = false;
  final bool _obscurePassword = true;

  bool _isLoading = false;

  final AuthService _authService = AuthService();

  final GoogleAuthService _googleAuthService =
    GoogleAuthService();

  @override
  void initState() {
    super.initState();

    _idController.addListener(_updateState);
    _passwordController.addListener(_updateState);

    _loadSavedEmail();
  }

  // 저장된 이메일 불러오기
  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();

    final savedEmail = prefs.getString('savedEmail');
    final rememberId = prefs.getBool('rememberId') ?? false;

    if (!mounted) return;

    setState(() {
      _rememberId = rememberId;

      if (_rememberId && savedEmail != null) {
        _idController.text = savedEmail;
      }
    });
  }

  // 이메일 저장 설정
  Future<void> _saveEmailPreference() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('rememberId', _rememberId);

    if (_rememberId) {
      await prefs.setString(
        'savedEmail',
        _idController.text.trim(),
      );
    } else {
      await prefs.remove('savedEmail');
    }
  }

  Future<void> _saveAutoLoginPreference() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('autoLogin', _autoLogin);
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _isLoginEnabled {
    return _idController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  // Firebase 로그인
  Future<void> _login() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      // 이메일 저장
      await _saveEmailPreference();
      await _saveAutoLoginPreference();

      // Firebase 로그인
      await _authService.signIn(
        email: _idController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'user-not-found':
        case 'invalid-credential':
          message = '이메일 또는 비밀번호를 확인해주세요.';
          break;

        case 'wrong-password':
          message = '비밀번호가 올바르지 않습니다.';
          break;

        case 'invalid-email':
          message = '올바른 이메일 형식이 아닙니다.';
          break;

        case 'too-many-requests':
          message = '잠시 후 다시 시도해주세요.';
          break;

        case 'network-request-failed':
          message = '네트워크 연결을 확인해주세요.';
          break;

        default:
          message = '로그인에 실패했습니다. 다시 시도해주세요.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

    } catch (e) {
      debugPrint('로그인 오류: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인 중 오류가 발생했습니다.'),
        ),
      );

    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Google 로그인
  Future<void> _googleLogin() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential =
          await _googleAuthService.signInWithGoogle();

      final user = userCredential.user;

      if (user == null) {
        throw Exception('Google 사용자 정보를 가져오지 못했습니다.');
      }

      // 자동 로그인 설정 저장
      await _saveAutoLoginPreference();

      // 이메일 저장 설정
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberId', _rememberId);

      if (_rememberId && user.email != null) {
        await prefs.setString('savedEmail', user.email!);
      } else {
        await prefs.remove('savedEmail');
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Google 로그인 Firebase 오류: ${e.code}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google 로그인에 실패했습니다. 다시 시도해주세요.'),
        ),
      );
    } catch (e) {
      debugPrint('Google 로그인 오류: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google 로그인 중 오류가 발생했습니다.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();

    _idFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double scale = constraints.maxWidth / 390;

          return Stack(
            children: [
              // 배경 그라데이션
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.5, 1.0],
                    colors: [
                      AppColors.ivory,
                      AppColors.green,
                    ],
                  ),
                ),
              ),

              // 별 장식
              Positioned(
                left: 177 * scale,
                top: 308 * scale,
                child: Image.asset(
                  'assets/images/title_star.png',
                  width: 214 * scale,
                  height: 522 * scale,
                  fit: BoxFit.contain,
                ),
              ),

              // 로고
              Positioned(
                left: 120 * scale,
                top: 158 * scale,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 162 * scale,
                  fit: BoxFit.contain,
                ),
              ),

              // 이메일 입력창
              Positioned(
                left: 47 * scale,
                top: 304 * scale,
                width: 298 * scale,
                height: 58 * scale,
                child: _buildTextField(
                  controller: _idController,
                  focusNode: _idFocusNode,
                  hintText: '이메일',
                  isPassword: false,
                  scale: scale,
                ),
              ),

              // 비밀번호 입력창
              Positioned(
                left: 47 * scale,
                top: 377 * scale,
                width: 298 * scale,
                height: 58 * scale,
                child: _buildTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  hintText: '비밀번호',
                  isPassword: true,
                  scale: scale,
                ),
              ),

              // 이메일 저장
              Positioned(
                left: 53 * scale,
                top: 451 * scale,
                child: _buildCheckbox(
                  value: _rememberId,
                  label: '이메일 저장',
                  onChanged: (value) {
                    setState(() {
                      _rememberId = value ?? false;
                    });
                  },
                  scale: scale,
                ),
              ),

              // 자동 로그인
              Positioned(
                left: 153 * scale,
                top: 451 * scale,
                child: _buildCheckbox(
                  value: _autoLogin,
                  label: '자동 로그인',
                  onChanged: (value) {
                    setState(() {
                      _autoLogin = value ?? false;
                    });
                  },
                  scale: scale,
                ),
              ),

              // 로그인 버튼
              Positioned(
                left: 47 * scale,
                top: 489 * scale,
                width: 298 * scale,
                height: 59 * scale,
                child: ElevatedButton(
                  onPressed: _isLoginEnabled && !_isLoading
                      ? _login
                      : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.green,
                    disabledBackgroundColor:
                        AppColors.disabled,
                    foregroundColor: AppColors.text,
                    disabledForegroundColor:
                        AppColors.text,
                    shape: const StadiumBorder(),
                    padding: EdgeInsets.zero,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.text,
                          ),
                        )
                      : Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),

              // 회원가입 이동 문구
              Positioned(
                left: 0,
                right: 0,
                top: 568 * scale,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'MITZUL이 처음이신가요?',
                      style: TextStyle(
                        color: AppColors.subText,
                        fontSize: 13 * scale,
                      ),
                    ),

                    SizedBox(width: 10 * scale),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SignupScreen(),
                          ),
                        );
                      },
                      child: Text(
                        '회원가입',
                        style: TextStyle(
                          color: AppColors.subText,
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 또는 구분선
              Positioned(
                left: 76 * scale,
                top: 635 * scale,
                width: 238 * scale,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.subText,
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9 * scale,
                      ),
                      child: Text(
                        '또는',
                        style: TextStyle(
                          color: AppColors.subText,
                          fontSize: 12 * scale,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Container(
                        height: 1,
                        color: AppColors.subText,
                      ),
                    ),
                  ],
                ),
              ),

              // Google 로그인
              Positioned(
                left: 170 * scale,
                top: 670 * scale,
                child: GestureDetector(
                  onTap: _isLoading ? null : _googleLogin,
                  child: Image.asset(
                    'assets/images/googlelogin.png',
                    width: 50 * scale,
                    height: 50 * scale,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 이메일 및 비밀번호 입력창
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required bool isPassword,
    required double scale,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        final bool hasLabel =
            focusNode.hasFocus ||
            controller.text.isNotEmpty;

        final bool isActive =
            focusNode.hasFocus ||
            controller.text.isNotEmpty;

        Widget buildInput() {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText:
                isPassword && _obscurePassword,
            minLines: 1,
            maxLines: 1,
            cursorHeight: 17,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
            ).copyWith(
              hintText: hasLabel ? null : hintText,
              hintStyle: const TextStyle(
                color: AppColors.disabled,
                fontSize: 17,
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.lockBackground,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: isActive
                  ? AppColors.green
                  : AppColors.border,
              width: 2,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 17,
            vertical: hasLabel ? 5 : 0,
          ),
          child: hasLabel
              ? Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      hintText,
                      style: const TextStyle(
                        color: AppColors.disabled,
                        fontSize: 12,
                      ),
                    ),

                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: buildInput(),
                          ),

                          // 이메일 입력값 삭제 버튼
                          if (!isPassword &&
                              controller.text.isNotEmpty)
                            GestureDetector(
                              onTap: controller.clear,
                              child: const Padding(
                                padding: EdgeInsets.only(
                                  left: 8,
                                ),
                                child: Icon(
                                  Icons.cancel,
                                  color: Colors.grey,
                                  size: 19,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                )
              : Center(
                  child: buildInput(),
                ),
        );
      },
    );
  }

  // 체크박스
  Widget _buildCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
    required double scale,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 13.5 * scale,
            height: 13.5 * scale,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.subText,
                width: 1.2,
              ),
              borderRadius: BorderRadius.circular(2),
              color: value
                  ? AppColors.green
                  : Colors.transparent,
            ),
            child: value
                ? Icon(
                    Icons.check,
                    size: 10 * scale,
                    color: Colors.white,
                  )
                : null,
          ),

          SizedBox(width: 6.08 * scale),

          Text(
            label,
            style: TextStyle(
              color: AppColors.subText,
              fontSize: 12 * scale,
            ),
          ),
        ],
      ),
    );
  }
}
