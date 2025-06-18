import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../mypage/my_page_screen.dart';
import 'noise_log_screen.dart';
import '../../services/noise_service.dart';
import '../../services/user_service.dart';
import '../../models/noise_log.dart';
import '../../models/user_profile.dart';
import '../../services/alert_service.dart';
import '../../widgets/profile_button.dart';
import 'dart:math' as math;
import 'dart:async'; // Timer 사용을 위해 추가

class NoiseReportScreen extends StatefulWidget {
  const NoiseReportScreen({super.key});

  @override
  State<NoiseReportScreen> createState() => _NoiseReportScreenState();
}

class _NoiseReportScreenState extends State<NoiseReportScreen> {
  // 현재 페이지 인덱스 추적
  int _currentPageIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  
  // 차트 타입 리스트
  final List<String> _chartTypes = [
    '일간 소음 변동 Line Chart',
    // '주간 소음 추이 Line/Bar Chart',
    // '좌석별 소음 비율 Bar Chart',
  ];

  // 데이터 상태 변수
  bool _isLoading = true;
  UserProfile? _userProfile; // 사용자 프로필 추가
  String? _grade;
  double? _averageDecibel;
  String? _currentSeatCode;
  List<NoiseLog> _noiseLogs = [];
  bool hasUnreadAlerts = false; // 읽지 않은 알림 여부
  
  // 추가 통계 데이터
  int _maxDecibel = 0;
  int _noiseExceededCount = 0;
  int _quietnessPercentage = 0;
  int _avgQuietnessPercentage = 0;

