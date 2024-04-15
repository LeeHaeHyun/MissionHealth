import 'package:flutter/material.dart';
import 'package:mission_health/auth_service.dart';
import 'package:mission_health/main.dart';

import 'calendar_screen.dart';
import 'map_screen.dart';
import 'condition_screen.dart';
import 'disease_screen.dart';

// 로그인 후 메인 페이지

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 현재 선택된 탭의 인덱스를 저장하는 변수(초기화)
  int _selectedIndex = 0;

  // 각 탭에 대응하는 위젯들을 저장하는 리스트
  static final List<Widget> _widgetOptions = <Widget>[
    DiseaseScreen(),
    ConditionScreen(),
    CalendarScreen(),
    MapScreen(),
  ];

// bottom 네비게이션 바에서 아이템이 탭될 때 호출되는 콜백 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService(); // AuthService 인스턴스 생성

    return Scaffold(
      resizeToAvoidBottomInset: false, // overflow 방지
      appBar: AppBar(
        title: Text(
          '미션 헬스',
          style: TextStyle(
            fontFamily: 'Pretendard', // Pretendard 폰트
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 2.0,
                color: Colors.white30,
              ),
            ],
          ),
        ),
        centerTitle: true, // 제목 가운데 정렬
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.black,
            ),
            onPressed: () {
              // 로그아웃 기능 구현
              authService.signOut();
              // 로그인화면으로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
        // 스크롤 가능한 위젯의 배경을 그라디언트로 설정하는 부분
        flexibleSpace: Container(
          decoration: BoxDecoration(
            // 그라디언트 효과를 설정하는 속성
            gradient: LinearGradient(
              // 그라디언트의 시작 지점
              begin: Alignment.topLeft,
              // 그라디언트의 종료 지점
              end: Alignment.bottomRight,
              colors: [
                Colors.blue[300]!,
                Colors.blue[500]!,
                Colors.blue[700]!,
              ],
            ),
          ),
        ),
        // 스크롤 가능한 위젯의 그림자 효과의 높이
        elevation: 4.0,
      ),
      body: Column(
        children: [
          Container(
            height: 8.0,
            color: Colors.grey[300],
          ),
          // 부모 위젯의 남은 공간을 모두 차지하도록 자식 위젯을 확장시키는 위젯
          Expanded(
            child: Center(
              // _widgetOptions 리스트에서 선택된 인덱스에 해당하는 위젯을 가운데 정렬
              // _widgetOptions 리스트에서 _selectedIndex에 해당하는 요소를 가져옴(중요)
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ),
        ],
      ),
      // 네비게이션바 !
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '질병',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart),
            label: '상태',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '달력',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_sharp),
            label: '위치',
          ),
        ],
        // 현재 선택된 항목의 인덱스를 설정
        currentIndex: _selectedIndex,
        // 선택된 항목의 아이콘 및 텍스트 색상
        selectedItemColor: Colors.blue[800],
        // 선택되지 않은 항목의 아이콘 및 텍스트 색상
        unselectedItemColor: Colors.grey[600],
        // 클릭하면 호출하여 _selectedIndex에 저장
        onTap: _onItemTapped,
      ),
    );
  }
}
