import 'package:flutter/material.dart';

import 'data.dart';

// 첫번째 탭, 질병 사전 페이지

class DiseaseScreen extends StatefulWidget {
  const DiseaseScreen({super.key});

  @override
  State<DiseaseScreen> createState() => _DiseaseScreenState();
}

class _DiseaseScreenState extends State<DiseaseScreen> {
  // 카드를 클릭했을 때 발생하는 이벤트를 처리하는 함수
  void cardClickEvent(BuildContext context, int index) {
    // 클릭한 카드에 해당하는 내용을 가져와서 (itemContents[index]),
    // 이를 ContentPage 화면으로 전환하여 보여주는 역할
    String content = itemContents[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentPage(content: content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 디버그 띠 없애기
      debugShowCheckedModeBanner: false,
      // 가로 축 중심으로 중앙 정렬
      home: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            // 왼쪽과 오른쪽에 패딩을 주어 간격 조정
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: TextField(
              // 힌트 텍스트(hintText)와 외곽선(border)을 설정
              decoration: InputDecoration(
                hintText: '질병명을 입력해주세요.',
                border: OutlineInputBorder(),
              ),
              // 입력 필드의 내용이 변경될 때마다 호출되는 콜백 함수
              onChanged: (value) {
                setState(() {
                  // 사용자가 입력한 텍스트를 searchText 변수에 저장하고,
                  // 화면을 다시 그리기 위해 setState 함수를 호출
                  searchText = value;
                });
              },
            ),
          ),
          // 태그를 필터링하기 위해 사용되는 위젯
          Padding(
            padding: const EdgeInsets.all(8.0),
            // 자식 위젯을 가로로 배열하는 위젯
            child: Wrap(
              // 자식 위젯 사이의 간격을 설정
              spacing: 8.0,
              // Wrap 위젯에 포함될 자식 위젯들의 리스트
              // tags 리스트의 각 요소를 반복하여
              // FilterChip 위젯으로 변환한 후, 리스트로 반환
              children: tags.map((tag) {
                // 사용자가 선택할 수 있는 칩(chip) 위젯
                return FilterChip(
                  // 칩 안에 표시되는 텍스트 레이블
                  label: Text(tag),
                  // 칩이 선택되었는지 여부를 나타내기 위함
                  selected: activatedTags.contains(tag),
                  // 칩이 선택되었을 때 호출되는 콜백 함수
                  onSelected: (bool value) {
                    setState(() {
                      if (value) {
                        activatedTags.add(tag); // 태그 활성화
                      } else {
                        activatedTags.remove(tag); // 태그 비활성화
                      }
                    });
                  },
                );
                // map() 메소드로 생성된 객체를 리스트로 변환하는 역할
              }).toList(),
            ),
          ),
          // 레이아웃의 사용 가능한 모든 공간을 꽉 채우도록 자식 위젯을 확장
          Expanded(
            child: Center(
              // 리스트 형태의 위젯을 동적으로 생성할 수 있는 위젯
              // 스크롤 기능이 내장
              child: ListView.builder(
                // 아이템의 길이만큼
                itemCount: items.length,
                // 각 아이템을 구성하는 데 사용되는 콜백 함수
                // 콜백 함수 : 다른 함수에 전달되어 특정 상황이 발생했을 때 호출되는 함수
                itemBuilder: (BuildContext context, int index) {
                  // 질명병 검색 텍스트필드에 내용이 있는데 아이템에 검색 텍스트가 없다면
                  // 숨깁니다. (검색으로 인한 예외분류)
                  if ((searchText.isNotEmpty &&
                          !items[index].contains(searchText)) ||
                      // 태그는 활성되어 있는데 아이템 내용 안에는 태그의 내용이 하나도 없다면
                      // 숨깁니다.(태그로 인한 예외분류)
                      (activatedTags.isNotEmpty &&
                          !activatedTags.any(
                              (tag) => itemContents[index].contains(tag)))) {
                    // 크기가 0인 위젯을 생성(아이템을 숨기는 용도)
                    return SizedBox.shrink();
                  } else {
                    return Card(
                      // Card의 그림자 깊이
                      elevation: 3,
                      // 타원형의 모서리를 가진 모양
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            // 테두리 둥글게 만들기:가로축과 세로축의 반지름이 각각 20
                            BorderRadius.all(Radius.elliptical(20, 20)),
                      ),
                      //  리스트 아이템을 구성하는데 사용되는 위젯
                      child: ListTile(
                        // 제목(리스트의 각 아이템에 해당하는 문자열을 화면에 표시)
                        title: Center(child: Text(items[index])),
                        // 클릭했을 때 아래의 ContentPage로 보내기 위한 함수
                        onTap: () => cardClickEvent(context, index),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ContentPage extends StatelessWidget {
  // data.dart의 itemContents 리스트를 가져옴
  final String content;

  const ContentPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '핵심 요약',
          style: TextStyle(
            fontFamily: 'Pretendard',
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Text(
              content, // 여기에 입력
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ),
    );
  }
}
