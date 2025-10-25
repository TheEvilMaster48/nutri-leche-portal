class Mensaje {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;

  Mensaje({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Mensaje.fromMap(Map<String, dynamic> map) {
    return Mensaje(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
