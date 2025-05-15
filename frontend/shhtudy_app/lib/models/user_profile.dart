//백엔드에서 받아온 사용자 정보를 프론트엔드에서 다루기 쉽게 구조화
class UserProfile {
  final String userId;
  final String name;
  final String userAccountId;
  final String grade;
  final int remainingTime;
  final String? currentSeat;
  final double averageDecibel;
  final int noiseOccurrence;
  final int mannerScore;
  final int points;
  final String phoneNumber;

  UserProfile({
    required this.userId,
    required this.name,
    required this.userAccountId,
    required this.grade, 
    required this.remainingTime,
    this.currentSeat,
    required this.averageDecibel,
    required this.noiseOccurrence,
    this.mannerScore = 0,
    this.points = 0,
    this.phoneNumber = '',
  });

  // JSON에서 모델 생성
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      name: json['name'],
      userAccountId: json['userAccountId'],
      grade: json['grade'],
      remainingTime: json['remainingTime'],
      currentSeat: json['currentSeat'],
      averageDecibel: json['averageDecibel'] != null 
          ? double.parse(json['averageDecibel'].toString())
          : 0.0,
      noiseOccurrence: json['noiseOccurrence'] ?? 0,
      mannerScore: json['mannerScore'] ?? 0,
      points: json['points'] ?? 0,
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }

  // 모델을 JSON으로 변환 (SharedPreferences 저장용)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'userAccountId': userAccountId,
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
}