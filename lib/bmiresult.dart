import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mission_health/ExerciseProvider.dart';

import 'ExerciseButton.dart';

class BmiResult extends StatefulWidget {
  final double bmi; // 체지방률
  final String weightCategory; // 정상 여부 결과
  final double weightToNormal; // 정상 체중까지 요구하는 체중(kg)

// BmiResult 위젯을 생성할 때 필요한 매개변수
  BmiResult({
    required this.bmi,
    required this.weightCategory,
    required this.weightToNormal,
  });

  @override
  _BmiResultState createState() => _BmiResultState();
}

// BmiResult 위젯의 상태를 관리
class _BmiResultState extends State<BmiResult> {
  late bool canClick = true; // 클릭 가능한 여부(초기화)
  late Timer? clickTimer; // 클릭 타이머 선언
  late int remainingSeconds; // 버튼 활성화까지 남은 시간

// 위젯이 처음으로 생성될 때 호출
  @override
  void initState() {
    super.initState();
    _loadLastClickedTime(); // 이전 클릭 시간을 불러오기
  }

// 위젯이 제거될 때 호출
  @override
  void dispose() {
    clickTimer?.cancel(); // 클릭 타이머를 취소
    super.dispose();
  }

// 마지막 클릭한 시간을 업데이트하고 상태를 업데이트
  void _updateLastClickedTime() async {
    // SharedPreferences는 키-값 쌍의 지속적인 데이터를 저장
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 현재 시간을 문자열로 변환하여 저장
    String currentTimeString = DateTime.now().toString();
    // SharedPreferences에 'lastClickedTime'이라는 키로 현재 시간을 저장
    await prefs.setString('lastClickedTime', currentTimeString);
    setState(() {
      // ExerciseProvider의 인스턴스를 가져옴
      // context : ExerciseProvider의 서비스에 접근
      // listen: false : canClick 상태만 업데이트하기에 다시 ui를 빌드할 필요 없음
      Provider.of<ExerciseProvider>(context, listen: false)
          // ExerciseProvider의 canClick 상태를 false로 업데이트(value를 false로 전달)
          .updateCanClick(false);
      Provider.of<ExerciseProvider>(context, listen: false)
          // ExerciseProvider의 remainingSeconds 상태를 43200으로 업데이트
          .updateRemainingSeconds(43200);
    });
    // 클릭 타이머를 시작
    startClickTimer();
  }

// 운동하기 버튼을 클릭할 수 있는지 여부를 결정하고 타이머를 시작
  Future<void> _loadLastClickedTime() async {
    // // SharedPreferences는 키-값 쌍의 지속적인 데이터를 저장
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 'lastClickedTime' 키에 저장된 값을 가져옴(이전에 클릭한 시간)
    String? lastClickedTimeString = prefs.getString('lastClickedTime');
    // 이전에 클릭한 시간이 null이 아니라면
    if (lastClickedTimeString != null) {
      // 이전에 클릭한 시간을 파싱하여 lastClickedTime 변수에 저장
      DateTime lastClickedTime = DateTime.parse(lastClickedTimeString);
      setState(() {
        // ExerciseProvider 클래스의 updateCanClick 메서드를 호출하여
        // 사용자가 운동을 클릭할 수 있는지 여부를 업데이트
        Provider.of<ExerciseProvider>(context, listen: false).updateCanClick(
            // 현재 시간과 이전 클릭 시간의 차이가 seconds: 이상인지 여부를 확인
            // 마지막 클릭 시간으로부터 seconds: 이상이 지났는지 확인
            DateTime.now().difference(lastClickedTime) >=
                // 기간을 나타내는 Duration 객체를 생성
                Duration(seconds: 43200));
        Provider.of<ExerciseProvider>(context, listen: false)
            // 사용자에게 남은 클릭 가능한 시간을 업데이트
            // 마지막 클릭 시간으로부터 seconds: 이상이 지났는지 확인
            .updateRemainingSeconds(DateTime.now()
                        .difference(lastClickedTime) >=
                    Duration(seconds: 43200)
                // 삼항 연산자 : 지났으면 0반환,
                // 안지났다면, 이전 클릭 시간으로부터 시간을 계산하여 사용자에게 남은 시간으로 설정
                // inseconds : 계산된 시간 차이를 초 단위로 변환하여 반환
                ? 0
                : 43200 - DateTime.now().difference(lastClickedTime).inSeconds);
      });
      // canClick 속성이 false인 경우에 startClickTimer() 함수를 호출
      if (!Provider.of<ExerciseProvider>(context, listen: false).canClick) {
        startClickTimer();
      }
    }
  }

// 1초마다 실행되는 타이머를 생성하여 사용자가 클릭할 수 있는 시간을 업데이트하고,
// 시간이 초과되면 클릭 가능한 상태를 다시 true로 설정하는 함수
  void startClickTimer() {
    //  1초마다 실행되는 반복 타이머를 생성
    clickTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        // ExerciseProvider 클래스의 객체를 가져오나 ui는 변화하지 않음
        Provider.of<ExerciseProvider>(context, listen: false)
            // 남은 시간을 업데이트
            .updateRemainingSeconds(
                Provider.of<ExerciseProvider>(context, listen: false)
                        .remainingSeconds -
                    1);
        // 만약 남은 시간이 0보다 같거나 작은 경우
        if (Provider.of<ExerciseProvider>(context, listen: false)
                .remainingSeconds <=
            0) {
          // 클릭 가능한 상태로 바꾸고
          Provider.of<ExerciseProvider>(context, listen: false)
              .updateCanClick(true);
          // 타이머를 취소함
          timer.cancel();
        }
      });
    });
  }

