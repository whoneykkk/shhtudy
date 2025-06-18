import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:noise_meter/noise_meter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../models/user_profile.dart';
import '../config/api_config.dart';
import '../services/user_service.dart';
import '../models/noise_session_request.dart';
import '../models/noise_log.dart';
// import 'package:flutter/services.dart';  // 향후 마이크 플랫폼 채널 사용 시 필요

class NoiseService {
  // API 기본 URL
  static final String baseUrl = ApiConfig.baseUrl;
  static const String noiseLogsKey = 'noise_logs_cache';
  static const int quietThreshold = 45; // 45dB 이상은 소음으로 간주
  static const Duration cacheInterval = Duration(milliseconds: 500);
  
  // 마이크 채널 및 관련 변수 (향후 구현 시 주석 해제)
  // static const MethodChannel _channel = MethodChannel('com.shhtudy.microphone');
  // static Function(int)? _noiseCallback;
  // static bool _isListening = false;

  static final List<NoiseLog> _logs = [];
  static NoiseMeter? _noiseMeter;
  static StreamSubscription<NoiseReading>? _subscription;
  static bool _isRecording = false;
  // 외부에서 로그 가져올 수 있게
  static List<NoiseLog> get logs => List.unmodifiable(_logs);
  
  // 캐시된 통계 데이터
  static double _cachedAverageDecibel = 0;
  static double _cachedQuietRatio = 0;
  static double _cachedMaxDecibel = 0;
  static DateTime? _lastCacheUpdate;

  // 통계 데이터 getter
  static double get averageDecibel => _cachedAverageDecibel;
  static double get quietRatio => _cachedQuietRatio;
  static double get maxDecibel => _cachedMaxDecibel;

  // 매너 점수 계산 상수
  static const int BASE_MANNER_SCORE = 100;
  static const int MAX_MANNER_SCORE = 100;
  static const int MIN_MANNER_SCORE = 0;

  // 가점 요소
  static const int VERY_QUIET_DB_BONUS = 5;    // 35dB 이하
  static const int QUIET_DB_BONUS = 3;         // 35-40dB
  static const int NORMAL_DB_BONUS = 1;        // 40-45dB
  static const int VERY_QUIET_RATIO_BONUS = 5; // 90% 이상
  static const int QUIET_RATIO_BONUS = 3;      // 80-90%
  static const int NORMAL_RATIO_BONUS = 1;     // 70-80%

  // 감점 요소
  static const int HIGH_DB_PENALTY = 2;        // 50-55dB
  static const int VERY_HIGH_DB_PENALTY = 3;   // 55-60dB
  static const int EXTREME_DB_PENALTY = 5;     // 60dB 초과
  static const int ABRUPT_NOISE_PENALTY = 2;   // 급격한 소음 1회
  static const int ABRUPT_NOISE_PENALTY_2 = 3; // 급격한 소음 2회
  static const int ABRUPT_NOISE_PENALTY_3 = 5; // 급격한 소음 3회 이상
  static const int NOISE_VIOLATION_PENALTY = 2;    // 소음 위반 1-3회
  static const int NOISE_VIOLATION_PENALTY_2 = 3;  // 소음 위반 4-6회
  static const int NOISE_VIOLATION_PENALTY_3 = 5;  // 소음 위반 7회 이상

  static Future<bool> _checkAndRequestPermissions() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // 통계 데이터 업데이트
  static void _updateStatistics() {
    if (_logs.isEmpty) return;

    final now = DateTime.now();
    if (_lastCacheUpdate != null &&
        now.difference(_lastCacheUpdate!) < cacheInterval) {
      return;
    }

    final totalDecibel = _logs.fold<double>(0, (sum, log) => sum + log.level);
    _cachedAverageDecibel = totalDecibel / _logs.length;
    _cachedMaxDecibel = _logs
        .map((log) => log.level.toDouble())
        .reduce((a, b) => a > b ? a : b);
    final quietCount = _logs.where((log) => log.level <= quietThreshold).length;
    _cachedQuietRatio = quietCount / _logs.length;

    _lastCacheUpdate = now;
  }

