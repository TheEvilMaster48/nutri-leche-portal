class Chat {
  final String id;
  final String userId;
  final String userName;
  final String userRole;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isOnline;

  Chat({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    this.lastMessage,
    this.lastMessageTime,
    this.isOnline = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'isOnline': isOnline,
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userRole: json['userRole'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      isOnline: json['isOnline'] ?? false,
    );
  }
}
