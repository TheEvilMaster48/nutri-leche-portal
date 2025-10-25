class Chat {
  final String id;
  final String userName;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  Chat({
    required this.id,
    required this.userName,
    this.lastMessage,
    this.lastMessageTime,
  });

  Chat copyWith({
    String? id,
    String? userName,
    String? lastMessage,
    DateTime? lastMessageTime,
  }) {
    return Chat(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] ?? '',
      userName: map['userName'] ?? '',
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.tryParse(map['lastMessageTime'])
          : null,
    );
  }
}