  static Future<void> startNoiseMonitoring(Function(int) onNoiseLevel) async {
    // 이미 실행 중이면 중복 시작 방지
    if (_isRecording) {
      print('소음 측정이 이미 실행 중입니다.');
      return;
    }

    // 마이크 권한 체크
    final hasPermission = await _checkAndRequestPermissions();
    if (!hasPermission) {
      throw Exception('마이크 권한이 필요합니다.');
    }

    try {
      _noiseMeter = NoiseMeter();
      _subscription = _noiseMeter!.noise.listen(
        (reading) {
          // 유효하지 않은 값 처리
          if (reading.meanDecibel.isInfinite || reading.meanDecibel.isNaN) {
            print('유효하지 않은 소음 값 감지됨: ${reading.meanDecibel}');
            return;
          }

          // 소음 값 범위 제한 (0-120dB)
          double validDecibel = reading.meanDecibel.clamp(0, 120);
          final db = validDecibel.round();
          
          onNoiseLevel(db);

          // 로그 저장
          final log = NoiseLog(level: db, timestamp: DateTime.now(), isExceeded: db > quietThreshold);
          _logs.add(log);

          // 통계 데이터 업데이트
          _updateStatistics();

          // 기준 초과 시 서버 전송
          if (db > quietThreshold) {
            sendNoiseData(db);
          }
        },
        onError: (err) {
          print('NoiseMeter Error: $err');
          stopNoiseMonitoring();
        },
        cancelOnError: true,
      );

      _isRecording = true;
      print('소음 측정 시작됨');
    } catch (e) {
      print('소음 측정 시작 실패: $e');
      _isRecording = false;
      rethrow;
    }
  }

  static Future<void> stopNoiseMonitoring() async {
    if (!_isRecording) return;

    try {
      await _subscription?.cancel();
      _subscription = null;
      _noiseMeter = null;
      _isRecording = false;
      print('소음 측정 종료됨');
    } catch (e) {
      print('소음 측정 종료 중 오류: $e');
      rethrow;
    }
  }

