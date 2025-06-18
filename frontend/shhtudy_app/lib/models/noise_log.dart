//소음 로그 모델 클래스

class NoiseLog {
  final int level;         // 소음 레벨 (dB)
  final bool isExceeded;   // 기준 소음 초과 여부
  final DateTime timestamp; // 측정 시간

  NoiseLog({
    required this.level,
    required this.isExceeded,
    required this.timestamp,
  });
  
  // JSON 데이터로부터 객체 생성 (API 응답 처리용)
  factory NoiseLog.fromJson(Map<String, dynamic> json) {
    return NoiseLog(
      level: json['level'],
      isExceeded: json['isExceeded'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
  
  // 객체를 JSON 데이터로 변환 (API 요청 처리용)
  Map<String, dynamic> toJson() {
    return {
      'decibel': level,
      'isExceeded': isExceeded,
      'measuredAt': timestamp.toIso8601String(),
    };
  }
} 