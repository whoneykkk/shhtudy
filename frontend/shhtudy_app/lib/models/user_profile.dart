//백엔드에서 받아온 사용자 정보를 프론트엔드에서 다루기 쉽게 구조화
class UserProfile {
  final String userId; // firebaseUid
  final String name;
  final String nickname; // 사용자 닉네임 (ID 역할)
  final String grade;
  final int remainingTime;
  final String? currentSeat;
  final double averageDecibel;
  final int noiseOccurrence;
  final int mannerScore; // 매너 점수 (기본값 100)
  final int points; // 적립 포인트 (기본값 500)
  final String phoneNumber;

  UserProfile({
    required this.userId,
    required this.name,
    required this.nickname,
    required this.grade, 
    required this.remainingTime,
    this.currentSeat,
    required this.averageDecibel,
    required this.noiseOccurrence,
    this.mannerScore = 100, // 백엔드 기본값에 맞춤
    this.points = 500,
    this.phoneNumber = '',
  });

  // JSON에서 모델 생성
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'], // firebaseUid
      name: json['name'],
      nickname: json['nickname'], // 닉네임 사용
      grade: json['grade'],
      remainingTime: json['remainingTime'],
      currentSeat: json['currentSeat'],
      averageDecibel: json['averageDecibel'] != null 
          ? double.parse(json['averageDecibel'].toString())
          : 0.0,
      noiseOccurrence: json['noiseOccurrence'] ?? 0,
      mannerScore: json['mannerScore'] ?? 100, // 기본값 100
      points: json['points'] ?? 500,
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }

  // 모델을 JSON으로 변환 (SharedPreferences 저장용)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId, // firebaseUid
      'name': name,
      'nickname': nickname, // 닉네임 사용
      'grade': grade,
      'remainingTime': remainingTime,
      'currentSeat': currentSeat,
      'averageDecibel': averageDecibel,
      'noiseOccurrence': noiseOccurrence,
      'mannerScore': mannerScore,
      'points': points,
      'phoneNumber': phoneNumber,
    };
  }
  
  // 기존 코드 호환성을 위한 getter
  String get userAccountId => nickname; // nickname을 userAccountId로 접근 가능
}