  static Future<bool> sendNoiseData(int decibelLevel) async {
    try {
      final token = await UserService.getToken();
      if (token == null) throw Exception('인증 토큰 없음');

      final response = await http.post(
        Uri.parse('$baseUrl/api/noise/event'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'decibel': decibelLevel,
          'measuredAt': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200 &&
          json.decode(response.body)['success'] == true;
    } catch (e) {
      print('소음 로그 전송 실패: $e');
      return false;
    }
  }

  // 급격한 소음 발생 횟수 계산
  static int countAbruptNoises(List<NoiseLog> logs) {
    if (logs.isEmpty) return 0;

    int count = 0;
    int consecutiveSeconds = 0;
    NoiseLog? prevLog;

    for (var log in logs) {
      if (log.level > quietThreshold) {
        if (prevLog != null) {
          final diff = log.timestamp.difference(prevLog.timestamp).inSeconds;
          if (diff <= 1) {
            consecutiveSeconds += diff;
          } else {
            consecutiveSeconds = 1;
          }
        } else {
          consecutiveSeconds = 1;
        }

        if (consecutiveSeconds >= 3) {
          count++;
          consecutiveSeconds = 0;
          prevLog = null;
          continue;
        }
      } else {
        consecutiveSeconds = 0;
      }
      prevLog = log;
    }
    return count;
  }

  // 매너 점수 계산
  static int calculateMannerScore(double avgDb, double quietRatio, int abruptCount, int noiseExceededCount) {
    double score = BASE_MANNER_SCORE.toDouble();

    // 1. 평균 데시벨에 따른 가점
    if (avgDb <= 35) {
      score += VERY_QUIET_DB_BONUS;
    } else if (avgDb <= 40) {
      score += QUIET_DB_BONUS;
    } else if (avgDb <= 45) {
      score += NORMAL_DB_BONUS;
    }

    // 2. 조용한 시간 비율에 따른 가점
    if (quietRatio >= 0.9) {
      score += VERY_QUIET_RATIO_BONUS;
    } else if (quietRatio >= 0.8) {
      score += QUIET_RATIO_BONUS;
    } else if (quietRatio >= 0.7) {
      score += NORMAL_RATIO_BONUS;
    }

    // 3. 평균 데시벨에 따른 감점
    if (avgDb > 60) {
      score -= EXTREME_DB_PENALTY;
    } else if (avgDb > 55) {
      score -= VERY_HIGH_DB_PENALTY;
    } else if (avgDb > 50) {
      score -= HIGH_DB_PENALTY;
    }

    // 4. 급격한 소음 발생에 따른 감점
    if (abruptCount >= 3) {
      score -= ABRUPT_NOISE_PENALTY_3;
    } else if (abruptCount == 2) {
      score -= ABRUPT_NOISE_PENALTY_2;
    } else if (abruptCount == 1) {
      score -= ABRUPT_NOISE_PENALTY;
    }

    // 5. 소음 위반 횟수에 따른 감점
    if (noiseExceededCount >= 7) {
      score -= NOISE_VIOLATION_PENALTY_3;
    } else if (noiseExceededCount >= 4) {
      score -= NOISE_VIOLATION_PENALTY_2;
    } else if (noiseExceededCount >= 1) {
      score -= NOISE_VIOLATION_PENALTY;
    }

    // 최종 점수 범위 제한 (0-100)
    return score.clamp(MIN_MANNER_SCORE.toDouble(), MAX_MANNER_SCORE.toDouble()).round();
  }

  // 세션 종료 + 통계 서버 전송
  static Future<bool> closeNoiseSession(NoiseSessionRequest session) async {
    try {
      final token = await UserService.getToken();
      if (token == null) return false;

      // 급격한 소음 발생 횟수 계산
      final abruptCount = countAbruptNoises(_logs);
      
      // 소음 위반 횟수 계산
      final noiseExceededCount = _logs.where((log) => log.level > quietThreshold).length;

      // 매너 점수 계산
      final mannerScore = calculateMannerScore(
        session.averageDecibel,
        session.quietRatio,
        abruptCount,
        noiseExceededCount
      );

      final response = await http.put(
        Uri.parse('$baseUrl/api/noise/session/close'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          ...session.toJson(),
          'mannerScore': mannerScore,
          'abruptCount': abruptCount,
          'noiseExceededCount': noiseExceededCount,
        }),
      );

      if (response.statusCode == 200) {
        print('세션 종료 및 통계 저장 완료');
        return true;
      } else {
        print('세션 종료 실패: ${response.body}');
        return false;
      }
    } catch (e) {
      print('세션 종료 오류: $e');
      return false;
    }
  }

  // 세션 종료 + 통계 서버 전송
  static Future<bool> closeCurrentSession() async {
    if (_logs.isEmpty) {
      print('종료할 로그 없음');
      return false;
    }

    // 마지막 통계 업데이트
    _updateStatistics();

    // 세션 지속 시간 계산 (분 단위)
    final duration =
        _logs.last.timestamp.difference(_logs.first.timestamp).inMinutes;

    final session = NoiseSessionRequest(
      checkinTime: _logs.first.timestamp,
      checkoutTime: _logs.last.timestamp,
      averageDecibel: _cachedAverageDecibel,
      quietRatio: _cachedQuietRatio,
      maxDecibel: _cachedMaxDecibel,
      sessionDuration: duration,
    );

    final result = await closeNoiseSession(session);

    if (result) {
      _logs.clear();
      _cachedAverageDecibel = 0;
      _cachedQuietRatio = 0;
      _cachedMaxDecibel = 0;
      _lastCacheUpdate = null;
      print('세션 로그 초기화 완료');
    }
    return result;
  }

  // 소음 통계 데이터 가져오기
  static Future<Map<String, dynamic>?> getNoiseStats() async {
    try {
      // 사용자 프로필에서 소음 데이터 확인
      final UserProfile? userProfile = await UserService.getUserProfile();
      
      if (userProfile != null) {
        // 사용자 프로필에서 소음 관련 데이터 추출
        return {
          'grade': userProfile.grade,
          'averageDecibel': userProfile.averageDecibel,
          'noiseOccurrence': userProfile.noiseOccurrence,
          'currentSeat': userProfile.currentSeat,
        };
      }
      
      // 데이터가 없는 경우 기본값 반환
      return {
        'grade': 'GOOD',
        'averageDecibel': 0.0,
        'noiseOccurrence': 0,
        'currentSeat': '--',
      };
    } catch (e) {
      print('소음 통계 데이터 가져오기 오류: $e');
      // 오류 발생 시 기본값 반환
      return {
        'grade': 'GOOD',
        'averageDecibel': 0.0,
        'noiseOccurrence': 0,
        'currentSeat': '--',
      };
    }
  }

  // 소음 세션 로그 조회 (API 명세서 기반)
  // 백엔드에서는 30일 이상 지난 데이터를 자동으로 삭제하는 스케줄러 필요
  static Future<List<Map<String, dynamic>>> getNoiseSessionLogs() async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/noise/events?page=0&size=1000&sort=measuredAt,DESC'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('getNoiseSessionLogs Response Status: ${response.statusCode}'); // 상태 코드 출력
      print('getNoiseSessionLogs Response Body: ${response.body}'); // 응답 본문 출력

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['events'] is List) {
          return List<Map<String, dynamic>>.from(data['events']);
        }
        return [];
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> errorData = json.decode(response.body);
        if (errorData['message'] == "오늘 이용 기록이 없습니다.") {
          print('오늘 이용 기록이 없어 소음 로그를 가져오지 못했습니다.');
          return []; // 이용 기록이 없는 경우 빈 리스트 반환
        }
      }
      
      throw Exception('로그 조회 실패: ${response.statusCode}');
    } catch (e) {
      print('로그 조회 오류: $e');
      return [];
    }
  }

  // 소음 로그 조회
  static Future<List<Map<String, dynamic>>> getNoiseLogs() async {
    return await getNoiseSessionLogs();
  }

  // 일간 소음 이벤트 데이터 가져오기
  static Future<List<Map<String, dynamic>>> getDailyNoiseEvents(int page, int size) async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      // 백엔드 API 호출 (모든 이벤트를 가져오기 위해 충분히 큰 size 사용)
      final response = await http.get(
        Uri.parse('$baseUrl/api/noise/events?page=$page&size=$size&sort=measuredAt,DESC'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null && data['data']['content'] != null) {
          return List<Map<String, dynamic>>.from(data['data']['content']);
        }
      }

      throw Exception('일간 소음 이벤트 조회 실패: ${response.statusCode}');
    } catch (e) {
      print('일간 소음 이벤트 조회 중 오류: $e');
      return [];
    }
  }

  // 최신 소음 이벤트 데이터 가져오기 (전체 사용자 기준)
  static Future<List<Map<String, dynamic>>> getRecentNoiseEvents() async {
    try {
      final token = await UserService.getToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/noise/events?page=0&size=1000&sort=measuredAt,DESC'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('getRecentNoiseEvents Response Status: ${response.statusCode}'); // 상태 코드 출력
      print('getRecentNoiseEvents Response Body: ${response.body}'); // 응답 본문 출력

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['events'] is List) { // 'events' 키가 List 타입인지 확인
          return List<Map<String, dynamic>>.from(data['events']);
        }
      }
      
      throw Exception('최신 소음 이벤트 조회 실패: ${response.statusCode}');
    } catch (e) {
      print('최신 소음 이벤트 조회 중 오류: $e');
      return [];
    }
  }

  // 내 좌석의 실시간 소음 레벨 가져오기 (아직 API 없어서 더미 데이터 반환)
  static Future<int> getCurrentNoiseLevel() async {
    try {
      // 실제 API 호출 (향후 구현)
      // final response = await http.get(Uri.parse('$baseUrl/noise/current'));
      
      // 임시로 랜덤 값 반환 (35-55dB 범위)
      return 35 + (DateTime.now().millisecondsSinceEpoch % 21);
    } catch (e) {
      print('현재 소음 레벨 가져오기 오류: $e');
      return 40; // 기본값
    }
  }
} 

