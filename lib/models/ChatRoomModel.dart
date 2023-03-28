class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;
  String? lastMessageSendBy;
  int? unreadMessageCount;
  DateTime? lasttime;

  ChatRoomModel(
      {this.chatroomid,
      this.participants,
      this.lastMessage,
      this.lasttime,
      this.lastMessageSendBy,
      this.unreadMessageCount});

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastMessage = map["lastmessage"];
    lasttime = map["lasttime"].toDate();
    lastMessageSendBy = map["lastmessagesendby"];
    unreadMessageCount = map["unreadmessagecount"];
  }

  ChatRoomModel copyWith({
    String? chatroomid,
    Map<String, dynamic>? participants,
    String? lastMessage,
    DateTime? lasttime,
    String? lastMessageSendBy,
    int? unreadMessageCount,
  }) {
    return ChatRoomModel(
       chatroomid: chatroomid ?? this.chatroomid,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lasttime: lasttime ?? this.lasttime,
      lastMessageSendBy: lastMessageSendBy ?? this.lastMessageSendBy,
      unreadMessageCount: unreadMessageCount ?? this.unreadMessageCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "chatroomid": chatroomid,
      "participants": participants,
      "lastmessage": lastMessage,
      "lasttime": lasttime,
      "lastmessagesendby": lastMessageSendBy,
      "unreadmessagecount": unreadMessageCount,
    };
  }
}
