import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../mypage/my_page_screen.dart';
import '../../services/alert_service.dart';
import '../../services/seat_service.dart';
import '../../services/user_service.dart';
import '../../models/user_profile.dart';
import '../../widgets/profile_button.dart';

// 좌석 상태 enum
enum SeatStatus {
  empty,
  quiet,
  normal,
  warning,
  mine,
}

// 좌석 정보 클래스
class SeatInfo {
  final String code;
  final SeatStatus status;
  final bool isMine;

  SeatInfo({
    required this.code,
    required this.status,
    this.isMine = false,
  });
}

class SeatScreen extends StatefulWidget {
  const SeatScreen({super.key});

  @override
  State<SeatScreen> createState() => _SeatScreenState();
}

class _SeatScreenState extends State<SeatScreen> {
  String? currentSeatCode;
  String selectedZone = 'A';
  final List<String> zones = ['A', 'B', 'C', 'D'];
  final TextEditingController _messageController = TextEditingController();
  bool hasUnreadAlerts = false;
  bool isLoading = false;
  
  // 실제 좌석 데이터
  List<Map<String, dynamic>> currentZoneSeats = [];
  List<String> accessibleZones = [];
  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
    _checkUnreadAlerts();
    _loadUserProfile();
    _loadAccessibleZones();
    _loadSeatsData();
  }

  // 사용자 프로필 로드
  Future<void> _loadUserProfile() async {
    try {
      final profile = await UserService.getUserProfile();
      if (mounted) {
        setState(() {
          userProfile = profile;
          currentSeatCode = profile?.currentSeat;
        });
      }
    } catch (e) {
      print('사용자 프로필 로딩 오류: $e');
    }
  }

  // 접근 가능한 구역 로드
  Future<void> _loadAccessibleZones() async {
    try {
      final zones = await SeatService.getAccessibleZones();
      if (mounted) {
        setState(() {
          accessibleZones = zones;
          // 접근 가능한 첫 번째 구역을 선택
          if (zones.isNotEmpty && !zones.contains(selectedZone)) {
            selectedZone = zones.first;
          }
        });
      }
    } catch (e) {
      print('접근 가능한 구역 로딩 오류: $e');
      setState(() {
        accessibleZones = ['A', 'B', 'C', 'D']; // 기본값
      });
    }
  }

  // 좌석 데이터 로드
  Future<void> _loadSeatsData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final seats = await SeatService.getSeatsByZone(selectedZone);
      if (mounted) {
        setState(() {
          currentZoneSeats = seats;
          isLoading = false;
        });
      }
    } catch (e) {
      print('좌석 데이터 로딩 오류: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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

  // 백엔드 상태를 프론트엔드 색상으로 변환
  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SILENT':
        return AppTheme.quietColor;
      case 'GOOD':
        return AppTheme.normalColor;
      case 'WARNING':
        return AppTheme.warningColor;
      case 'MY_SEAT':
        return const Color(0xFF5E6198); // 내 좌석 색상
      case 'EMPTY':
      default:
        return Colors.grey;
    }
  }

  // 좌석 클릭 처리 (쪽지 보내기만 가능 - 데모 앱이므로 좌석 배정/해제는 키오스크에서)
  void _handleSeatTap(Map<String, dynamic> seat) {
    final String locationCode = seat['locationCode'];
    final String status = seat['status'];
    final bool accessible = seat['accessible'] ?? true;
    
    if (status == 'MY_SEAT') {
      // 내 좌석인 경우 안내 메시지
      _showInfoDialog('내 좌석', '현재 이용 중인 좌석입니다.\n\n좌석 이동이나 해제는 1층 키오스크에서 가능합니다.');
    } else if (status == 'EMPTY') {
      // 빈 좌석인 경우 안내 메시지
      _showInfoDialog('빈 좌석', '사용 가능한 좌석입니다.\n\n좌석 선택은 1층 키오스크에서 가능합니다.');
    } else if (status != 'EMPTY' && accessible) {
      // 다른 사용자가 사용 중이고 접근 가능하면 쪽지 보내기
      _showSendMessageDialog(locationCode);
    } else if (!accessible) {
      // 접근 불가능한 좌석
      _showAccessDeniedDialog(seat['accessibilityMessage'] ?? '접근할 수 없는 좌석입니다.');
    }
  }

  // 정보 안내 다이얼로그
  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  // 접근 거부 다이얼로그
  void _showAccessDeniedDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('접근 제한'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showSendMessageDialog(String locationCode) {
    _messageController.clear();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$locationCode 좌석에 쪽지 보내기',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      _messageController.clear();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: '조용하게 소통할 내용을 입력하세요...\n예: "펜 빌려주실 수 있나요?", "조용히 해주세요 ㅠㅠ"',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _messageController.clear();
                      Navigator.pop(context);
                    },
                    child: Text(
                      '취소',
                      style: TextStyle(
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final message = _messageController.text.trim();
                      if (message.isNotEmpty) {
                        _messageController.clear();
                        Navigator.pop(context);
                        
                        // TODO: 좌석 ID 기반 쪽지 보내기 API 호출
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$locationCode 좌석에 쪽지를 보냈습니다! 📩'),
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('보내기'),
                  ),
                ],
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
        child: Column(
          children: [
            // 상단 바
            Padding(
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
                          Icons.menu_book,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '좌석 현황',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // 현재 좌석 번호
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentSeatCode ?? '--',
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
            // 키오스크 안내 배너
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '좌석 선택/이동/시간 추가는 키오스크에서 가능합니다',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 스크롤 가능한 본문
            Expanded(
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(scrollbars: true),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 좌석 배치도 이미지 섹션
                        Container(
                          width: double.infinity,
                          height: 300,
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              children: [
                                // 상단 제목 영역
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: AppTheme.primaryColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'shh-tudy 스터디카페 좌석 배치도',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '🔍 좌석을 터치하면 쪽지를 보낼 수 있어요',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.primaryColor.withOpacity(0.8),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // 좌석 배치도 이미지 영역
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    child: Image.asset(
                                      'assets/images/seat_layout.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        // 이미지 로드 실패 시 대체 UI
                                        return Container(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image_not_supported_outlined,
                                                size: 48,
                                                color: AppTheme.textColor.withOpacity(0.5),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                '좌석 배치도를 불러올 수 없습니다',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppTheme.textColor.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 좌석 배치도 현황 섹션
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 헤더
                              Row(
                                children: [
                                  // 구역 선택 콤보박스
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0.5),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentColor,
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: AppTheme.primaryColor,
                                        width: 1,
                                      ),
                                    ),
                                    child: DropdownButton<String>(
                                      value: selectedZone,
                                      items: zones.map((String zone) {
                                        final bool isAccessible = accessibleZones.contains(zone);
                                        return DropdownMenuItem<String>(
                                          value: zone,
                                          child: Text(
                                            '$zone구역${isAccessible ? '' : ' (접근불가)'}',
                                            style: TextStyle(
                                              color: isAccessible 
                                                ? AppTheme.textColor 
                                                : AppTheme.textColor.withOpacity(0.5),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            selectedZone = newValue;
                                          });
                                          _loadSeatsData(); // 구역 변경 시 데이터 새로고침
                                        }
                                      },
                                      underline: Container(),
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: AppTheme.primaryColor,
                                      ),
                                      dropdownColor: AppTheme.accentColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '실시간 현황',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  // 새로고침 버튼
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        _loadSeatsData();
                                        _loadUserProfile();
                                      },
                                      icon: Icon(
                                        Icons.refresh,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Divider(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                thickness: 1,
                              ),
                              const SizedBox(height: 16),
                              // 좌석 그리드
                              isLoading 
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(40.0),
                                      child: CircularProgressIndicator(
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  )
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 5,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 1.5,
                                    ),
                                    itemCount: currentZoneSeats.length,
                                    itemBuilder: (context, index) {
                                      final seat = currentZoneSeats[index];
                                      final bool isAccessible = seat['accessible'] ?? true;
                                      final bool isMyCurrentSeat = seat['locationCode'] == currentSeatCode;
                                      final String status = seat['status'];
                                      
                                      return GestureDetector(
                                        onTap: () => _handleSeatTap(seat),
                                        child: Opacity(
                                          opacity: isAccessible ? 1.0 : 0.5,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: getStatusColor(seat['status']),
                                              borderRadius: BorderRadius.circular(12),
                                              border: isMyCurrentSeat
                                                  ? Border.all(
                                                      color: const Color(0xFF5E6198),
                                                      width: 4,
                                                    )
                                                  : !isAccessible
                                                      ? Border.all(
                                                          color: Colors.red.withOpacity(0.5),
                                                          width: 2,
                                                        )
                                                      : null,
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    seat['locationCode'],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  if (!isAccessible)
                                                    Icon(
                                                      Icons.lock,
                                                      color: Colors.white,
                                                      size: 12,
                                                    ),
                                                  if (status != 'EMPTY' && status != 'MY_SEAT' && isAccessible)
                                                    Icon(
                                                      Icons.email_outlined,
                                                      color: Colors.white,
                                                      size: 10,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              const SizedBox(height: 16),
                              Divider(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                thickness: 1,
                              ),
                              const SizedBox(height: 16),
                              // 범례
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildLegendItem('조용', AppTheme.quietColor),
                                  const SizedBox(width: 16),
                                  _buildLegendItem('양호', AppTheme.normalColor),
                                  const SizedBox(width: 16),
                                  _buildLegendItem('주의', AppTheme.warningColor),
                                  const SizedBox(width: 16),
                                  _buildLegendItem('빈 좌석', Colors.grey),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
} 