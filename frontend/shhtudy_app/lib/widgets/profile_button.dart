import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/mypage/my_page_screen.dart';
import '../services/alert_service.dart';
import 'dart:async';

class ProfileButton extends StatefulWidget {
  final bool hasUnreadAlerts;
  final VoidCallback? onTap;

  const ProfileButton({
    Key? key, 
    required this.hasUnreadAlerts,
    this.onTap,
  }) : super(key: key);

  @override
  State<ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
  bool _hasUnreadAlerts = false;
  StreamSubscription<bool>? _alertSubscription;
  
  @override
  void initState() {
    super.initState();
    _hasUnreadAlerts = widget.hasUnreadAlerts;
    _checkAlertStatus();
    
    // 알림 상태 변화 구독
    _alertSubscription = AlertService.alertStream.listen((hasUnread) {
      if (mounted && hasUnread != _hasUnreadAlerts) {
        setState(() {
          _hasUnreadAlerts = hasUnread;
        });
      }
    });
  }
  
  @override
  void didUpdateWidget(ProfileButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hasUnreadAlerts != widget.hasUnreadAlerts) {
      setState(() {
        _hasUnreadAlerts = widget.hasUnreadAlerts;
      });
    }
  }
  
  // 알림 상태 직접 확인
  Future<void> _checkAlertStatus() async {
    // 서비스를 통해 현재 알림 상태 직접 확인
    final hasUnread = AlertService.hasUnreadAlerts();
    if (mounted && hasUnread != _hasUnreadAlerts) {
      setState(() {
        _hasUnreadAlerts = hasUnread;
      });
    }
  }
  
  @override
  void dispose() {
    // 구독 취소
    _alertSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MyPageScreen(),
          ),
        ).then((_) async {
          // 마이페이지에서 돌아온 후 알림 상태 확인 및 UI 업데이트
          await _checkAlertStatus();
        });
      },
      child: Stack(
        children: [
          Container(
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
          if (_hasUnreadAlerts)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 