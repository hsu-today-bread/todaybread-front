class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.receivedAt,
    required this.isRead,
  });

  final String id;
  final String title;
  final String body;
  final Map<String, String> data;
  final DateTime receivedAt;
  final bool isRead;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      data: data,
      receivedAt: receivedAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'receivedAt': receivedAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory AppNotification.fromJson(Map<dynamic, dynamic> json) {
    final rawData = json['data'];
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '오늘의 빵 알림',
      body: json['body']?.toString() ?? '',
      data: rawData is Map
          ? rawData.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : const {},
      receivedAt:
          DateTime.tryParse(json['receivedAt']?.toString() ?? '') ??
          DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
