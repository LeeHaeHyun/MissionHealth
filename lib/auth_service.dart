import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// firebase Authentication 서비스 관련

// AuthService 클래스는 ChangeNotifier 클래스를 상속
// ChangeNotifier는 상태 변경을 알리고 UI를 업데이트 기능을 담당
// 현재 로그인된 사용자를 확인하고 필요한 상태 변경을 알릴 수 있는 중요한 역할
class AuthService extends ChangeNotifier {
  User? currentUser() {
    // 현재 유저(로그인 되지 않은 경우 null 반환)
    // 현재 로그인된 사용자를 확인하는데, 만약 사용자가 로그인되어 있지 않다면 null을 반환
    return FirebaseAuth.instance.currentUser;
  }

// 인증 서비스나 관련된 기능을 다루는 클래스
  void signIn({
    required String email, // 이메일
    required String password, // 비밀번호
    required Function() onSuccess, // 로그인 성공시 호출되는 함수
    required Function(String err) onError, // 에러 발생시 호출되는 함수
  }) async {
    // 로그인할 때 비어있다면 출력됨
    if (email.isEmpty) {
      onError('이메일을 입력해주세요.');
      return;
    } else if (password.isEmpty) {
      onError('비밀번호를 입력해주세요.');
      return;
    }

    // 로그인 시도(로그인 시도 과정에서 발생할 수 있는 예외를 처리)
    try {
      // 사용자의 이메일과 비밀번호로 로그인을 시도(FirebaseAuth)
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      onSuccess(); // 성공 함수 호출
      notifyListeners(); // 로그인 상태 변경 알림
    } on FirebaseAuthException catch (e) { 
      // firebase auth 에러 커스텀
      if (e.code == 'weak-password') {
        onError('비밀번호를 6자리 이상 입력해 주세요.');
      } else if (e.code == 'invalid-credential') {
        onError('이메일과 비밀번호가 일치하지 않습니다.');
      } else if (e.code == 'invalid-email') {
        onError('올바른 이메일 형식이 아닙니다.');
      } else if (e.code == 'user-not-found') {
        onError('일치하는 이메일이 없습니다.');
      } else if (e.code == 'wrong-password') {
        onError('비밀번호가 일치하지 않습니다.');
      } else if (e.code == 'too-many-requests') {
        onError('너무 많은 로그인 시도로 과부하가 발생했습니다. 1시간 후에 다시 시도해주세요.');
      } else {
        onError(e.message!);
      }
    } catch (e) {
      // Firebase auth 이외의 에러 발생
      onError('스크린샷 요청 : ' + e.toString());
    }
  }

  void signOut() async {
    // 로그아웃
    await FirebaseAuth.instance.signOut();
    notifyListeners(); // 로그인 상태 변경 알림
  }
}
