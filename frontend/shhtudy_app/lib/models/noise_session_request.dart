// 체크아웃시 전송 데이터 모델
class NoiseSessionRequest {
  final DateTime checkinTime;
  final DateTime checkoutTime;
  final double averageDecibel;
  final double quietRatio;
  final double maxDecibel;
  final int sessionDuration; // 세션 지속 시간 (분)

  NoiseSessionRequest({
    required this.checkinTime,
    required this.checkoutTime,
    required this.averageDecibel,
    required this.quietRatio,
    required this.maxDecibel,
    required this.sessionDuration,
  });

  Map<String, dynamic> toJson() => {
        'checkinTime': checkinTime.toIso8601String(),
        'checkoutTime': checkoutTime.toIso8601String(),
        'averageDecibel': averageDecibel,
        'quietRatio': quietRatio,
        'maxDecibel': maxDecibel,
        'sessionDuration': sessionDuration,
      };
} 