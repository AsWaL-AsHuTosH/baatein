class TimeMessagePair{
  final DateTime time;
  final String message;
  TimeMessagePair({this.message, this.time});
}

Comparator<TimeMessagePair> comp = (a, b) => a.time.compareTo(b.time);