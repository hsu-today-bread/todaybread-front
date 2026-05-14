import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todaybread/models/notification/app_notification.dart';
import 'package:todaybread/providers/login/login_provider.dart';
import 'package:todaybread/screens/boss/boss_order_history_screen.dart';
import 'package:todaybread/screens/bread/bread_detail_screen.dart';
import 'package:todaybread/screens/store/store_detail_screen.dart';
import 'package:todaybread/services/local/notification_local_store.dart';
import 'package:todaybread/utils/app_colors.dart';

class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final isBoss = context.read<AuthProvider>().isBoss;
    setState(() {
      _notifications = NotificationLocalStore.getNotifications()
          .where((n) => isBoss || n.data['type'] != 'ORDER_CREATED')
          .toList();
    });
  }

  Future<void> _openNotification(AppNotification notification) async {
    await NotificationLocalStore.markRead(notification.id);
    if (!mounted) {
      return;
    }
    _load();

    final type = notification.data['type'];
    final isBoss = context.read<AuthProvider>().isBoss;
    switch (type) {
      case 'ORDER_CREATED':
        if (!isBoss) return;
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BossOrderHistoryScreen()),
        );
      case 'KEYWORD_STOCK':
      case 'FAVORITE_STORE_STOCK':
        final storeId = int.tryParse(notification.data['storeId'] ?? '');
        final breadId = int.tryParse(notification.data['breadId'] ?? '');
        if (storeId == null) {
          return;
        }
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => breadId == null
                ? StoreDetailScreen(storeId: storeId)
                : BreadDetailScreen(
                    breadId: breadId,
                    storeId: storeId,
                    fallbackToStoreOnLoadFailure: true,
                  ),
          ),
        );
      default:
        return;
    }
  }

  Future<void> _deleteNotification(AppNotification notification) async {
    await NotificationLocalStore.delete(notification.id);
    if (!mounted) {
      return;
    }
    _load();
  }

  Future<void> _clearAll() async {
    await NotificationLocalStore.clear();
    if (!mounted) {
      return;
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
        ),
        title: const Text(
          '알림',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text(
                '전체 삭제',
                style: TextStyle(
                  color: AppColors.primaryBackground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _notifications.isEmpty
            ? const Center(
                child: Text(
                  '도착한 알림이 없습니다.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8A8A8A),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: _notifications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return _NotificationTile(
                    notification: notification,
                    onTap: () => _openNotification(notification),
                    onDelete: () => _deleteNotification(notification),
                  );
                },
              ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.isRead ? Colors.white : const Color(0xFFF4FBF9),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE6E6E6)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconFor(notification.data['type']),
                  color: AppColors.primaryBackground,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF171717),
                      ),
                    ),
                    if (notification.body.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF656565),
                        ),
                      ),
                    ],
                    const SizedBox(height: 7),
                    Text(
                      _formatTime(notification.receivedAt),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9A9A9A),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close_rounded, color: Color(0xFF9A9A9A)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String? type) {
    return switch (type) {
      'ORDER_CREATED' => Icons.receipt_long_rounded,
      'KEYWORD_STOCK' => Icons.notifications_active_rounded,
      'FAVORITE_STORE_STOCK' => Icons.favorite_rounded,
      _ => Icons.notifications_rounded,
    };
  }

  String _formatTime(DateTime value) {
    final now = DateTime.now();
    final diff = now.difference(value);
    if (diff.inMinutes < 1) {
      return '방금 전';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes}분 전';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours}시간 전';
    }
    return '${value.month}월 ${value.day}일';
  }
}
