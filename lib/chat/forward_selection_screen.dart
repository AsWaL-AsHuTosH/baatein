import 'package:baatein/chat/chat_forward_screen.dart';
import 'package:baatein/chat/group_forward_screen.dart';
import 'package:baatein/helper/message_info.dart';
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
        title: Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Text('Forward message', style: TextStyle(fontSize: 20),),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Chats'),
            Tab(text: 'Groups'),
          ],
        ),
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
