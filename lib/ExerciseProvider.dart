import 'package:flutter/material.dart';

class ExerciseProvider extends ChangeNotifier {
  late bool _canClick; // 클릭 가능 여부
  late int _remainingSeconds; // 남은 시간(운동하기 버튼)
  late String _selectedExercise; // 선택된 운동(랜덤 뽑기)

  // java의 게터와 같다. 호출하면 _변수의 값을 반환
  bool get canClick => _canClick;
  int get remainingSeconds => _remainingSeconds;
  String get selectedExercise => _selectedExercise; // 선택된 운동 getter 추가

  // 생성자 (초기화)
  ExerciseProvider() {
    _canClick = true;
    _remainingSeconds = 0;
    _selectedExercise = ''; // 선택된 운동 초기화
  }

// 기능: ChangeNotifier를 통해 ui를 업데이트

  // 클릭 가능 여부 업데이트(value라는 매개변수를 받는다.)
  void updateCanClick(bool value) {
    _canClick = value;
    notifyListeners();
  }

  // 남은 시간 업데이트(seconds라는 매개변수를 받는다.)
  void updateRemainingSeconds(int seconds) {
    _remainingSeconds = seconds;
    notifyListeners();
  }

  // 선택된 운동 업데이트(exercise라는 매개변수를 받는다.)
  void updateSelectedExercise(String exercise) {
    _selectedExercise = exercise;
    notifyListeners();
  }
}
