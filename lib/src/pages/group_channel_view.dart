import 'package:assignment2/src/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class GroupChannelView extends StatefulWidget {
  final GroupChannel groupChannel;
  const GroupChannelView({Key? key, required this.groupChannel})
      : super(key: key);

  @override
  _GroupChannelViewState createState() => _GroupChannelViewState();
}

class _GroupChannelViewState extends State<GroupChannelView>
    with ChannelEventHandler {
  List<BaseMessage> _messages = [];
  bool isTextFieldNotEmpty = false;
  double keyboardHeight = 0.0;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getMessages(widget.groupChannel);
    SendbirdSdk().addChannelEventHandler(widget.groupChannel.channelUrl, this);
    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (visible) {
        setState(() {
          keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        });
      } else {
        setState(() {
          keyboardHeight = 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    SendbirdSdk().removeChannelEventHandler(widget.groupChannel.channelUrl);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  onMessageReceived(channel, message) {
    setState(() {
      _messages.add(message);
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> getMessages(GroupChannel channel) async {
    try {
      List<BaseMessage> messages = await channel.getMessagesByTimestamp(
          DateTime.now().millisecondsSinceEpoch * 1000, MessageListParams());
      setState(() {
        _messages = messages;
        _scrollToBottom();
      });
    } catch (e) {
      print('group_channel_view.dart: getMessages: ERROR: $e');
    }
  }

  Future<void> sendMessage(String messageText) async {
    UserMessageParams params = UserMessageParams(message: messageText);
    UserMessage message = await widget.groupChannel.sendUserMessage(params);
    setState(() {
      _messages.add(message);
      _scrollToBottom();
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          'Channels',
          textAlign: TextAlign.left,
          style: TextStyle(
              color: whiteColor, fontSize: 20, fontWeight: FontWeight.w300),
        ),
        actions: [
          Container(
            width: 60,
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create_channel');
              },
              icon: const Icon(Icons.menu),
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 5, 5, 5),
        child: body(context),
      ),
    );
  }

  String timeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }

  Widget body(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - keyboardHeight,
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUserMessage =
                    message.sender!.userId == SendbirdSdk().currentUser!.userId;
                return Flexible(
                  fit: FlexFit.loose,
                  child: Row(
                    mainAxisAlignment: isUserMessage
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      isUserMessage
                          ? Container(
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 5, right: 20, left: 15),
                              margin: const EdgeInsets.only(
                                  bottom: 5, right: 10, left: 10),
                              decoration: const BoxDecoration(
                                  color: Color(0xFFFF4693),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30),
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(8),
                                  )),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: isUserMessage
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Text(
                                      message.message,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.only(top: 8, left: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: message
                                                    .sender!.profileUrl !=
                                                null
                                            ? const NetworkImage(
                                                "https://banner2.cleanpng.com/20181231/fta/kisspng-computer-icons-user-profile-portable-network-graph-circle-svg-png-icon-free-download-5-4714-onli-5c2a3809d6e8e6.1821006915462707298803.jpg")
                                            : NetworkImage(
                                                message.sender!.profileUrl!),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 5,
                                            right: 20,
                                            left: 20),
                                        margin: const EdgeInsets.only(
                                            bottom: 4, right: 10, left: 10),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF1A1A1A),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                            topLeft: Radius.circular(5),
                                            topRight: Radius.circular(20),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      message.sender!.userId,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color:
                                                            Color(0xFFADADAD),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    message.isPinnedMessage ==
                                                            false
                                                        ? Container(
                                                            height: 5,
                                                            width: 5,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFF46F9F5),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                          )
                                                        : Container()
                                                  ],
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    message.message,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Color(0xFFFFFFFF),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    timeAgo(DateTime.fromMillisecondsSinceEpoch(
                                        message.createdAt)),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: Color(0xFF9C9CA3),
                                    ),
                                  )
                                ],
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
          ),
          _bottomWidget(context)
        ],
      ),
    );
  }

  Widget _bottomWidget(context) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      color: const Color(0xff131313),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.all(8),
            child: IconButton(
              icon: const Icon(
                Icons.add,
                size: 30,
              ),
              color: Colors.white,
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  sendMessage(_messageController.text);
                }
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(25.0),
              border: Border.all(
                color: const Color(0xFF323232),
              ),
            ),
            width: MediaQuery.of(context).size.width - 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18, right: 8),
                    child: TextField(
                      controller: _messageController,
                      onChanged: (value) {
                        setState(() {
                          isTextFieldNotEmpty =
                              value.isNotEmpty; // Update the flag
                        });
                      },
                      decoration: const InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: "Type a message here...",
                        hintStyle: TextStyle(color: Color(0xFF666666)),
                        contentPadding: EdgeInsets.only(
                          left: 18,
                          top: 10,
                          bottom: 10,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(left: 8, right: 12),
                  decoration: BoxDecoration(
                    color: isTextFieldNotEmpty
                        ? const Color(0xFFFF006A)
                        : const Color(0xFF3A3A3A),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_upward,
                        size: 15,
                      ),
                      color: isTextFieldNotEmpty
                          ? const Color(0xFF000000)
                          : const Color(0xFF1A1A1A),
                      onPressed: () {
                        if (_messageController.text.isNotEmpty) {
                          sendMessage(_messageController.text);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
    );
  }
}
