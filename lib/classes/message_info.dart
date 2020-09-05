class MessageInfo{
  final DateTime time;
  final String message;
  final String type;
  final String url;
  MessageInfo({this.message, this.time, this.type, this.url});
}

Comparator<MessageInfo> comp = (a, b) => a.time.compareTo(b.time);