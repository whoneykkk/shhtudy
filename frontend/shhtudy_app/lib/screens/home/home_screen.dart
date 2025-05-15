import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../seat/seat_screen.dart';
import '../report/noise_report_screen.dart';
import '../mypage/my_page_screen.dart';
import '../../models/user_profile.dart';
import '../../services/user_service.dart';
import '../auth/login_screen.dart';
import '../../services/noise_service.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 사용자 프로필 정보
  UserProfile? userProfile;
  bool isLoading = true;
  double progressValue = 0.5;  // 프로그레스 바 초기값 50%
  int? currentRealtimeDecibel; // 실시간 데시벨 값 (테스트용 임시값)

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadRealtimeNoiseLevel(); // 실시간 소음 레벨 불러오기
    
    // 외부 마이크 연동을 위한 리스너 설정 준비
    // 실제 구현 시 마이크 데이터 스트림을 구독하는 방식으로 변경 예정
    /*
    // 실시간 소음 마이크 데이터 리스너 설정 예시
    MicrophoneService.listenToNoiseLevel((int noiseLevel) {
      if (mounted) {
        setState(() {
          currentRealtimeDecibel = noiseLevel;
        });
      }
    });
    */
    
    // TODO: 외부 마이크 연동 전까지 임시로 주기적으로 업데이트 (개발 중에만 사용)
    // 프로덕션에서는 외부 마이크 스트림 사용 예정
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _loadRealtimeNoiseLevel();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    // TODO: 마이크 리스너 정리 코드 추가 필요
    // MicrophoneService.disposeListener();
    super.dispose();
  }

  // 사용자 프로필 정보 불러오기
  Future<void> _loadUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 서버에서 최신 프로필 정보 가져오기
      final profile = await UserService.getUserProfile();
      
      if (!mounted) return; // 위젯이 아직 유효한지 확인
      
      if (profile != null) {
        setState(() {
          userProfile = profile;
          
          // 프로그레스바 값 계산 - 포인트 기반으로 등급별 다른 범위 사용
          progressValue = _calculateProgress(profile.grade, profile.points);
          
          // 실시간 데시벨값은 별도 함수에서 로딩
          isLoading = false;
        });
        
        // 프로필 로드 후 즉시 실시간 소음 레벨도 불러오기
        _loadRealtimeNoiseLevel();
      } else {
        // 서버에서 프로필을 가져오지 못한 경우 로그인 화면으로 이동
        setState(() {
          isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('사용자 정보를 불러올 수 없습니다. 다시 로그인해주세요.'),
            duration: Duration(seconds: 3),
          ),
        );
        
        // 로그인 화면으로 이동
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      print('프로필 로딩 오류: $e');
      
      setState(() {
        isLoading = false;
      });
      
      // 오류 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('데이터터 로딩 중 오류가 발생했습니다. 다시 로그인해주세요.'),
          duration: Duration(seconds: 3),
        ),
      );
      
      // 로그인 화면으로 이동
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      });
    }
  }

  // 실시간 소음 레벨 불러오기
  Future<void> _loadRealtimeNoiseLevel() async {
    try {
      // 좌석이 없으면 실시간 소음 데이터를 가져오지 않음
      if (userProfile?.currentSeat == null) {
        setState(() {
          currentRealtimeDecibel = null;
        });
        return;
      }
      
      // TODO: 외부 마이크 연동 구현 전까지 임시로 서버에서 데이터 가져오기
      // 실제 구현 시에는 이 함수가 마이크 모듈 초기화 역할만 담당하고
      // 이후에는 스트림 리스너로 실시간 업데이트
      final noiseLevel = await NoiseService.getCurrentNoiseLevel();
      
      if (mounted) {
        setState(() {
          currentRealtimeDecibel = noiseLevel;
        });
      }
    } catch (e) {
      print('실시간 소음 레벨 불러오기 오류: $e');
    }
  }

  String formatRemainingTime(int? seconds) {
    if (seconds == null) return '--:--:--';
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textColor.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.accentColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(scrollbars: true),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 상단 바
                Row(
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
                            Icons.menu_book,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'shh-tudy',
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        userProfile?.currentSeat ?? '--',
                        style: TextStyle(
                          color: AppTheme.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 프로필 버튼
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyPageScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[200],
                          child: Icon(
                            Icons.person_outline,
                            color: AppTheme.textColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 남은 시간
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '남은 시간',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColor.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            formatRemainingTime(userProfile?.remainingTime),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textColor,
                              letterSpacing: 2,
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 내 좌석 소음 정도
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '내 좌석 소음 정도',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColor.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 소음 레벨 원형 표시
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.normalColor,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.normalColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : userProfile?.currentSeat == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      '--DB',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  '${currentRealtimeDecibel ?? "--"}DB',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 소음 레벨 범례
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendItem('조용', AppTheme.quietColor),
                          const SizedBox(width: 32),
                          _buildLegendItem('양호', AppTheme.normalColor),
                          const SizedBox(width: 32),
                          _buildLegendItem('주의', AppTheme.warningColor),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 내 매너 점수
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '내 매너 점수',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColor.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Row(
                            children: [
                              isLoading
                                ? const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(),
                                  )
                                : Text(
                                    (userProfile?.mannerScore ?? 0).toString().padLeft(2, '0'),
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                              const SizedBox(width: 8),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    _getGradeText(userProfile?.grade),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progressValue,
                                  backgroundColor: Colors.white,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                  minHeight: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '평균 데시벨: ${userProfile?.averageDecibel != null ? userProfile!.averageDecibel.toString() : '--'}db',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '소음 발생 횟수: ${userProfile?.noiseOccurrence ?? '--'}회',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 하단 버튼
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SeatScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primaryColor,
                                ),
                                child: const Icon(
                                  Icons.chair_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '좌석 현황 보기',
                                style: TextStyle(
                                  color: AppTheme.textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NoiseReportScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primaryColor,
                                ),
                                child: const Icon(
                                  Icons.report_problem_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '소음 레포트',
                                style: TextStyle(
                                  color: AppTheme.textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
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

  // 등급별 프로그레스 바 값 계산
  double _calculateProgress(String? grade, int points) {
    if (grade == null) return 0.0;
    
    switch (grade.toUpperCase()) {
      case 'WARNING': // C 등급
        return (points / 300).clamp(0.0, 1.0);
      case 'GOOD': // B 등급
        return ((points - 300) / 400).clamp(0.0, 1.0);
      case 'SILENT': // A 등급
        return ((points - 700) / 300).clamp(0.0, 1.0);
      default:
        return 0.0;
    }
  }
}