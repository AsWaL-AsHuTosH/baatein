class MessageInfo {
  final DateTime time;
  final String message;
  final String type;
  final String url;
  final String imageName;
  MessageInfo({this.message, this.time, this.type, this.url, this.imageName});
}

Comparator<MessageInfo> comp = (a, b) => a.time.compareTo(b.time);
