import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/user_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _currentStep = 0;

  final TextEditingController _nameController =
      TextEditingController();
  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_updateState);
    _emailController.addListener(_updateState);
    _passwordController.addListener(_updateState);
    _confirmPasswordController.addListener(_updateState);
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _isFirstStepValid {
    return _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty;
  }

  bool get _isSecondStepValid {
    return _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text ==
            _confirmPasswordController.text;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    super.dispose();
  }

  
  Future<void> _goToNextStep() async {
    if (_currentStep == 0) {
      FocusScope.of(context).unfocus();

      setState(() {
        _currentStep = 1;
      });
      return;
    }

    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Firebase Authentication 계정 생성
      final credential = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 2. 생성된 사용자 UID 확인
      final user = credential.user;

      if (user == null) {
        throw Exception('사용자 정보를 가져오지 못했습니다.');
      }

      // 3. Firestore에 사용자 정보 저장
      await _userService.createUser(
        uid: user.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      // 4. 로그인 화면으로 이동
      if (!mounted) return;

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = '이미 사용 중인 이메일입니다.';
          break;
        case 'invalid-email':
          message = '올바른 이메일 형식이 아닙니다.';
          break;
        case 'weak-password':
          message = '비밀번호가 너무 간단합니다.';
          break;
        case 'network-request-failed':
          message = '네트워크 연결을 확인해주세요.';
          break;
        default:
          message = '회원가입에 실패했습니다. 다시 시도해주세요.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

    } catch (e, stackTrace) {
      debugPrint('회원가입 오류: $e');
      debugPrint('오류 상세: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원가입 처리 중 오류가 발생했습니다.'),
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


  void _goToPreviousStep() {
    FocusScope.of(context).unfocus();

    if (_currentStep == 1) {
      setState(() {
        _currentStep = 0;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double scale =
        MediaQuery.of(context).size.width / 390;

    final bool isButtonEnabled = _currentStep == 0
        ? _isFirstStepValid
        : _isSecondStepValid;

    return Scaffold(
      backgroundColor: AppColors.lockBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 앱바
            SizedBox(
              width: double.infinity,
              height: 56 * scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    '회원가입',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Positioned(
                    left: 21 * scale,
                    child: GestureDetector(
                      onTap: _goToPreviousStep,
                      child: Image.asset(
                        'assets/images/back_arrow.png',
                        width: 22.35 * scale,
                        height: 19.3 * scale,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 화면 내용
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 30 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50 * scale),

                    // 제목
                    Text(
                      _currentStep == 0
                          ? '정보를\n입력해주세요'
                          : '비밀번호를\n만들어주세요',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 27.21 * scale,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 30 * scale),

                    // 첫 번째 단계
                    if (_currentStep == 0) ...[
                      _buildTextField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        hintText: '이름',
                        scale: scale,
                      ),
                      SizedBox(height: 16 * scale),
                      _buildTextField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        hintText: '이메일',
                        scale: scale,
                      ),
                    ],

                    // 두 번째 단계
                    if (_currentStep == 1) ...[
                      _buildTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        hintText: '비밀번호',
                        isPassword: true,
                        isObscured: !_showPassword,
                        onTogglePassword: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                        scale: scale,
                      ),
                      SizedBox(height: 16 * scale),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocus,
                        hintText: '비밀번호 확인',
                        isPassword: true,
                        isObscured: !_showConfirmPassword,
                        onTogglePassword: () {
                          setState(() {
                            _showConfirmPassword =
                                !_showConfirmPassword;
                          });
                        },
                        scale: scale,
                      ),

                      if (_confirmPasswordController.text.isNotEmpty &&
                          _passwordController.text !=
                              _confirmPasswordController.text) ...[
                        SizedBox(height: 7 * scale),
                        Padding(
                          padding: EdgeInsets.only(left: 17 * scale),
                          child: Text(
                            '비밀번호가 일치하지 않습니다.',
                            style: TextStyle(
                              color: const Color(0xFF905B58),
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ],

                    const Spacer(),

                    // 다음 / 확인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 59 * scale,
                      child: ElevatedButton(
                        onPressed: isButtonEnabled && !_isLoading
                            ? _goToNextStep
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
                            ? SizedBox(
                                width: 22 * scale,
                                height: 22 * scale,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.text,
                                ),
                              )
                            : Text(
                                _currentStep == 0 ? '다음' : '확인',
                                style: TextStyle(
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),

                    SizedBox(height: 153 * scale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 로그인 화면과 동일한 입력창 구조
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required double scale,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onTogglePassword,
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
            obscureText: isPassword && isObscured,
            minLines: 1,
            maxLines: 1,
            cursorHeight: 17 * scale,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16 * scale,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: hasLabel ? null : hintText,
              hintStyle: TextStyle(
                color: AppColors.disabled,
                fontSize: 16 * scale,
              ),
              border: InputBorder.none,
            ),
          );
        }

        return Container(
          height: 58 * scale,
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
            horizontal: 17 * scale,
            vertical: hasLabel ? 5 * scale : 0,
          ),
          child: hasLabel
              ? Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      hintText,
                      style: TextStyle(
                        color: AppColors.disabled,
                        fontSize: 12 * scale,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: buildInput(),
                          ),

                          // 비밀번호 표시 / 숨김
                          if (isPassword)
                            Transform.translate(
                              offset: Offset(0, -6 * scale),
                              child: GestureDetector(
                                onTap: onTogglePassword,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: 8 * scale,
                                  ),
                                  child: Icon(
                                    isObscured
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.disabled,
                                    size: 17 * scale,
                                  ),
                                ),
                              ),
                            ),

                          // 입력값 삭제 버튼
                          if (controller.text.isNotEmpty)
                            Transform.translate(
                              offset: Offset(0, -6 * scale),
                              child: GestureDetector(
                                onTap: controller.clear,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 8 * scale,
                                  ),
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.grey,
                                    size: 17 * scale,
                                  ),
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
}
