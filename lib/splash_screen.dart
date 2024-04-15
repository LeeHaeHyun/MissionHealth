import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mission_health/auth_service.dart';
import 'package:mission_health/homepage.dart';
import 'package:mission_health/main.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3초 후에 사용자의 로그인 상태를 확인하고 다음 화면으로 네비게이트
    Timer(Duration(seconds: 1), () {
      // AuthService 인스턴스 얻기
      final authService = Provider.of<AuthService>(context, listen: false);
      // 현재 사용자의 로그인 상태 확인
      final user = authService.currentUser();

      // 사용자가 로그인되어 있으면 홈 페이지로 이동
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } else {
        // 사용자가 로그인되어 있지 않으면 로그인 페이지로 이동
        // 여기에 LoginPage()로 이동하는 코드를 추가하면 됩니다.
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // 스플래시 이미지 표시
        child: Image.asset('assets/image/background.png'),
      ),
    );
  }
}