  // 일간 소음 변동 차트 데이터
  List<FlSpot> _dailyNoiseSpots = [];
  Timer? _dailyChartUpdateTimer;

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // 사용자 프로필을 먼저 로드
    _loadNoiseData();
    _checkUnreadAlerts(); // 읽지 않은 알림 확인
    _startDailyNoiseChartUpdate(); // 일간 소음 차트 업데이트 시작
  }

  // 사용자 프로필 로드
  Future<void> _loadUserProfile() async {
    try {
      final profile = await UserService.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _currentSeatCode = profile?.currentSeat; // 프로필에서 직접 좌석 정보 가져오기
        });
      }
    } catch (e) {
      print('사용자 프로필 로딩 오류: $e');
    }
  }

  // 읽지 않은 알림 확인
  Future<void> _checkUnreadAlerts() async {
    final unreadStatus = await AlertService.updateAlertStatus();
    if (mounted) {
      setState(() {
        hasUnreadAlerts = unreadStatus;
      });
    }
  }

  // 소음 데이터 로드
  Future<void> _loadNoiseData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 사용자 프로필과 소음 로그 데이터를 동시에 가져옵니다.
      final profile = await UserService.getUserProfile();
      final logs = await NoiseService.getNoiseLogs();
      final noiseLogs = logs.map((log) => NoiseLog.fromJson(log)).toList();

      if (!mounted) return;

      // 보고서에 필요한 통계 데이터를 가져온 noiseLogs를 기반으로 직접 계산합니다.
      double reportAverageDecibel = 0;
      double reportMaxDecibel = 0;
      int reportQuietCount = 0;
      int reportNoiseExceededCount = 0;

      if (noiseLogs.isNotEmpty) {
        final totalDecibel = noiseLogs.fold<double>(0, (sum, log) => sum + log.level);
        reportAverageDecibel = totalDecibel / noiseLogs.length;
        reportMaxDecibel = noiseLogs
            .map((log) => log.level.toDouble())
            .reduce((a, b) => a > b ? a : b);
        reportQuietCount = noiseLogs.where((log) => log.level <= NoiseService.quietThreshold).length;
        reportNoiseExceededCount = noiseLogs.where((log) => log.level > NoiseService.quietThreshold).length;
      }

      setState(() {
        _userProfile = profile; // 사용자 프로필 업데이트
        _grade = profile?.grade ?? 'GOOD'; // 사용자 프로필에서 등급 가져오기
        _averageDecibel = reportAverageDecibel;
        _currentSeatCode = profile?.currentSeat ?? '--'; // 사용자 프로필에서 좌석 정보 가져오기
        _noiseLogs = noiseLogs;

        _maxDecibel = reportMaxDecibel.toInt();
        _noiseExceededCount = reportNoiseExceededCount;
        _quietnessPercentage = noiseLogs.isEmpty ? 0 : (reportQuietCount / noiseLogs.length * 100).toInt();
        _avgQuietnessPercentage = 75; // 전체 사용자 평균은 API 추가 전까지 75%로 유지

        _isLoading = false;
      });
    } catch (e) {
      print('소음 데이터 로드 오류: $e');
      if (!mounted) return;

      setState(() {
        _grade = _userProfile?.grade ?? 'GOOD';
        _averageDecibel = _userProfile?.averageDecibel ?? 40.0;
        // _currentSeatCode는 이미 _loadUserProfile에서 설정됨
        _maxDecibel = 0;
        _noiseExceededCount = 0;
        _quietnessPercentage = 0;
        _avgQuietnessPercentage = 0;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dailyChartUpdateTimer?.cancel(); // 타이머 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 상단 바
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.podcasts,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '소음 레포트',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // 좌석 번호
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _currentSeatCode ?? '--',
                            style: TextStyle(
                              color: AppTheme.textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 프로필 버튼
                        ProfileButton(
                          hasUnreadAlerts: hasUnreadAlerts,
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => const MyPageScreen())
                            ).then((_) {
                              _checkUnreadAlerts();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // 등급 및 데시벨 정보
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // 현재 등급
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '현재 등급',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textColor.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getGradeText(_grade),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 평균 데시벨
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '평균 데시벨',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textColor.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _averageDecibel?.toStringAsFixed(0) ??
                                          '--',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 2, bottom: 4),
                                      child: Text(
                                        'db',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textColor
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 본문
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 차트 섹션
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 차트 제목
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Text(
                                        _chartTypes[0],
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // 차트
                                SizedBox(
                                  height: 250,
                                  child: _buildDailyNoiseLineChart(),
                                ),                           
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // 소음 로그 섹션
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '소음 로그',
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const NoiseLogScreen(),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.add,
                                        color: AppTheme.primaryColor,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (_noiseLogs.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Text(
                                        '소음 로그가 없습니다.',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    children: _buildNoiseLogItems(),
                                  ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 종합 피드백 섹션
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '종합 피드백',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                // 통계 카드
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      // 첫 번째 줄: 최고 데시벨과 소음 발생 횟수
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '최고 데시벨',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: AppTheme.textColor.withOpacity(0.6),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${_maxDecibel}dB',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.textColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 40,
                                            color: AppTheme.accentColor,
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 16),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '소음 발생',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: AppTheme.textColor.withOpacity(0.6),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${_noiseExceededCount}회',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.textColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: AppTheme.accentColor,
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      // 두 번째 줄: 조용 비율
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '조용 비율',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: AppTheme.textColor.withOpacity(0.6),
                                                ),
                                              ),
                                              Text(
                                                '${_quietnessPercentage}%',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // 조용 비율 프로그레스 바
                                          Container(
                                            height: 8,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Stack(
                                              children: [
                                                // 사용자 비율 표시
                                                Container(
                                                  height: 8,
                                                  width: MediaQuery.of(context).size.width * (_quietnessPercentage / 100) * 0.7,
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.primaryColor,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: Colors.orange,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '내 조용 비율: ${_quietnessPercentage}%',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.textColor.withOpacity(0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                // 오늘의 피드백
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getFeedbackMessage(_quietnessPercentage),
                                    style: TextStyle(
                                      color: AppTheme.textColor.withOpacity(0.8),
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // 소음 로그 카드 위젯
  Widget _buildNoiseLogCard(NoiseLog item) {
    final bool isExceeded = item.level > 45;
    final Color statusColor = isExceeded ? Colors.red : AppTheme.primaryColor;
    
    // 시간 포맷팅
    final hour = _twoDigits(item.timestamp.hour);
    final minute = _twoDigits(item.timestamp.minute);
    final formattedTime = '$hour:$minute';
    
    // 날짜 포맷팅
    final month = _twoDigits(item.timestamp.month);
    final day = _twoDigits(item.timestamp.day);
    final formattedDate = '${item.timestamp.year}-$month-$day';
    
    // 소음 상태 결정
    String statusText;
    Color color;
    IconData icon;
    
    if (item.level < 40) {
      color = AppTheme.primaryColor;  // 양호
      statusText = '정상';
      icon = Icons.volume_down;
    } else if (item.level < 50) {
      color = Colors.orange;  // 주의
      statusText = '주의';
      icon = Icons.volume_down;
    } else {
      color = Colors.red;  // 위험
      statusText = '소음 발생';
      icon = Icons.volume_up;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 소음 레벨 및 상태
          Row(
            children: [
              // 소음 아이콘
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              // 데시벨 값
              Text(
                '${item.level} dB',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              // 상태 표시
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 날짜 시간 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.access_time,
                size: 12,
                color: AppTheme.textColor.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                '$formattedDate $formattedTime',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 숫자를 2자리로 포맷팅 (날짜/시간 표시용)
  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  // 소음 비율에 따른 피드백 메시지
  String _getFeedbackMessage(int quietPercentage) {
    // 전체 평균과의 차이 계산
    final int difference = quietPercentage - _avgQuietnessPercentage;

    // 절대적 기준과 상대적 기준 모두 고려
    if (quietPercentage >= 80) {
      if (difference >= 5) {
        // 조용 비율이 매우 높고, 평균보다 더 높은 경우
        return '오늘 하루 집중하기 딱 좋은 환경이었어요. 멋진 분위기, 최고예요!';
      } else if (difference >= -5) {
        // 조용 비율이 매우 높지만, 평균과 비슷하거나 낮은 경우
        return '오늘 하루 집중하기 좋은 환경이었어요. 다른 분들도 모두 집중하는 분위기었네요!';
      } else {
        // 조용 비율이 매우 높지만, 평균과 비슷하거나 낮은 경우
        return '가끔 집중이 잘 되지 않는 날도 있죠. 모두의 작은 배려로 더 좋은 공간이 될 수 있어요!';
      }
    } else if (quietPercentage >= 70) {
      if (difference >= 5) {
        // 조용 비율이 적당히 높고, 평균보다 더 높은 경우
        return '좋은 하루였어요. 주변보다 더 조용한 환경을 유지하셨네요!';
      } else if (difference >= -5) {
        // 조용 비율이 적당히 높고, 평균과 비슷한 경우
        return '좋은 하루였어요. 모두의 작은 배려로 더 좋은 공간이 될 수 있어요!';
      } else {
        // 조용 비율이 적당히 높지만, 평균보다 낮은 경우
        return '가끔 집중이 잘 되지 않는 날도 있죠. 모두의 작은 배려로 더 좋은 공간이 될 수 있어요!';
      }
    } else {
      if (difference >= 0) {
        // 조용 비율이 낮지만, 평균보다는 높거나 같은 경우 (드문 경우)
        return '오늘은 전체적으로 시끄러운 환경이었네요. 모두의 작은 배려로 더 좋은 공간이 될 수 있어요!';
      } else if (difference >= -10) {
        // 조용 비율이 낮고, 평균보다 조금 낮은 경우
        return '오늘은 조금 시끄러운 환경이었네요. 모두의 작은 배려로 더 좋은 공간이 될 수 있어요!';
      } else {
        // 조용 비율이 낮고, 평균보다 많이 낮은 경우
        return '때로는 소란스러울 수도 있죠. 다음에는 모두 함께 더 좋은 공간을 만들어나가요.';
      }
    }
  }

  // 등급 표시 텍스트 반환
  String _getGradeText(String? grade) {
    if (grade == null) return '--';
    
    switch (grade.toUpperCase()) {
      case 'WARNING':
        return 'C';
      case 'SILENT':
        return 'A';
      case 'GOOD':
        return 'B';
      default:
        return grade[0];
    }
  }

  // 일간 소음 변동 Line Chart 위젯
  Widget _buildDailyNoiseLineChart() {
    if (_noiseLogs.isEmpty) {
      return const Center(
        child: Text(
          '소음 로그 데이터가 없습니다.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // 가장 최근 로그가 있는 날짜를 기준으로 필터링
    // 모든 로그를 확인하여 가장 최근 날짜를 찾음
    DateTime latestDay = _noiseLogs.reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b).timestamp;
    
    List<NoiseLog> dailyLogs = _noiseLogs.where((log) =>
        log.timestamp.year == latestDay.year &&
        log.timestamp.month == latestDay.month &&
        log.timestamp.day == latestDay.day).toList();

    if (dailyLogs.isEmpty) {
      return const Center(
        child: Text(
          '해당 날짜의 소음 로그 데이터가 없습니다.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // 시간별 평균 데시벨 계산
    Map<int, List<int>> hourlyDecibels = {};
    for (var log in dailyLogs) {
      final hour = log.timestamp.hour;
      // Chart's X-axis starts from 8 AM (value 0). So only include logs from 8 AM to 4 PM (value 8).
      if (hour >= 8 && hour <= 16) { 
        hourlyDecibels.putIfAbsent(hour, () => []).add(log.level);
      }
    }

    List<FlSpot> spots = [];
    for (int i = 8; i <= 16; i++) { // 8 AM to 4 PM (X-axis range 0 to 8)
      if (hourlyDecibels.containsKey(i)) {
        final levels = hourlyDecibels[i]!;
        if (levels.isNotEmpty) {
          final average = levels.reduce((a, b) => a + b) / levels.length;
          spots.add(FlSpot((i - 8).toDouble(), average));
        }
      }
    }
    spots.sort((a, b) => a.x.compareTo(b.x)); // X축 값 기준으로 정렬

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 10,
            verticalInterval: 1, 
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppTheme.primaryColor.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: AppTheme.primaryColor.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) { // 8시부터 시작하도록 조정
                  int hour = (value.toInt() + 8); // 0 on x-axis is 8 AM
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8.0,
                    child: Text(
                      '$hour시',
                      style: TextStyle(
                        color: AppTheme.textColor.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 8.0,
                    child: Text(
                      '${value.toInt()}',
                      style: TextStyle(
                        color: AppTheme.textColor.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          minX: 0, // X축 최소값 (8 AM)
          maxX: 8, // X축 최대값 (4 PM)
          minY: 30,
          maxY: 60,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  Color dotColor = spot.y > NoiseService.quietThreshold ? Colors.red : AppTheme.primaryColor;
                  return FlDotCirclePainter(
                    radius: 3,
                    color: dotColor,
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 주간 소음 추이 Line/Bar Chart 위젯
  Widget _buildWeeklyNoiseChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주간 데이터는 아직 준비 중입니다',
            style: TextStyle(
              color: AppTheme.textColor.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          // 샘플 UI 표시
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.backgroundColor.withOpacity(0.5),
            ),
            child: Center(
              child: Icon(
                Icons.bar_chart,
                size: 80,
                color: AppTheme.primaryColor.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 좌석별 소음 비율 Bar Chart 위젯
  Widget _buildSeatNoiseBarChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '좌석별 데이터는 아직 준비 중입니다',
            style: TextStyle(
              color: AppTheme.textColor.withOpacity(0.7),
              fontSize: 14,
            ),

          ),
          const SizedBox(height: 8),
          // 샘플 UI 표시
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.backgroundColor.withOpacity(0.5),
            ),
            child: Center(
              child: Icon(
                Icons.grid_view,
                size: 80,
                color: AppTheme.primaryColor.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<NoiseLog> _getLatestNoiseLogs() {
    // 최신 3개의 소음 로그만 표시
    final logs = [..._noiseLogs];
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // 최신순 정렬
    return logs.take(3).toList();
  }

  List<Widget> _buildNoiseLogItems() {
    // 최신 3개의 소음 로그만 표시
    return _getLatestNoiseLogs()
        .map((item) => _buildNoiseLogCard(item))
        .toList();
  }

  // 조용 비율에 따른 색상 반환
  Color _getQuietnessColor(int percentage) {
    if (percentage >= 80) return AppTheme.primaryColor;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  // 일간 소음 차트 업데이트 시작
  void _startDailyNoiseChartUpdate() {
    _dailyChartUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) async { // 10초마다 업데이트
      if (!mounted) {
        timer.cancel();
        return;
      }
      await _loadDailyNoiseEventsForChart();
    });
    _loadDailyNoiseEventsForChart(); // 초기 로드
  }

  // 일간 소음 이벤트 데이터를 가져와 차트 데이터로 가공
  Future<void> _loadDailyNoiseEventsForChart() async {
    try {
      final events = await NoiseService.getRecentNoiseEvents(); // 최신 이벤트 가져오기
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // 오늘 날짜의 데이터만 필터링
      final todayEvents = events.where((event) {
        final measuredAt = DateTime.parse(event['measuredAt']);
        return measuredAt.year == today.year &&
               measuredAt.month == today.month &&
               measuredAt.day == today.day;
      }).toList();

      // 시간대별 평균 데시벨 계산
      Map<int, List<int>> hourlyDecibels = {};
      for (var event in todayEvents) {
        final measuredAt = DateTime.parse(event['measuredAt']);
        final hour = measuredAt.hour;
        hourlyDecibels.putIfAbsent(hour, () => []).add(event['decibel']?.toInt() ?? 0);
      }

      List<FlSpot> newSpots = [];
      for (int hour = 0; hour < 24; hour++) {
        if (hourlyDecibels.containsKey(hour)) {
          final avgDecibel = hourlyDecibels[hour]!.reduce((a, b) => a + b) / hourlyDecibels[hour]!.length;
          newSpots.add(FlSpot(hour.toDouble(), avgDecibel));
        } else {
          // 데이터가 없는 시간대는 0으로 표시 (혹은 이전 값 유지 등 다른 전략 고려 가능)
          newSpots.add(FlSpot(hour.toDouble(), 0));
        }
      }

      // 시간에 따라 정렬
      newSpots.sort((a, b) => a.x.compareTo(b.x));

      if (mounted) {
        setState(() {
          _dailyNoiseSpots = newSpots;
        });
      }
    } catch (e) {
      print('일간 소음 이벤트 차트 데이터 로드 중 오류: $e');
    }
  }
} 