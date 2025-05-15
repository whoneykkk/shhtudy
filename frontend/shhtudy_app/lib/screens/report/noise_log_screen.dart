import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'noise_report_screen.dart';
import '../../services/noise_service.dart';
import '../../models/noise_log.dart';

class NoiseLogScreen extends StatefulWidget {
  const NoiseLogScreen({super.key});

  @override
  State<NoiseLogScreen> createState() => _NoiseLogScreenState();
}

class _NoiseLogScreenState extends State<NoiseLogScreen> {
  // 필터 관련 상태
  String _selectedDateFilter = '전체';
  bool _onlyExceeded = false;
  bool _isLoading = true;
  
  // 날짜 필터 옵션
  final List<String> _dateFilters = ['전체', '오늘', '이번 주', '이번 달'];
  
  // 소음 로그 데이터
  List<NoiseLog> _allLogs = [];
  List<NoiseLog> _filteredLogs = [];
  
  @override
  void initState() {
    super.initState();
    _loadNoiseLogData();
  }
  
  // 소음 로그 데이터 로드
  Future<void> _loadNoiseLogData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 소음 로그 데이터 가져오기
      final logs = await NoiseService.getNoiseLogs();
      
      if (!mounted) return;
      
      final noiseLogs = logs.map((log) => NoiseLog.fromJson(log)).toList();
      
      setState(() {
        _allLogs = noiseLogs;
        _applyFilters(); // 필터 적용
        _isLoading = false;
      });
    } catch (e) {
      print('소음 로그 데이터 로드 오류: $e');
      
      if (!mounted) return;
      
      setState(() {
        _allLogs = [];
        _filteredLogs = [];
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('데이터를 불러오는데 실패했습니다. 다시 시도해주세요.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  // 필터 적용
  void _applyFilters() {
    List<NoiseLog> filtered = List.from(_allLogs);
    
    // 날짜 필터 적용
    if (_selectedDateFilter != '전체') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      switch (_selectedDateFilter) {
        case '오늘':
          filtered = filtered.where((log) => 
            log.timestamp.year == today.year && 
            log.timestamp.month == today.month && 
            log.timestamp.day == today.day
          ).toList();
          break;
        case '이번 주':
          // 이번 주 월요일 계산
          final weekDay = now.weekday;
          final monday = today.subtract(Duration(days: weekDay - 1));
          filtered = filtered.where((log) => 
            log.timestamp.isAfter(monday.subtract(const Duration(days: 1)))
          ).toList();
          break;
        case '이번 달':
          // 이번 달 1일 계산
          final firstDayOfMonth = DateTime(now.year, now.month, 1);
          filtered = filtered.where((log) => 
            log.timestamp.isAfter(firstDayOfMonth.subtract(const Duration(days: 1)))
          ).toList();
          break;
      }
    }
    
    // 초과 여부 필터 적용
    if (_onlyExceeded) {
      filtered = filtered.where((log) => log.isExceeded).toList();
    }
    
    // 날짜별로 정렬 (최신순)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    setState(() {
      _filteredLogs = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.accentColor,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 바
            AppBar(
              backgroundColor: AppTheme.accentColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                '소음 로그',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                // 새로고침 버튼
                IconButton(
                  onPressed: _loadNoiseLogData,
                  icon: Icon(
                    Icons.refresh,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  tooltip: '데이터 새로고침',
                ),
              ],
            ),
            
            // 필터 섹션
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 필터
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _dateFilters.map((filter) => _buildFilterChip(
                      filter,
                      _selectedDateFilter == filter,
                      () {
                        setState(() {
                          _selectedDateFilter = filter;
                          _applyFilters();
                        });
                      },
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  // 소음 초과 여부 필터
                  InkWell(
                    onTap: () {
                      setState(() {
                        _onlyExceeded = !_onlyExceeded;
                        _applyFilters();
                      });
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _onlyExceeded,
                            onChanged: (value) {
                              setState(() {
                                _onlyExceeded = value ?? false;
                                _applyFilters();
                              });
                            },
                            activeColor: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '기준 소음 초과 항목만 보기',
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // 로그 목록
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredLogs.isEmpty
                      ? Center(
                          child: Text(
                            '소음 로그가 없습니다.',
                            style: TextStyle(
                              color: AppTheme.textColor.withOpacity(0.6),
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _filteredLogs.length,
                          itemBuilder: (context, index) {
                            final log = _filteredLogs[index];
                            
                            // 날짜 표시 여부 확인 (같은 날짜는 한 번만 표시)
                            bool showDateHeader = index == 0 ||
                                !_isSameDay(log.timestamp, _filteredLogs[index - 1].timestamp);
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showDateHeader) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                                    child: Text(
                                      _formatDateHeader(log.timestamp),
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        offset: const Offset(0, 2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: _buildNoiseLogItemContent(log),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 필터 칩 위젯
  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : AppTheme.accentColor,
              borderRadius: BorderRadius.circular(20),
              border: isSelected ? null : Border.all(
                color: AppTheme.textColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.white : AppTheme.textColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // 소음 로그 아이템 내용
  Widget _buildNoiseLogItemContent(NoiseLog log) {
    // 시간 포맷팅
    final hour = _twoDigits(log.timestamp.hour);
    final minute = _twoDigits(log.timestamp.minute);
    final timeStr = '$hour:$minute';
    
    // 색상 결정
    Color color;
    String statusText;
    
    if (log.level < 40) {
      color = AppTheme.primaryColor;  // 양호
      statusText = '정상';
    } else if (log.level < 50) {
      color = Colors.orange;  // 주의
      statusText = '주의';
    } else {
      color = Colors.red;  // 위험
      statusText = '소음 발생';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              log.level >= 50 ? Icons.volume_up : (log.level >= 40 ? Icons.volume_down : Icons.volume_mute),
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '${log.level} dB',
              style: TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Spacer(),
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
              timeStr,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // 날짜 헤더 포맷
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return '오늘';
    } else if (dateOnly == yesterday) {
      return '어제';
    } else {
      return '${date.year}년 ${date.month}월 ${date.day}일';
    }
  }
  
  // 같은 날짜인지 확인
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  // 숫자를 2자리로 포맷팅 (날짜/시간 표시용)
  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}
