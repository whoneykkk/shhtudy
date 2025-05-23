import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../mypage/my_page_screen.dart';
import '../../services/alert_service.dart';
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
  String selectedZone = 'A구역';
  final List<String> zones = ['A구역', 'B구역', 'C구역', 'D구역'];
  final TextEditingController _messageController = TextEditingController();
  bool hasUnreadAlerts = false; // 읽지 않은 알림 여부

  // 구역별 임시 좌석 데이터
  final Map<String, List<SeatInfo>> zoneSeats = {
    'A구역': [
      SeatInfo(code: 'a-1', status: SeatStatus.empty),
      SeatInfo(code: 'a-2', status: SeatStatus.quiet),
      SeatInfo(code: 'a-3', status: SeatStatus.normal),
      SeatInfo(code: 'a-4', status: SeatStatus.warning),
      SeatInfo(code: 'a-5', status: SeatStatus.quiet),
    ],
    'B구역': [
      SeatInfo(code: 'b-1', status: SeatStatus.empty),
      SeatInfo(code: 'b-2', status: SeatStatus.quiet),
      SeatInfo(code: 'b-3', status: SeatStatus.normal),
      SeatInfo(code: 'b-4', status: SeatStatus.warning),
      SeatInfo(code: 'b-5', status: SeatStatus.quiet),
      SeatInfo(code: 'b-6', status: SeatStatus.normal, isMine: true),
    ],
    'C구역': [
      SeatInfo(code: 'c-1', status: SeatStatus.empty),
      SeatInfo(code: 'c-2', status: SeatStatus.quiet),
      SeatInfo(code: 'c-3', status: SeatStatus.normal),
      SeatInfo(code: 'c-4', status: SeatStatus.warning),
      SeatInfo(code: 'c-5', status: SeatStatus.quiet),
      SeatInfo(code: 'c-6', status: SeatStatus.normal),
      SeatInfo(code: 'c-7', status: SeatStatus.warning),
    ],
    'D구역': [
      SeatInfo(code: 'd-1', status: SeatStatus.empty),
      SeatInfo(code: 'd-2', status: SeatStatus.quiet),
      SeatInfo(code: 'd-3', status: SeatStatus.normal),
      SeatInfo(code: 'd-4', status: SeatStatus.warning),
      SeatInfo(code: 'd-5', status: SeatStatus.quiet),
      SeatInfo(code: 'd-6', status: SeatStatus.normal),
      SeatInfo(code: 'd-7', status: SeatStatus.warning),
      SeatInfo(code: 'd-8', status: SeatStatus.empty),
    ],
  };

  @override
  void initState() {
    super.initState();
    _checkUnreadAlerts(); // 읽지 않은 알림 확인
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

  Color getStatusColor(SeatStatus status) {
    switch (status) {
      case SeatStatus.quiet:
        return AppTheme.quietColor;
      case SeatStatus.normal:
        return AppTheme.normalColor;
      case SeatStatus.warning:
        return AppTheme.warningColor;
      case SeatStatus.empty:
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showSendMessageDialog(SeatInfo seat) {
    // 빈 좌석이거나 내 좌석이면 모달을 띄우지 않음
    if (seat.status == SeatStatus.empty || seat.isMine) return;
    
    // 텍스트 필드 초기화
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
                    '${seat.code} 좌석에 쪽지 보내기',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      _messageController.clear();  // X 버튼으로 닫을 때도 초기화
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
                    hintText: '메시지를 입력하세요...',
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
                      _messageController.clear();  // 취소 버튼으로 닫을 때도 초기화
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
                    onPressed: () {
                      // TODO: 쪽지 보내기 API 호출
                      String message = _messageController.text;
                      _messageController.clear();
                      Navigator.pop(context);
                      // 성공 스낵바 표시
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${seat.code} 좌석에 쪽지를 보냈습니다.'),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                      );
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
    final currentZoneSeats = zoneSeats[selectedZone] ?? [];
    final rowCount = (currentZoneSeats.length / 5).ceil();

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
                  // 프로필 버튼 (새 위젯으로 교체)
                  ProfileButton(
                    hasUnreadAlerts: hasUnreadAlerts,
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const MyPageScreen())
                      ).then((_) {
                        // 마이페이지에서 돌아오면 알림 상태 다시 확인
                        _checkUnreadAlerts();
                      });
                    },
                  ),
                ],
              ),
            ),
            // 스크롤 가능한 본문
            Expanded(
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(scrollbars: true),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 좌석 배치도 이미지 섹션
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/seat_layout.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 좌석 배치도 현황 섹션
                        Container(
                          width: double.infinity,
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
                                        return DropdownMenuItem<String>(
                                          value: zone,
                                          child: Text(
                                            zone,
                                            style: TextStyle(
                                              color: AppTheme.textColor,
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
                                    '좌석 배치도',
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
                                        // TODO: 새로고침 기능 구현
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
                              GridView.builder(
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
                                  return GestureDetector(
                                    onTap: seat.status != SeatStatus.empty && !seat.isMine 
                                        ? () => _showSendMessageDialog(seat)
                                        : null,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: getStatusColor(seat.status),
                                        borderRadius: BorderRadius.circular(12),
                                        border: seat.isMine
                                            ? Border.all(
                                                color: const Color(0xFF5E6198),
                                                width: 4,
                                              )
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          seat.code,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
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