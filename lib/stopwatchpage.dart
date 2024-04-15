import 'dart:async';

import 'package:flutter/material.dart';

// 스톱워치 페이지

class StopWatchPage extends StatefulWidget {
  const StopWatchPage({super.key});

  @override
  State<StopWatchPage> createState() => _StopWatchPageState();
}

class _StopWatchPageState extends State<StopWatchPage> {
  late Timer _timer; // 타이머
  var _time = 0; // 0.01초마다 1씩 증가시킬 정수형 변수
  var _isRunning = false; // 현재 시작 상태를 나타낼 불리언 변수

  List<String> _lapTimes = []; // 랩타임에 표시할 시간을 저장할 리스트

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration.zero, () {}); // 초기화
  }

// 위젯이 꺼질 때 _time 취소
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // overflow 방지
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('개인 운동 스톱워치'),
      ),
      body: _buildBody(), // 함수를 불러 내용 표시
      // 높이가 50인 bottom 네비바
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50.0,
        ),
      ),
      // 플로팅버튼: 누르면 _clickButton 시작!
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          _clickButton();
        }),
        // _isRunning가 true면 일시정지 아이콘, false면 플레이 아이콘
        child: _isRunning ? Icon(Icons.pause) : Icon(Icons.play_arrow),
      ),
      // 플로팅 버튼 위치는 정가운데에서
      // 다른 콘텐츠와 겹치지 않고 중앙 정렬 동시에 네비게이션 바 아래에도 위치
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // 내용 부분
  Widget _buildBody() {
    var sec = _time ~/ 100; // 초
    var hundredth = '${_time % 100}'.padLeft(2, '0'); // 1/100초

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        // 쌓는다.
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(
                  // 시간을 표시할 영역
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '$sec', // 초
                      style: TextStyle(fontSize: 70.0),
                    ),
                    Text(
                      '$hundredth',
                      style: TextStyle(fontSize: 25.0),
                    ), // 1/100초
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    // 기록을 표시할 영역
                    width: 250,
                    height: 300,
                    // 여러 개의 아이템을 스크롤 가능한 리스트로 나열
                    child: ListView(
                      children: _lapTimes
                          // map 메서드를 사용하여 각 랩 타임을 Text 위젯으로 변환
                          .map(
                            (time) => Text(
                              time,
                              style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          )
                          // 그것을 이어서 리스트로 변환
                          .toList(),
                    ),
                  ),
                )
              ],
            ),
            // 기록 삭제 아이콘
            Positioned(
              left: 10,
              bottom: 10,
              child: FloatingActionButton(
                heroTag: "btn1", // flutter 고유 태그 붙여주기(에러해결)
                backgroundColor: Colors.deepOrange,
                onPressed: _reset1, // 랩타임 기록만 삭제함
                child: Icon(
                  Icons.delete,
                  size: 24,
                ),
              ),
            ),
            // 시간 삭제 아이콘
            Positioned(
              left: 70,
              bottom: 70,
              child: FloatingActionButton(
                heroTag: "btn2", // flutter 고유 태그 붙여주기(에러해결)
                backgroundColor: Colors.deepOrange,
                onPressed: _reset2, // 시간만 0.00으로 초기화
                child: Icon(Icons.timer_off),
              ),
            ),
            // 기록 추가 아이콘
            Positioned(
              right: 10,
              bottom: 10,
              child: FloatingActionButton(
                heroTag: "btn3", // flutter 고유 태그 붙여주기(에러해결)
                backgroundColor: Colors.deepOrange,
                onPressed: () {
                  setState(() {
                    // 누르면 기록이 추가됨
                    _recordLapTime('$sec.$hundredth');
                  });
                },
                child: Icon(Icons.border_color),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 시작 또는 일시정지 버튼 함수
  void _clickButton() {
    // _isRunning이 true이면 false로, false이면 true로 변경
    // 목적: 상태를 반전시키는 이유는 토글 동작을 수행하기 위해서
    _isRunning = !_isRunning;

    if (_isRunning) {
      _start(); // true면 시작!
    } else {
      _pause(); // false면 중지!
    }
  }

// 시작!
  void _start() {
    //  10밀리초마다 코드를 실행하는 타이머를 생성
    _timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      setState(() {
        // 계속 더한다.
        _time++;
      });
    });
  }

  // 중지!
  void _pause() {
    _timer.cancel(); // 더하기를 취소한다.
  }

  // 기록만 삭제하기
  void _reset1() {
    setState(() {
      // 계속 더하는 것을 중지시킴
      _isRunning = false;
      _timer.cancel();
      // 기록만 전부 삭제
      _lapTimes.clear();
    });
  }

  // 시간만 초기화
  void _reset2() {
    setState(() {
      // 계속 더하는 것을 중지시킴
      _isRunning = false;
      _timer.cancel();
      // 시간을 0으로 바꿈
      _time = 0;
    });
  }

// 기록 버튼을 누르면 _lapTimes에 추가
  void _recordLapTime(String time) {
    _lapTimes.insert(0, '${_lapTimes.length + 1}번째 기록! [$time]');
  }
}
