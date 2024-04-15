import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mission_health/ExerciseProvider.dart';
import 'package:mission_health/homepage.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/date_symbol_data_local.dart'; // 추가
import 'auth_service.dart';
import 'splash_screen.dart';

// 로그인 메인 페이지

// 회원가입 패키지 설치: flutter pub add url_launcher

void main() async {
  initializeDateFormatting('ko_KR', null); // 한국어 로케일 데이터 초기화
  // main 함수에서 async 사용하기 위함(firebase를 구동해야 하기에 비동기 방식 필요)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // firebase 앱 시작
  runApp(
    // 앱 전체에서 상태 관리를 위해 Provider를 설정
    MultiProvider(
      providers: [
        // 상태 변화를 감지하고 상태를 제공하는 Provider
        // 각 클래스의 객체를 생성하여 상태를 초기화(전역적으로 상태 관리 가능)
        // AuthService() 목적: 앱 전체에서 인증 관련 상태 를 관리할 수 있다.
        // ExerciseProvider() 목적 : 앱 전체에서 전역적으로 운동하기 카운트와 당첨 운동을
        // 끊기지 않고 유지하기 위해서
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => ExerciseProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Pretendard'), // 사용할 폰트 패밀리 지정,
      debugShowCheckedModeBanner: false, // 디버그 띠 없애기
      // user가 있다면 홈페이지로 없다면 로그인 페이지로
      home: SplashScreen(), // 스플래시 화면 표시
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 이메일 컨트롤러를 생성
  TextEditingController emailController = TextEditingController();
  // 비밀번호 컨트롤러를 생성
  TextEditingController passwordController = TextEditingController();

  // 개발자 정보 팝업을 표시하는 함수
  void _showDeveloperInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('개발자 정보'),
          content: Column(
            // 위젯이 Column 방향으로 차지하는 공간을 최소화
            mainAxisSize: MainAxisSize.min,
            // 위젯이 row 축의 시작 부분에 정렬
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('의지가 없다면 건강을 지키기 어렵습니다. \n여기에 건강에 유용한 정보들을 가득 담았습니다.'),
              Text('개발자: 이해현'),
              Text('문의: haehyun93@naver.com'),
              Text('버전: 1.0'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Consumer : 상태가 변경될 때 UI를 다시 빌드하는 데 사용('AuthService' 클래스에 접근)
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        final user = authService.currentUser();
        return Scaffold(
          // 스크롤 가능하게 하는 위젯
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height, // 화면의 전체 높이
              // 데코레이션(색상, 배경, 그림자 등)을 정의
              decoration: BoxDecoration(
                // 그라데이션 배경으로 정의
                gradient: LinearGradient(
                  begin: Alignment.topCenter, // 중앙 위에서 시작
                  end: Alignment.bottomCenter, // 중앙 바닥에서 끝
                  colors: [Colors.blue.shade200, Colors.blue.shade500],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // column 기준 중앙 정렬
                  children: [
                    // 앱 제목(삼항연산자 사용)
                    Text(
                      // 사용자 정보가 있으면 행복한 하루 되세요!
                      user == null ? "미션헬스" : "행복한 하루 되세요👋",
                      style: TextStyle(
                        fontFamily: 'Pretendard', // 폰트
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 24), // 여백 추가
                    // Email 입력란
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        // 이메일 컨트롤러 연결
                        controller: emailController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    // Password 입력란
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        // 비밀번호 컨트롤러 연결
                        controller: passwordController,
                        obscureText: true,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    // 로그인 버튼
                    ElevatedButton(
                      onPressed: () {
                        // onPressed에 대한 동작 추가
                        // 로그인
                        authService.signIn(
                          // authService.signIn에 아래 요소를 매개변수로 전달
                          email: emailController.text,
                          password: passwordController.text,
                          onSuccess: () {
                            // 로그인 성공
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("환영합니다! 행복한 하루 되세요😄"),
                            ));

                            // HomePage로 이동
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()),
                            );
                          },
                          onError: (err) {
                            // 에러 발생
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(err),
                            ));
                          },
                        );
                      },
                      child: Text('입장하기'),
                    ),
                    SizedBox(height: 16),
                    // 회원가입
                    TextButton(
                      onPressed: () {
                        launchUrl(Uri.parse(
                            'https://docs.google.com/forms/d/1yvFBzvuMlJVZ6k1OsSxQFoG_iukHILlPYhMAQxSwjKk/edit'));
                      },
                      child: Text(
                        '회원가입',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 16),
                    // 개발자 정보 버튼
                    ElevatedButton(
                      onPressed: _showDeveloperInfoDialog, // 함수 호출
                      child: Text(
                        '개발자 정보',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
