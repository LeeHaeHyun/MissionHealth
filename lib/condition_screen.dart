import 'package:flutter/material.dart';
import 'package:mission_health/bmiresult.dart';
import 'package:mission_health/stopwatchpage.dart';

// 상태 탭 메인화면

class ConditionScreen extends StatefulWidget {
  const ConditionScreen({super.key});

  @override
  _ConditionScreenState createState() => _ConditionScreenState();
}

class _ConditionScreenState extends State<ConditionScreen> {
  // 키(cm) 값을 다루는 컨트롤러 생성
  final TextEditingController _heightController = TextEditingController();
  // 몸무게(kg) 값을 다루는 컨트롤러 생성
  final TextEditingController _weightController = TextEditingController();

// 체중과 키를 입력받아서 BMI 계산하는 함수
  double _calculateBMI(double weight, double heightCM) {
    // 잘못된 입력을 방지하기 위한 보호 조건
    if (weight <= 0 || heightCM <= 0) {
      return 0.0;
    }
    // BMI 계산 공식(체질량지수(BMI)는 체중(kg)을 키의 제곱(m^2)으로 나눈 값)
    return weight / ((heightCM / 100) * (heightCM / 100)); // 계산을 위해 M로 변환
  }

// BMI 결과를 반영하는 문지기 역할
  String _getWeightCategory(double bmi) {
    if (bmi < 18.5) {
      return '저체중';
    } else if (bmi <= 23) {
      return '정상';
    } else if (bmi <= 25) {
      return '과체중';
    } else if (bmi < 27) {
      return '경도비만';
    } else if (bmi < 30) {
      return '중등비만';
    } else {
      return '고도비만';
    }
  }

// 정상 체중으로 돌아가기 위해 필요한 체중 변화량을 계산하는 함수
  double _calculateWeightToNormal(double bmi) {
    // 정상 체중을 나타내는 BMI = 23.0
    double normalBMI = 23.0;
    // 사용자가 입력한 키를 읽어오는 코드, 실패하면 0.0
    double heightCM = double.tryParse(_heightController.text) ?? 0.0;
    // 정상 BMI와 현재 BMI의 차이를 계산한 후, 이를 키의 제곱에 곱하여 체중 변화량을 계산
    // 현재 체중에서 정상 체중까지의 차이를 계산하고, 이를 체중(KG)으로 반환
    return (normalBMI - bmi) * (heightCM / 100) * (heightCM / 100);
  }

// 사용자가 입력한 체중과 키를 읽어오는 부분
  void _calculateBMIResult() {
    // 텍스트필드에 입력한 값을 가져오고 숫자라면 double형 아니면 0.0으로 변환
    double weight = double.tryParse(_weightController.text) ?? 0.0;
    double height = double.tryParse(_heightController.text) ?? 0.0;

// 키 몸무게에 대한 예외 함수
    void showAlertDialog(BuildContext context, String title, String content) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
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

// 키가 0보다 크고 24보다 작다면?
    if (height < 24 && height > 0) {
      showAlertDialog(context, '잠깐!', '세계에서 가장 키가 작은 아기는 24cm입니다.');
      return;
    }
// 키가 251보다 크다면?
    if (height > 251) {
      showAlertDialog(context, '잠깐!', '세계에서 가장 키가 큰 사람는 251cm입니다.');
      return;
    }
// 키가 0보다 작거나 같다면?
    if (height <= 0) {
      showAlertDialog(context, '잠깐!', '키(cm)를 입력해주세요!');
      return;
    }
// 몸무게가 0보다 작거나 같다면?
    if (weight <= 0) {
      showAlertDialog(context, '잠깐!', '몸무게(kg)을 입력해주세요!');
      return;
    }
// 몸무게가 769보다 크다면?
    if (weight > 769) {
      showAlertDialog(context, '잠깐!', '세계에서 가장 무거운 사람은 769kg입니다.');
      return;
    }

    // 체지방률을 계산한 값
    double bmi = _calculateBMI(weight, height);
    // 체중 상태를 계산한 값
    String weightCategory = _getWeightCategory(bmi);
    // 정상까지 체중 변화를 계산한 값
    double weightToNormal = _calculateWeightToNormal(bmi);

    Navigator.push(
      context,
      MaterialPageRoute(
        // 변수들을 BmiResult의 매개변수로 전달
        builder: (context) => BmiResult(
          bmi: bmi,
          weightCategory: weightCategory,
          weightToNormal: weightToNormal,
        ),
      ),
    );
  }

  // 키보드를 숨기는 메서드
  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 화면의 크기가 키보드에 의해 자동으로 조정되지 않게(overflow 방지임)
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Center(
          child: Text(
            '미션! 건강 계산기',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.redAccent, // 앱바의 배경색
      ),
      body: GestureDetector(
        onTap: _dismissKeyboard, // 다른 곳을 탭하면 키보드 숨기기
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // Row를 기준으로 부모 위젯의 크기에 맞게 자동으로 확장
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                // 키를 다루는 컨트롤러와 연결
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '키 (cm)'),
                textInputAction: TextInputAction.done, // 완료 버튼 추가
                onEditingComplete: () =>
                    FocusScope.of(context).unfocus(), // 완료 버튼을 누르면 키보드 내리기
              ),
              SizedBox(height: 10),
              TextField(
                // 몸무게를 다루는 컨트롤러와 연결
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '몸무게 (kg)'),
                textInputAction: TextInputAction.done, // 완료 버튼 추가
                onEditingComplete: () =>
                    FocusScope.of(context).unfocus(), // 완료 버튼을 누르면 키보드 내리기
              ),
              SizedBox(height: 20),
              // 결과를 누르면 사용자가 입력한 체중과 키를 검증하는 함수를 호출
              ElevatedButton(
                onPressed: _calculateBMIResult,
                child: Text('결과'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StopWatchPage(),
                      settings: RouteSettings(name: 'StopWatchPage'),
                    ),
                  );
                },
                child: Text('스톱워치'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
