import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'noise_report_screen.dart';

class NoiseLogScreen extends StatefulWidget {
  const NoiseLogScreen({super.key});

  @override
  State<NoiseLogScreen> createState() => _NoiseLogScreenState();
}

class _NoiseLogScreenState extends State<NoiseLogScreen> {
  // 필터 관련 상태
  String _selectedDateFilter = '전체';
  String _selectedLevelFilter = '전체';
  bool _onlyExceeded = false;
  
  // 날짜 필터 옵션
  final List<String> _dateFilters = ['전체', '오늘', '이번 주', '이번 달'];
  
  // 레벨 필터 옵션
  final List<String> _levelFilters = ['전체', '30dB 이하', '30-40dB', '40-50dB', '50dB 이상'];
  
  // 소음 로그 임시 데이터 (나중에 DB에서 가져온 데이터로 대체)
  final List<NoiseLog> _allNoiseLogItems = [
    NoiseLog(
      logId: 1,
      userId: 'user123',
      level: 55,
      isExceeded: true,
      timestamp: DateTime(2024, 4, 25, 14, 32),
    ),
    NoiseLog(
      logId: 2,
      userId: 'user123',
      level: 37,
      isExceeded: false,
      timestamp: DateTime(2024, 4, 25, 13, 45),
    ),
    NoiseLog(
      logId: 3,
      userId: 'user123',
      level: 42,
      isExceeded: false,
      timestamp: DateTime(2024, 4, 25, 12, 15),
    ),
    NoiseLog(
      logId: 4,
      userId: 'user123',
      level: 60,
      isExceeded: true,
      timestamp: DateTime(2024, 4, 24, 16, 20),
    ),
    NoiseLog(
      logId: 5,
      userId: 'user123',
      level: 35,
      isExceeded: false,
      timestamp: DateTime(2024, 4, 24, 14, 30),
    ),
    NoiseLog(
      logId: 6,
      userId: 'user123',
      level: 38,
      isExceeded: false,
      timestamp: DateTime(2024, 4, 24, 11, 45),
    ),
    NoiseLog(
      logId: 7,
      userId: 'user123',
      level: 52,
      isExceeded: true,
      timestamp: DateTime(2024, 4, 23, 15, 10),
    ),
    NoiseLog(
      logId: 8,
      userId: 'user123',
      level: 45,
      isExceeded: false,
      timestamp: DateTime(2024, 4, 23, 13, 25),
    ),
    NoiseLog(
      logId: 9,
      userId: 'user123',
      level: 33,
      isExceeded: false,
      timestamp: DateTime(2024, 4, 22, 11, 15),
    ),
    NoiseLog(
      logId: 10,
      userId: 'user123',
      level: 48,
      isExceeded: false,
      timestamp: DateTime(2024, 4, 21, 17, 30),
    ),
    NoiseLog(
      logId: 11,
      userId: 'user123',
      level: 28,
      isExceeded: false,
      timestamp: DateTime(2024, 4, 20, 10, 05),
    ),
    NoiseLog(
      logId: 12,
      userId: 'user123',
      level: 63,
      isExceeded: true,
      timestamp: DateTime(2024, 4, 19, 18, 40),
    ),
  ];
  
  // 필터링된 리스트
  List<NoiseLog> _filteredLogs = [];
  
