import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// 미션 헬스 랜덤 운동 뽑기 페이지

class ExerciseAnimation extends StatefulWidget {
  // onResultShown은 String을 인자로 받는 함수
  // 목적: 당첨된 운동결과를 bmiresult로 전달하기 위함
  final Function(String) onResultShown;

  // ExerciseAnimation 위젯은 onResultShown라는 콜백 함수를 인자로 받음
  // 역할: 운동 결과가 표시되었을 때 호출
  ExerciseAnimation({required this.onResultShown});

  @override
  _ExerciseAnimationState createState() => _ExerciseAnimationState();
}

class _ExerciseAnimationState extends State<ExerciseAnimation> {
  // 소수의 고정값이기에 코드 안에 쓰는 것이 안정적(운동목록)
  final List<String> exercises = [
    '빠른 걸음 50분',
    '계단 오르기 20분',
    '팔굽혀펴기 30회',
    '스쿼트 50회',
    '팔 벌려뛰기 100회',
    '플랭크 1분 유지',
    '윗몸 일으키기 30회',
    '줄넘기 300회',
    '달리기 15분',
    '버피 35회',
    '플랭크잭 50회',
    '10000보 걷기',
    '금일 단식',
    '줄넘기 100회',
    '팔 벌려뛰기 300회',
    '팔 벌려뛰기 500회',
    '윗몸 일으키기 50회',
    '금일 단식',
    '스쿼트 30회',
    '계단 오르기 10분',
    '줄넘기 1000회',
    '줄넘기 500회',
    '달리기 25분',
    '버피 50회',
    '빠른 걸음 90분',
  ];
  // 선택된 운동을 저장하는 변수(초기화)
  String selectedExercise = '';
  // 현재 애니메이션이 진행 중인지를 나타내는 변수(초기화)
  bool _animationInProgress = false;
  // 랜덤 값을 생성
  Random _random = Random();

// StatefulWidget의 생명주기이며, 위젯이 처음 생성될 때 호출
  @override
  void initState() {
    super.initState();
    // _startAnimation() 메서드를 호출하여 애니메이션을 시작
    _startAnimation();
  }

// 애니메이션 시작!
  void _startAnimation() {
    // 애니메이션이 진행 중(true)
    _animationInProgress = true;
    _runAnimation(); // 실행한다!
  }

  // 애니메이션을 실행하는 함수
  void _runAnimation() {
    // Future.delayed를 사용하여 100밀리초 후에 코드 블록을 실행
    Future.delayed(Duration(milliseconds: 100), () {
      // 애니메이션이 진행 중이 아니라면 함수를 종료(return;)
      if (!_animationInProgress) return;
      // 진행중이라면 운동 목록에서 랜덤한 인덱스(nextInt)를 선택
      setState(() {
        int nextIndex = _random.nextInt(exercises.length);
        // 선택된 인덱스에 해당하는 운동을 selectedExercise 변수에 저장
        selectedExercise = exercises[nextIndex];
      });
      // 선택된 인덱스가 비어 있다면
      if (selectedExercise.isEmpty) {
        // 애니메이션이 실행되어야 함
        _runAnimation();
      } else {
        _showResult(selectedExercise); // _showResult에 selectedExercise 전달하여 호출
      }
    });
  }

  // 1초후 당첨을 알리는 애니메이션
  void _showResult(String exercise) {
    // Future.delayed를 사용하여 1초 후에 코드 블록을 실행
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        // [당첨]을 넣어서 업데이트 저장
        selectedExercise = '[당첨] $selectedExercise';
      });
      // 당첨된 운동을 부모 위젯으로 전달
      // (이유: 이 데이터를 bmiresult에서 쓰기 위해)
      widget.onResultShown(selectedExercise);
    });
  }

  // 꺼질 때 호출되는 함수
  @override
  void dispose() {
    // 현재 애니메이션이 진행 중인지를 나타내는 변수(초기화)
    _animationInProgress = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // 자식 위젯들을 세로 중앙에 정렬
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 자식이 변경될 때 자동으로 애니메이션을 적용
        AnimatedSwitcher(
          // 전환 애니메이션의 지속 시간
          duration: Duration(milliseconds: 500),
          child: Text(
            // 선택된 운동 이름
            selectedExercise,
            // 애니메이션 전환을 위해 각 Text 위젯에 고유한 키를 부여
            // AnimatedSwitcher가 이전 위젯과 새로운 위젯을 구별하기 위함
            key: Key(selectedExercise),
            style: TextStyle(fontSize: 24),
          ),
        ),
      ],
    );
  }
}