// 운동하기 버튼이 눌렸을 때 팝업창을 띄우는 함수
  void _handleExerciseButtonPress(BuildContext context) {
    // ExerciseProvider 클래스에 접근하기 위해 exerciseProvider 선언
    final exerciseProvider =
        Provider.of<ExerciseProvider>(context, listen: false);
    // 운동하기 버튼을 누를 수 있다면
    if (exerciseProvider.canClick) {
      // 마지막 클릭 시간을 업데이트
      _updateLastClickedTime();
      showDialog(
        context: context,
        barrierDismissible: false, // 팝업창 외부를 클릭할시 닫히면 안됨
        builder: (context) {
          return AlertDialog(
            title: Text('오늘의 운동'),
            content: SingleChildScrollView(
              // 스크롤 가능
              // 운동을 추첨하여 보여주는 역할
              // (String result)는 운동이 결정되면 실행되는 함수
              // onResultShown을 통해 선택된 함수를 표시
              // 당첨된 운동 결과를 부모 위젯으로 전달
              child: ExerciseAnimation(
                onResultShown: (String result) {
                  exerciseProvider.updateSelectedExercise(result);
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String emoji = ''; // 이모티콘
    String description = ''; // 설명

    switch (widget.weightCategory) {
      case '저체중':
        emoji = '😥';
        description = '몸에 지방이 부족합니다.';
        break;
      case '정상':
        emoji = '😊';
        description = '이대로 건강을 유지하세요.';
        break;
      case '과체중':
        emoji = '😓';
        description = '지금부터 살을 빼야 합니다.';
        break;
      case '경도비만':
        emoji = '😰';
        description = '위험한 상태입니다.';
        break;
      case '중등비만':
        emoji = '😨';
        description = '심각한 상태입니다.';
        break;
      case '고도비만':
        emoji = '😱';
        description = '매우 심각한 상태입니다.';
        break;
    }

    return Scaffold(
      // overflow 방지
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '건강 계산 결과',
          style: TextStyle(fontFamily: 'Pretendard'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.weightCategory, // 정상 여부 결과
              style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              // 소수점 2자리까지 체지방률을 표시
              '몸에 지방이 ${widget.bmi.toStringAsFixed(2)}%가 있습니다.',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              emoji,
              style: TextStyle(fontSize: 100),
            ),
            SizedBox(height: 20),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23),
            ),
            SizedBox(height: 20),
            if (widget.weightCategory != '정상') // 정상이 아닐 경우
              Text(
                // 삼항 연산자 사용
                '체중을 ${widget.weightToNormal.toStringAsFixed(2)} kg ${widget.weightCategory == '저체중' ? '늘려야합니다' : '감량해야'} 합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            SizedBox(height: 20),
            if (widget.weightCategory == '과체중' ||
                widget.weightCategory == '초등비만' ||
                widget.weightCategory == '중등비만' ||
                widget.weightCategory == '고도비만')
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // ExerciseProvider 클래스에 접근하기 위해 exerciseProvider 생성
                      final exerciseProvider =
                          Provider.of<ExerciseProvider>(context, listen: false);
                      if (exerciseProvider.canClick) {
                        // canClick가 true 상태일 경우
                        _handleExerciseButtonPress(context); // 팝업창 띄우기 실행
                      }
                    },
                    // ExerciseProvider에 접근하기 위해 Consumer 위젯 사용
                    child: Consumer<ExerciseProvider>(
                      // Consumer 위젯의 child 속성은 필수가 아니므로 _로 생략한다.
                      builder: (context, exerciseProvider, _) {
                        return Text(
                          exerciseProvider.canClick
                              ? '운동하기!'
                              : '${exerciseProvider.remainingSeconds}초 후에 다시 시도하세요.',
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  // ExerciseProvider에 접근하기 위해 Consumer 위젯 사용
                  Consumer<ExerciseProvider>(
                    builder: (context, exerciseProvider, _) {
                      // 당첨된 운동이 있을 경우
                      return exerciseProvider.selectedExercise.isNotEmpty
                          // 그 당첨된 운동을 보여주고, 없으면 공백
                          ? Text(exerciseProvider.selectedExercise)
                          : SizedBox.shrink();
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
