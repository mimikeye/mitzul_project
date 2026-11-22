
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'signup_screen.dart';

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

  @override
  void initState() {
    super.initState();

    _idController.addListener(_updateState);
    _passwordController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  bool get _isLoginEnabled {
    return _idController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
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
                  onPressed: _isLoginEnabled
                      ? () {
                          // 추후 Firebase 로그인 연결
                        }
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
                  child: Text(
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
                            builder: (context) => const SignupScreen(),
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
                  onTap: () {
                    // 추후 Google 로그인 연결
                  },
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
            decoration: InputDecoration(
              isCollapsed: true,
              hintText: hasLabel ? null : hintText,
              hintStyle: const TextStyle(
                color: AppColors.disabled,
                fontSize: 17,
              ),
              border: InputBorder.none,
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
