import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

// 웹뷰 패키지 설치 : flutter pub add webview_flutter
class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 디바이스의 화면 여백을 고려하여 자식 위젯을 안전하게 배치
      body: SafeArea(
        child: WebView(
          // WebView가 표시할 초기 URL을 지정
          initialUrl:
              'https://www.hira.or.kr/ra/hosp/getHealthMap.do?tabgbn=03&WT.ac=HIRA%EA%B1%B4%EA%B0%95%EC%A7%80%EB%8F%84%EB%B0%94%EB%A1%9C%EA%B0%80%EA%B8%B0',
          javascriptMode: JavascriptMode.unrestricted,
          gestureNavigationEnabled: true, // 제스처 네비게이션 활성화
          onWebViewCreated: (controller) {
            // WebView가 생성될 때 호출되는 콜백 함수
            controller.evaluateJavascript('''
              // JavaScript 코드 실행
              // 여기서는 oMap 변수를 선언하여 null로 초기화합니다.
              var oMap = null;
            ''');
          },
          navigationDelegate: (NavigationRequest request) {
            // 모든 URL에 대한 네비게이션을 허용
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }
}
