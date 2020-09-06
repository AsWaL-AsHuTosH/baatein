import 'package:baatein/chat/chat_forward_screen.dart';
import 'package:baatein/chat/group_forward_screen.dart';
import 'package:baatein/classes/message_info.dart';
import 'package:flutter/material.dart';


class ForwardSelectionScreen extends StatefulWidget {
  final List<MessageInfo> selectedMessage;
  final String from;
  ForwardSelectionScreen({this.selectedMessage, @required this.from});

  @override
  _ForwardSelectionScreenState createState() => _ForwardSelectionScreenState();
}

class _ForwardSelectionScreenState extends State<ForwardSelectionScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forward message'),
        bottom: TabBar(controller: _tabController, tabs: [
          Text('Chats'),
          Text('Groups'),
        ]),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ChatForwardScreen(
            selectedMessage: widget.selectedMessage,
            from: widget.from,
          ),
          GroupForwardScreen(
            selectedMessage: widget.selectedMessage,
            from: widget.from,
          ),
        ],
      ),
    );
  }
}