  @override
  void initState() {
    super.initState();
    _filteredLogs = List.from(_allNoiseLogItems);
    _filteredLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  // 필터 적용 함수
  void _applyFilters() {
    setState(() {
      _filteredLogs = _allNoiseLogItems.where((log) {
        // 초과 여부 필터
        if (_onlyExceeded && !log.isExceeded) {
          return false;
        }
        
        // 날짜 필터
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final logDate = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
        
        if (_selectedDateFilter == '오늘') {
          if (logDate != today) {
            return false;
          }
        } else if (_selectedDateFilter == '이번 주') {
          // 이번 주의 첫날 (월요일) 계산
          final firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
          if (logDate.isBefore(firstDayOfWeek)) {
            return false;
          }
        } else if (_selectedDateFilter == '이번 달') {
          final firstDayOfMonth = DateTime(now.year, now.month, 1);
          if (logDate.isBefore(firstDayOfMonth)) {
            return false;
          }
        }
        
        // 레벨 필터
        if (_selectedLevelFilter == '30dB 이하') {
          if (log.level > 30) {
            return false;
          }
        } else if (_selectedLevelFilter == '30-40dB') {
          if (log.level < 30 || log.level > 40) {
            return false;
          }
        } else if (_selectedLevelFilter == '40-50dB') {
          if (log.level < 40 || log.level > 50) {
            return false;
          }
        } else if (_selectedLevelFilter == '50dB 이상') {
          if (log.level < 50) {
            return false;
          }
        }
        
        return true;
      }).toList();
      
      // 최신순 정렬
      _filteredLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }
  
  // 필터 초기화
  void _resetFilters() {
    setState(() {
      _selectedDateFilter = '전체';
      _selectedLevelFilter = '전체';
      _onlyExceeded = false;
      _filteredLogs = List.from(_allNoiseLogItems);
      _filteredLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.accentColor,
      appBar: AppBar(
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
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: AppTheme.primaryColor,
            ),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 필터 표시 영역
          if (_selectedDateFilter != '전체' || _selectedLevelFilter != '전체' || _onlyExceeded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.accentColor,
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (_selectedDateFilter != '전체')
                          _buildFilterChip(_selectedDateFilter),
                        if (_selectedLevelFilter != '전체')
                          _buildFilterChip(_selectedLevelFilter),
                        if (_onlyExceeded)
                          _buildFilterChip('기준 초과만'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _resetFilters();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text('초기화'),
                  ),
                ],
              ),
            ),
          
          // 로그 목록
          Expanded(
            child: _filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.podcasts,
                          size: 64,
                          color: AppTheme.textColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '소음 로그가 없습니다',
                          style: TextStyle(
                            color: AppTheme.textColor.withOpacity(0.5),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredLogs.length,
                    itemBuilder: (context, index) {
                      final item = _filteredLogs[index];
                      
                      // 날짜 헤더 표시 여부 결정
                      final bool showDateHeader = index == 0 || 
                          !_isSameDay(item.timestamp, _filteredLogs[index - 1].timestamp);
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDateHeader) ...[
                            if (index > 0) const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.only(left: 8, bottom: 8),
                              child: Text(
                                _formatDateHeader(item.timestamp),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                          _buildNoiseLogCard(item),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  // 필터 다이얼로그 표시
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '필터 설정',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 날짜 필터
                  const Text(
                    '날짜',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _dateFilters.map((filter) {
                      return ChoiceChip(
                        label: Text(filter),
                        selected: _selectedDateFilter == filter,
                        onSelected: (selected) {
                          if (selected) {
                            setDialogState(() {
                              _selectedDateFilter = filter;
                            });
                          }
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        backgroundColor: AppTheme.accentColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // 레벨 필터
                  const Text(
                    '소음 레벨',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _levelFilters.map((filter) {
                      return ChoiceChip(
                        label: Text(filter),
                        selected: _selectedLevelFilter == filter,
                        onSelected: (selected) {
                          if (selected) {
                            setDialogState(() {
                              _selectedLevelFilter = filter;
                            });
                          }
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        backgroundColor: AppTheme.accentColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // 초과 여부 필터
                  Row(
                    children: [
                      Checkbox(
                        value: _onlyExceeded,
                        onChanged: (value) {
                          setDialogState(() {
                            _onlyExceeded = value ?? false;
                          });
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                      const Text(
                        '기준 소음 초과한 로그만 보기',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setDialogState(() {
                            _selectedDateFilter = '전체';
                            _selectedLevelFilter = '전체';
                            _onlyExceeded = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.textColor,
                        ),
                        child: const Text('초기화'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _applyFilters();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('적용'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  // 필터 칩 위젯
  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  // 소음 로그 카드 위젯
  Widget _buildNoiseLogCard(NoiseLog item) {
    final bool isExceeded = item.isExceeded;
    final Color statusColor = isExceeded ? Colors.red : AppTheme.primaryColor;
    final String statusText = isExceeded ? '기준 소음 초과' : '기준 소음 이하';
    
    // 날짜 및 시간 포맷팅
    final String formattedTime = '${_twoDigits(item.timestamp.hour)}:${_twoDigits(item.timestamp.minute)}';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 상태 표시 원
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor,
              ),
            ),
            const SizedBox(width: 12),
            // 소음 레벨
            Text(
              '평균 ${item.level}dB',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
              ),
            ),
            const SizedBox(width: 6),
            // 상태 텍스트
            Text(
              '| $statusText',
              style: TextStyle(
                fontSize: 14,
                color: isExceeded ? Colors.red : AppTheme.textColor,
              ),
            ),
            const Spacer(),
            // 시간
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
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

// 소음 로그 모델 클래스 - 데이터베이스 테이블과 매핑
class NoiseLog {
  final int logId;         // 로그 ID (PK)
  final String userId;     // 사용자 ID (FK)
  final int level;         // 소음 레벨 (dB)
  final bool isExceeded;   // 기준 소음 초과 여부
  final DateTime timestamp; // 측정 시간

  NoiseLog({
    required this.logId,
    required this.userId,
    required this.level,
    required this.isExceeded,
    required this.timestamp,
  });
  
  // JSON 데이터로부터 객체 생성 (API 응답 처리용)
  factory NoiseLog.fromJson(Map<String, dynamic> json) {
    return NoiseLog(
      logId: json['log_id'],
      userId: json['user_id'],
      level: json['level'],
      isExceeded: json['is_exceeded'] == 1,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
  
  // 객체를 JSON 데이터로 변환 (API 요청 처리용)
  Map<String, dynamic> toJson() {
    return {
      'log_id': logId,
      'user_id': userId,
      'level': level,
      'is_exceeded': isExceeded ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 