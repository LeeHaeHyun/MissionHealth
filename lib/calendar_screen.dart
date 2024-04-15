import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// CalendarScreen 클래스는 StatefulWidget을 상속
class CalendarScreen extends StatefulWidget {
  CalendarScreen({Key? key}) : super(key: key);

// _CalendarScreenState의 객체를 반환
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

// _CalendarScreenState 클래스를 정의하고, State<CalendarScreen>을 상속
class _CalendarScreenState extends State<CalendarScreen> {
  // 초기값으로 현재 날짜와 시간을 설정(사용자가 직접 터치하여 선택한 날짜)
  late DateTime selectedDay = DateTime.now();
  // 초기값으로 현재 날짜와 시간을 설정(달력에서 오늘 날짜 포커스하기)
  late DateTime focusedDay = DateTime.now();
  // 메모의 개수를 저장하는 정수형 변수
  late int memoCount = 0;
  late TextStyle textStyle = TextStyle(
    fontWeight: FontWeight.w600,
    color: Color.fromARGB(255, 255, 255, 255),
  );

// 현재 화면이 로딩 중인지를 나타내는 boolean 타입 변수
  bool isLoading = false;

// 위젯의 초기화 단계에서 호출되는 메서드
  @override
  void initState() {
    super.initState();
    _initDB(); // 데이터베이스 초기화
    _updateMemoCount(selectedDay); // 처음 딱 켰을 때 메모 개수 업데이트
  }

// 데이터베이스를 초기화하는 비동기 함수
// SQLite 데이터베이스를 열고 초기화
  Future<Database> _initDB() async {
    // getDatabasesPath(): 데이터베이스 파일이 저장될 경로
    final dbPath = await getDatabasesPath();
    // 데이터베이스 파일의 경로를 결합합니다.
    // 여기서 'example.db'는 데이터베이스 파일의 이름
    final path = join(dbPath, 'example.db');
    // SQLite 데이터베이스를 열어 매개변수를 받는다.
    return await openDatabase(
      // 데이터베이스 파일의 경로
      path,
      // 데이터베이스의 버전
      version: 1,
      // 데이터베이스가 처음 생성될 때 실행할 함수
      // onCreate 함수는 데이터베이스가 처음 생성될 때 실행되며,
      // 해당 데이터베이스에 example 테이블을 생성하는 SQL 쿼리를 실행
      onCreate: (db, version) async {
        await db.execute(
          // idx 각 행이 자동으로 1씩 증가하는 숫자(시퀀스)
          // title: 이 열은 행의 제목
          // content: 이 열은 행의 내용을 저장
          // date: 이 열은 행의 날짜를 저장
          'CREATE TABLE example(idx INTEGER PRIMARY KEY autoincrement, title TEXT, content TEXT, date TEXT)',
        );
      },
    );
  }
/////////////////////// 여기까지 SQLITE 사용 준비가 끝난 것 ///////////////////////

// ★★ 데이터 추가하기
  Future<void> _insertData(String name, String value, String date) async {
    // 데이터베이스를 초기화하고 변수 db에 저장
    final db = await _initDB();

    // 데이터베이스의 example 테이블에 새로운 데이터를 추가
    await db.insert(
      'example',
      {'title': name, 'content': value, 'date': date},
      // 동일한 기본 키(primary key)를 가진 데이터가 이미 존재할 경우,
      // 새로운 데이터로 기존 데이터를 대체할 것
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // 선택한 날짜에 대한 메모 개수를 업데이트(선택한 날짜만 깜박 포인트)
    _updateMemoCount(selectedDay);
  }

// ★★ 메모의 개수 가져오기
// 역할: 선택한 날짜에 해당하는 메모가 있는지 여부를 확인
  Future<int> _getMemoCount(DateTime selectedDay) async {
    // 데이터베이스를 초기화하고 변수 db에 저장
    final db = await _initDB();
    // 선택한 날짜를 "년-월-일" 형식의 문자열로 변환하여 변수 formattedDate 저장
    final formattedDate =
        "${selectedDay.year}-${selectedDay.month}-${selectedDay.day}";

    // 특정한 날짜에 해당하는 메모의 개수를 가져오기 위해
    final List<Map<String, dynamic>> result = await db.rawQuery(
        // example 테이블에서 date 열이 특정한 날짜와 일치하는 레코드들의 개수를 세라!
        'SELECT COUNT(*) as count FROM example WHERE date = ?',
        [formattedDate]);
    // SQL 쿼리 결과인 result에서 첫 번째 행의 첫 번째 열의 정수 값을 추출, 없다면 0
    return Sqflite.firstIntValue(result) ?? 0;
  }

// ★★ 선택한 날짜에 해당하는 모든 메모를 가져오는 함수
// 역할: 메모들을 화면에 표시하는 데 사용
  Future<List<Map<String, dynamic>>> _future() async {
    // 데이터베이스를 초기화하고 변수 db에 저장
    final db = await _initDB();
    // 선택한 날짜를 "년-월-일" 형식의 문자열로 변환하여 변수 formattedDate 저장
    String formattedDate =
        "${selectedDay?.year}-${selectedDay?.month}-${selectedDay?.day}";
    // SQL 쿼리를 실행하여 선택한 날짜에 해당하는 모든 메모를 가져
    List<Map<String, dynamic>> dataset = await db
        // rawQuery 함수는 데이터베이스에서 직접 SQL 쿼리를 실행
        // 'example' 테이블에서 'date' 필드가 선택한 날짜와 일치하는 모든 레코드 조회
        .rawQuery('SELECT * FROM example WHERE date = ?', [formattedDate]);
    // 가져온 메모들을 담고 있는 리스트를 반환
    return dataset;
  }

// ★★ 데이터베이스 삭제하기
  Future<void> _deleteData(int idx) async {
    // 데이터베이스를 초기화하고 변수 db에 저장
    final db = await _initDB();
    await db.delete(
      // 테이블의 이름
      'example',
      // 삭제할 레코드를 선택하는 조건: 'idx' 열의 값이 동일한가?를 확인하는 구문
      where: 'idx = ?',
      // SQL 쿼리에서 사용되는 매개변수 값을 지정
      whereArgs: [idx],
    );
    _updateMemoCount(selectedDay); // 데이터 삭제 후 메모 개수 업데이트
  }

// ★★ 데이터베이스 수정하기
  Future<void> _updateData(int idx, String title, String content) async {
    // 데이터베이스를 초기화하고 변수 db에 저장
    final db = await _initDB();
    await db.update(
      // 테이블명
      'example',
      // 제목과 내용을 업데이트 지정
      {'title': title, 'content': content},
      where: 'idx = ?',
      whereArgs: [idx],
    );
    _updateMemoCount(selectedDay); // 데이터 업데이트 후 메모 개수 업데이트
  }

  void _showEditDialog(
      // 다이얼로그를 표시할 때 필요한 컨텍스트, 인덱스, 제목, 내용을 매개변수
      BuildContext context,
      int idx,
      String title,
      String content) {
    // 제목에 대한 입력을 처리하는 컨트롤러
    TextEditingController titleController = TextEditingController(text: title);
    // 내용에 대한 입력을 처리하는 컨트롤러
    TextEditingController contentController =
        TextEditingController(text: content);

// 메모를 수정하는 다이얼로그
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('메모 수정'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                // 제목을 입력받는 컨트롤러를 연결
                controller: titleController,
                decoration: InputDecoration(labelText: '제목'),
              ),
              TextField(
                // 내용을 입력받는 컨트롤러를 연결
                controller: contentController,
                decoration: InputDecoration(labelText: '내용'),
              ),
            ],
          ),
          // 취소를 누를 경우 걍 꺼짐
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            // 확인을 누르면 수정 함수 호출하여 번호, 제목, 내용을 보내버림(백엔드)
            TextButton(
              onPressed: () {
                _updateData(idx, titleController.text, contentController.text);
                // 그리고 꺼짐
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

// ★★ 메모의 개수를 업데이트
  void _updateMemoCount(DateTime date) async {
    setState(() {
      // 화면에 로딩 중임을 나타내기 위해 isLoading 변수를 true로 설정
      isLoading = true;
    });

    // 선택한 날짜에 해당하는 메모의 개수를 확인하기 위해
    // memoCount 변수에 담는다.
    final memoCount = await _getMemoCount(date);

    setState(() {
      // 메모 개수 업데이트
      // 원리: _getMemoCount 함수에서 반환된 메모의 개수를 memoCount 변수에 할당
      // 현재(this) 클래스의 memoCount 변수에 memoCount 값을 할당
      this.memoCount = memoCount;
      // 로딩 상태 다시 해제
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 화면의 크기가 키보드에 의해 자동으로 조정되지 않게(overflow 방지임)
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          // TableCalendar 위젯 사용!
          TableCalendar(
            locale: 'ko_KR', // 한국어로 설정
            // 달력의 첫 번째 날짜를 나타내는 속성
            firstDay: DateTime.utc(2021, 10, 16),
            // 달력의 마지막 날짜를 나타내는 속성
            lastDay: DateTime.utc(2030, 3, 14),
            // 현재 달력이 포커스된 날짜를 나타내는 속성
            focusedDay: focusedDay,
            weekendDays: [DateTime.saturday, DateTime.sunday],
            // 사용자가 달력에서 날짜를 선택할 때 호출되는 콜백 함수
            onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
              setState(() {
                // 선택된 날짜에 따라 selectedDay와 focusedDay를 업데이트하고,
                // 선택된 날짜에 대한 메모 개수를 업데이트하는
                // _updateMemoCount 함수를 호출
                this.selectedDay = selectedDay;
                this.focusedDay = focusedDay;
              });
              _updateMemoCount(selectedDay); // 날짜 선택 시 메모 개수 업데이트
            },
            // 특정 날짜가 선택된 날짜와 일치하는지 여부를 확인하는 함수
            selectedDayPredicate: (DateTime day) {
              // isSameDay: 달력에서 현재 선택된 날짜와 동일하면 true를 반환하고,
              // 그렇지 않으면 false
              return isSameDay(selectedDay, day);
            },
            // 달력을 월별로 표시함
            calendarFormat: CalendarFormat.month,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
            ),
            // 달력의 헤더 스타일을 설정하는 속성
            headerStyle: HeaderStyle(
              // 형식 변경 버튼을 숨김
              formatButtonVisible: false,
            ),
            // 달력 빌더 시작!
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                if (date.weekday == DateTime.saturday) {
                  return Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${date.day}',
                      style: TextStyle(color: Colors.blue), // 토요일 텍스트 색상
                    ),
                  );
                } else if (date.weekday == DateTime.sunday) {
                  return Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${date.day}',
                      style: TextStyle(color: Colors.red), // 일요일 텍스트 색상
                    ),
                  );
                } else {
                  return Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${date.day}',
                      style: TextStyle(color: Colors.black), // 나머지 요일 텍스트 색상
                    ),
                  );
                }
              },

              // 달력에서 각 날짜에 마커를 렌더링하는 함수
              // 빌드 컨텍스트, 해당 날짜, 해당 날짜에 연결된 이벤트 목록
              markerBuilder: (context, date, events) {
                // isLoading이 true면 원형 프로그레스 바 반환
                if (isLoading) {
                  return CircularProgressIndicator();
                } else {
                  // 비동기 작업의 결과에 따라 UI를 갱신(바로 깜박거림)
                  // 핵심: 다른 날짜를 선택한 것만으로 깜박거리지 않아야 함
                  // 다른 날짜를 선택하면 커서는 이동하지만, 빨간색 원은 갱신이 안된다.
                  return FutureBuilder<int>(
                    // 특정 날짜에 해당하는 메모의 개수를 비동기적으로 가져옴
                    future: _getMemoCount(date),
                    builder: (context, snapshot) {
                      // 만약 snapshot에 데이터가 있다면,
                      // 즉, 비동기 작업이 완료되었다면,
                      // 해당 날짜에 연결된 메모의 개수를 가져와서 처리합니다.(깜박!)
                      if (snapshot.hasData) {
                        // snapshot.data가 null이 아닌 경우에만 해당 값을 memoCount 변수에 할당
                        final int memoCount = snapshot.data!;
                        // 메모의 개수가 0보다 크면 빨간색 마커를 반환! 없다면 아무것도 반환 안함
                        // 삼항연산자를 사용한 부분
                        return memoCount > 0
                            ? Positioned(
                                right: 1,
                                bottom: 1,
                                child: Container(
                                  width: 18.0,
                                  height: 18.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                  // 빨간색 원 안에 숫자를 의미
                                  child: Center(
                                    child: Text(
                                      memoCount.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox();
                      } else {
                        return SizedBox();
                      }
                    },
                  );
                }
              },
            ),
          ),
          // 배경색이 초록색인 컨테이너
          Container(
            decoration: BoxDecoration(
              color: Colors.green[200],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              // 가로 방향으로 위젯 배치
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 첫 번째 텍스트 위젯은 선택된 날짜를 표시합니다.
                  Text(
                    '${selectedDay?.year}년 ${selectedDay?.month}월 ${selectedDay?.day}일',
                    style: textStyle,
                  ),
                  // 두 번째 텍스트 위젯은 메모 개수를 표시
                  Text(
                    '$memoCount개',
                    style: textStyle,
                  ),
                ],
              ),
            ),
          ),
          // 화면의 남은 공간을 활용하여 자식 위젯의 크기를 확장
          // 남은 부분을 다 쓴다는 것
          Expanded(
            // 비동기적으로 데이터를 가져와서 화면에 표시
            child: FutureBuilder(
              // _future() 함수를 호출하여 선택된 날짜의 메모 데이터를 불러옴
              future: _future(),
              builder: (context, snapshot) {
                // 현재 데이터의 상태를 나타내며, 데이터를 불러오는 중
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // 가운데에 원형 프로그래스바를 표시
                  return Center(child: CircularProgressIndicator());
                  // 에러난다면?
                } else if (snapshot.hasError) {
                  // 에러 표시
                  return Center(child: Text('Error: ${snapshot.error}'));
                  // 데이터가 없거나 비어있다면?
                } else if (!snapshot.hasData ||
                    (snapshot.data as List).isEmpty) {
                  return Center(child: Text('메모가 비어 있습니다.'));
                } else {
                  // List<Map<String, dynamic>> 형태의 데이터를 기반으로 각 항목을 생성
                  final List<Map<String, dynamic>> data =
                      snapshot.data as List<Map<String, dynamic>>;
                  // 스크롤 가능한 목록을 만들어주는 위젯
                  return ListView.builder(
                    // 자식 위젯의 크기에 맞게 ListView가 크기를 조절
                    shrinkWrap: true,
                    // 데이터 리스트(data)의 길이
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      // 각 항목에 대한 UI를 생성하는 부분
                      return ListTile(
                        // 제목
                        title: Text(
                          // 현재 인덱스 제목 필드 값을 문자열(String)으로 가져오는 것
                          data[index]['title'] as String,
                          style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 87, 18, 165),
                          ),
                        ),
                        // 부제목
                        subtitle: Text(
                          // 현재 인덱스 내용 필드 값을 문자열(String)으로 가져오는 것
                          data[index]['content'] as String,
                          style: TextStyle(
                            color: Color.fromARGB(255, 21, 71, 209),
                          ),
                        ),
                        // ListTile의 왼쪽에 표시
                        // 인덱스 값을 문자열로 변환하여 CircleAvatar 내부의 Text 위젯으로 표시
                        leading: CircleAvatar(
                          child: Text((index + 1).toString()),
                        ),
                        // ListTile의 오른쪽에 표시되는 아이콘
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              // 연필 아이콘
                              IconButton(
                                icon: Icon(Icons.edit, size: 30),
                                onPressed: () {
                                  _showEditDialog(
                                    context,
                                    // 현재 인덱스(index)에 해당하는 데이터의 필드 값을 미리 형변환
                                    data[index]['idx'] as int,
                                    data[index]['title'] as String,
                                    data[index]['content'] as String,
                                  );
                                },
                              ),
                              // 쓰레기통 아이콘
                              IconButton(
                                icon: Icon(Icons.delete, size: 30),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('메모 삭제'),
                                        content: Text('정말 삭제하시겠습니까?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('취소'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _deleteData(
                                                  // idx 번호를 _deleteData 매개변수로 전달하기 위해
                                                  // 미리 int로 형변환한다.
                                                  data[index]['idx'] as int);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('확인'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      // 오른쪽 더하기 아이콘 생성 버튼
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // 제목을 입력 받는 컨트롤러 객체 생성
              TextEditingController dateController = TextEditingController();
              // 내용을 입력 받는 컨트롤러 객체 생성
              TextEditingController contentController = TextEditingController();
              return AlertDialog(
                title: const Text('메모 추가'),
                // 자식 위젯이 넘칠 경우 스크롤을 가능(overflow 방지)
                content: SingleChildScrollView(
                  child: Container(
                    // 화면 너비의 80%에 해당하는 너비를 가진 컨테이너를 생성
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 150,
                    child: Column(
                      children: [
                        TextField(
                          // 제목 컨트롤러 연결시키기!
                          controller: dateController,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(hintText: '제목을 입력해주세요'),
                        ),
                        TextField(
                          // 내용 컨트롤러 연결시키기!
                          controller: contentController,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(hintText: '내용을 입력해주세요'),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  // 등록 버튼
                  TextButton(
                    onPressed: () {
                      // 제목과 내용 그리고 날짜를 _insertData로 전달
                      _insertData(
                        dateController.text,
                        contentController.text,
                        "${selectedDay?.year}-${selectedDay?.month}-${selectedDay?.day}",
                      );
                      // 닫아버리기~
                      Navigator.of(context).pop();
                    },
                    child: const Text('등록'),
                  ),
                  // 그냥 닫아버리기~~
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('취소'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
