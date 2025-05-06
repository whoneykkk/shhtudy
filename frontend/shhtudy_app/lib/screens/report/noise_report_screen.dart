import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../mypage/my_page_screen.dart';
import 'noise_log_screen.dart';

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
    '주간 소음 추이 Line/Bar Chart',
    '좌석별 소음 비율 Bar Chart',
  ];

  // 소음 로그 임시 데이터 (나중에 DB에서 가져온 데이터로 대체)
  final List<NoiseLogItem> _noiseLogItems = [
    NoiseLogItem(
      level: 55,
      isExceeded: true,
      timestamp: DateTime(2024, 4, 25, 14, 32),
    ),
    NoiseLogItem(
      level: 37,
      isExceeded: false,
      timestamp: DateTime(2024, 4, 25, 13, 45),
    ),
    NoiseLogItem(
      level: 42,
      isExceeded: false,
      timestamp: DateTime(2024, 4, 25, 12, 15),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: API로 데이터 가져오기
    String? currentSeatCode = '--';
    String? grade = 'B';
    double? averageDecibel = 42.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
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
            ),
            // 등급 및 데시벨 정보
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // 현재 등급
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                            grade ?? '--',
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
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                                averageDecibel?.toStringAsFixed(0) ?? '--',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 2, bottom: 4),
                                child: Text(
                                  'db',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textColor.withOpacity(0.6),
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
                    // 차트 섹션 (슬라이드 가능)
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 차트 타입 표시
                          Text(
                            _chartTypes[_currentPageIndex],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const SizedBox(height: 16),
                          // 차트 슬라이더
                          SizedBox(
                            height: 200,
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPageIndex = index;
                                });
                              },
                              children: [
                                // 일간 소음 변동 Line Chart
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _buildDailyNoiseLineChart(),
                                ),
                                // 주간 소음 추이 Bar Chart
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _buildWeeklyNoiseBarChart(),
                                ),
                                // 좌석별 소음 비율 Bar Chart
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _buildSeatNoiseBarChart(),
                                ),
                              ],
                            ),
                          ),
                          // 페이지 인디케이터
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _chartTypes.length,
                              (index) => Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index == _currentPageIndex 
                                      ? AppTheme.primaryColor 
                                      : AppTheme.primaryColor.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 소음 로그 섹션 (카드 형식)
                    Container(
                      width: double.infinity,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Text(
                                  '소음 로그',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textColor,
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
                          ),
                          // 소음 로그 카드 리스트
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _noiseLogItems.length,
                            itemBuilder: (context, index) {
                              final item = _noiseLogItems[index];
                              return _buildNoiseLogCard(item);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 최저 비율 및 종합 퍼센트
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '좌석 비교 및 종합 피드백',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // 최고 데시벨 및 초과 횟수
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.warningColor.withOpacity(0.2),
                                  ),
                                  child: Icon(
                                    Icons.volume_up,
                                    color: AppTheme.warningColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '최고 63dB',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textColor,
                                      ),
                                    ),
                                    Text(
                                      '기준 소음 초과 5회',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 소음 비율 정보
                          Row(
                            children: [
                              // 내 소음 비율
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '내 소음 비율',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textColor.withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: AppTheme.primaryColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '82%',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // 전체 평균 소음 비율
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '전체 평균 소음 비율',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textColor.withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.groups,
                                            color: AppTheme.textColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '79%',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textColor,
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
                          const SizedBox(height: 20),
                          // 오늘의 피드백
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      color: AppTheme.primaryColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '오늘의 피드백',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _getFeedbackMessage(82), // 소음 비율에 따른 메시지 출력
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textColor,
                                    height: 1.4,
                                  ),
                                ),
                              ],
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
  Widget _buildNoiseLogCard(NoiseLogItem item) {
    final bool isExceeded = item.isExceeded;
    final Color statusColor = isExceeded ? Colors.red : AppTheme.primaryColor;
    final String statusText = isExceeded ? '기준 소음 초과' : '기준 소음 이하';
    
    // 날짜 및 시간 포맷팅
    final String formattedDate = '${item.timestamp.year}/${_twoDigits(item.timestamp.month)}/${_twoDigits(item.timestamp.day)}';
    final String formattedTime = '${_twoDigits(item.timestamp.hour)}:${_twoDigits(item.timestamp.minute)}';
    
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
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
        padding: const EdgeInsets.all(12),
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
            // 정보 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '평균 ${item.level}dB',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '| $statusText',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 날짜 및 시간
            Text(
              '$formattedDate | $formattedTime',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 숫자를 2자리로 포맷팅 (날짜/시간 표시용)
  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  // 소음 비율에 따른 피드백 메시지
  String _getFeedbackMessage(int quietnessPercent) {
    if (quietnessPercent >= 80) {
      return '집중하기 딱 좋은 하루였어요. 멋진 분위기, 최고예요!';
    } else if (quietnessPercent >= 60) {
      return '좋은 하루였어요. 모두의 작은 배려로 더 좋은 공간이 될 수 있어요!';
    } else {
      return '때로는 소란스러울 때도 있죠. 모두 함께 더 좋은 공간을 만들어가요!';
    }
  }

  // 일간 소음 변동 Line Chart 위젯
  Widget _buildDailyNoiseLineChart() {
    // 임시 데이터
    List<FlSpot> spots = [
      FlSpot(0, 42),  // 08:00, 42dB
      FlSpot(1, 38),  // 09:00, 38dB
      FlSpot(2, 45),  // 10:00, 45dB
      FlSpot(3, 55),  // 11:00, 55dB
      FlSpot(4, 50),  // 12:00, 50dB
      FlSpot(5, 43),  // 13:00, 43dB
      FlSpot(6, 47),  // 14:00, 47dB
      FlSpot(7, 41),  // 15:00, 41dB
      FlSpot(8, 36),  // 16:00, 36dB
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 10,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.accentColor,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AppTheme.accentColor,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const style = TextStyle(
                  color: Color(0xff68737d),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = '08';
                    break;
                  case 1:
                    text = '09';
                    break;
                  case 2:
                    text = '10';
                    break;
                  case 3:
                    text = '11';
                    break;
                  case 4:
                    text = '12';
                    break;
                  case 5:
                    text = '13';
                    break;
                  case 6:
                    text = '14';
                    break;
                  case 7:
                    text = '15';
                    break;
                  case 8:
                    text = '16';
                    break;
                  default:
                    text = '';
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(text, style: style),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}dB',
                  style: const TextStyle(
                    color: Color(0xff68737d),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.left,
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: 8,
        minY: 30,
        maxY: 60,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.8),
                AppTheme.primaryColor,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: true,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.2),
                  AppTheme.primaryColor.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 주간 소음 추이 Bar Chart 위젯
  Widget _buildWeeklyNoiseBarChart() {
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.grey.shade200,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = ['월', '화', '수', '목', '금', '토', '일'][group.x.toInt()];
              return BarTooltipItem(
                '$day\n${rod.toY.toInt()}dB',
                const TextStyle(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final style = TextStyle(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = '월';
                    break;
                  case 1:
                    text = '화';
                    break;
                  case 2:
                    text = '수';
                    break;
                  case 3:
                    text = '목';
                    break;
                  case 4:
                    text = '금';
                    break;
                  case 5:
                    text = '토';
                    break;
                  case 6:
                    text = '일';
                    break;
                  default:
                    text = '';
                    break;
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(text, style: style),
                );
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 10,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: 45,
                gradient: _getBarGradient(45),
                borderRadius: BorderRadius.circular(4),
                width: 20,
              )
            ],
            showingTooltipIndicators: [0],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: 38,
                gradient: _getBarGradient(38),
                borderRadius: BorderRadius.circular(4),
                width: 20,
              )
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: 52,
                gradient: _getBarGradient(52),
                borderRadius: BorderRadius.circular(4),
                width: 20,
              )
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                toY: 41,
                gradient: _getBarGradient(41),
                borderRadius: BorderRadius.circular(4),
                width: 20,
              )
            ],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [
              BarChartRodData(
                toY: 47,
                gradient: _getBarGradient(47),
                borderRadius: BorderRadius.circular(4),
                width: 20,
              )
            ],
          ),
          BarChartGroupData(
            x: 5,
            barRods: [
              BarChartRodData(
                toY: 35,
                gradient: _getBarGradient(35),
                borderRadius: BorderRadius.circular(4),
                width: 20,
              )
            ],
          ),
          BarChartGroupData(
            x: 6,
            barRods: [
              BarChartRodData(
                toY: 30,
                gradient: _getBarGradient(30),
                borderRadius: BorderRadius.circular(4),
                width: 20,
              )
            ],
          ),
        ],
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
        ),
        alignment: BarChartAlignment.spaceAround,
        maxY: 60,
      ),
    );
  }

  // 좌석별 소음 비율 Bar Chart 위젯
  Widget _buildSeatNoiseBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.grey.shade200,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final seatList = ['A-1', 'A-2', 'B-1', 'B-2', '내 좌석'];
              return BarTooltipItem(
                '${seatList[group.x.toInt()]}\n${rod.toY.toInt()}%',
                const TextStyle(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final style = TextStyle(
                  color: value == 4 ? AppTheme.primaryColor : AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                );
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'A-1';
                    break;
                  case 1:
                    text = 'A-2';
                    break;
                  case 2:
                    text = 'B-1';
                    break;
                  case 3:
                    text = 'B-2';
                    break;
                  case 4:
                    text = '내 좌석';
                    break;
                  default:
                    text = '';
                    break;
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(text, style: style),
                );
              },
              reservedSize: 25,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: 72,
                color: AppTheme.textColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
                width: 20,
              )
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: 65,
                color: AppTheme.textColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
                width: 20,
              )
            ],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [
              BarChartRodData(
                toY: 85,
                color: AppTheme.textColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
                width: 20,
              )
            ],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [
              BarChartRodData(
                toY: 70,
                color: AppTheme.textColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
                width: 20,
              )
            ],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [
              BarChartRodData(
                toY: 82,
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(4),
                width: 20,
              )
            ],
            showingTooltipIndicators: [0],
          ),
        ],
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
        ),
        maxY: 100,
      ),
    );
  }

  // 바 차트에 사용되는 그라데이션 생성
  LinearGradient _getBarGradient(double value) {
    Color color;
    if (value < 40) {
      color = AppTheme.quietColor;  // 조용
    } else if (value < 50) {
      color = AppTheme.primaryColor;  // 양호
    } else {
      color = AppTheme.warningColor;  // 주의
    }
    
    return LinearGradient(
      colors: [
        color.withOpacity(0.7),
        color,
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
  }
}

// 소음 로그 아이템 데이터 클래스
class NoiseLogItem {
  final int level; // 소음 레벨 (dB)
  final bool isExceeded; // 기준 소음 초과 여부
  final DateTime timestamp; // 측정 시간

  NoiseLogItem({
    required this.level,
    required this.isExceeded,
    required this.timestamp,
  });
  
  // DB에서 데이터를 받아와 객체를 생성하는 팩토리 메소드 (나중에 구현)
  factory NoiseLogItem.fromJson(Map<String, dynamic> json) {
    return NoiseLogItem(
      level: json['level'],
      isExceeded: json['is_exceeded'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
} 