import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

class OpenChannelPage extends StatefulWidget {
  const OpenChannelPage({Key? key}) : super(key: key);

  @override
  State<OpenChannelPage> createState() => OpenChannelPageState();
}

class OpenChannelPageState extends State<OpenChannelPage> {
  final channelUrl = Get.parameters['channel_url']!;
  final itemScrollController = ItemScrollController();
  final textEditingController = TextEditingController();
  late PreviousMessageListQuery query;

  final String userId = SendbirdChat.currentUser?.userId ?? '';

  String title = '';
  bool hasPrevious = false;
  List<BaseMessage> messageList = [];
  int? participantCount;

  OpenChannel? openChannel;

  @override
  void initState() {
    super.initState();
    SendbirdChat.addChannelHandler('OpenChannel', MyOpenChannelHandler(this));
    SendbirdChat.addConnectionHandler('OpenChannel', MyConnectionHandler(this));

    OpenChannel.getChannel(channelUrl).then((openChannel) {
      this.openChannel = openChannel;
      openChannel.enter().then((_) => _initialize());
    });
  }

  void _initialize() {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      query = PreviousMessageListQuery(
        channelType: ChannelType.open,
        channelUrl: channelUrl,
      )..next().then((messages) {
          setState(() {
            messageList
              ..clear()
              ..addAll(messages);
            title = '${openChannel.name} (${messageList.length})';
            hasPrevious = query.hasNext;
            participantCount = openChannel.participantCount;
          });
        });
    });
  }

  @override
  void dispose() {
    SendbirdChat.removeChannelHandler('OpenChannel');
    SendbirdChat.removeConnectionHandler('OpenChannel');
    textEditingController.dispose();

    OpenChannel.getChannel(channelUrl).then((channel) => channel.exit());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Center(
          child: Text(
            "강남스팟",
            style: TextStyle(color: Colors.white),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(child: messageList.isNotEmpty ? _list() : Container()),
          _messageSender(),
        ],
      ),
    );
  }

  Widget _list() {
    return ScrollablePositionedList.builder(
      physics: const ClampingScrollPhysics(),
      initialScrollIndex: messageList.length - 1,
      itemScrollController: itemScrollController,
      itemCount: messageList.length,
      itemBuilder: (BuildContext context, int index) {
        if (index >= messageList.length) return Container();

        BaseMessage message = messageList[index];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: userId == (message.sender?.userId ?? 'x')
                ? Alignment.topRight
                : Alignment.topLeft,
            child: SizedBox(
              width: 300,
              child: Row(
                mainAxisAlignment: userId == (message.sender?.userId ?? 'x')
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (userId != (message.sender?.userId ?? 'x'))
                    CircleAvatar(
                      radius: 18,
                      child: Widgets.imageNetwork(
                          message.sender?.profileUrl, 25, Icons.account_circle),
                    ),
                  SizedBox(
                    width: 150,
                    child: Card(
                      color: userId == (message.sender?.userId ?? 'x')
                          ? Colors.transparent
                          : Colors.grey.shade900,
                      child: Container(
                        decoration: userId == (message.sender?.userId ?? 'x')
                            ? BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(30),
                                  topLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30),
                                  topRight: Radius.circular(5),
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.pink.shade500,
                                    Colors.pink.shade300
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              )
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Visibility(
                                visible:
                                    userId != (message.sender?.userId ?? 'x'),
                                // Set visibility based on user ID comparison
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: Text(
                                          message.sender?.userId ?? '',
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                child: Text(
                                  message.message,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (userId != (message.sender?.userId ?? 'x'))
                    if (userId == (message.sender?.userId ?? 'x'))
                      CircleAvatar(
                        radius: 18,
                        child: Widgets.imageNetwork(message.sender?.profileUrl,
                            25, Icons.account_circle),
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _messageSender() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.white),
          ),
          Expanded(
            child: TextField(
              controller: textEditingController,
              style: const TextStyle(color: Colors.white),
              // Set text color to white
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.0),
                  borderSide: const BorderSide(color: Colors.purple),
                ),
                hintText: '메세지 보내기',
                hintStyle: const TextStyle(
                  color: Colors.white30,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () async {
                      if (textEditingController.value.text.isEmpty) {
                        return;
                      }

                      openChannel?.sendUserMessage(
                        UserMessageCreateParams(
                          message: textEditingController.value.text,
                        ),
                        handler:
                            (UserMessage message, SendbirdException? e) async {
                          if (e != null) {
                            await _showDialogToResendUserMessage(message);
                          } else {
                            _addMessage(message);
                          }
                        },
                      );

                      textEditingController.clear();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.pink,
                      ),
                      child: const Icon(Icons.arrow_upward),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDialogToResendUserMessage(UserMessage message) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Text('Resend: ${message.message}'),
            actions: [
              TextButton(
                onPressed: () {
                  openChannel?.resendUserMessage(
                    message,
                    handler: (message, e) async {
                      if (e != null) {
                        await _showDialogToResendUserMessage(message);
                      } else {
                        _addMessage(message);
                      }
                    },
                  );

                  Get.back();
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('No'),
              ),
            ],
          );
        });
  }

  void _addMessage(BaseMessage message) {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      setState(() {
        messageList.add(message);
        title = '${openChannel.name} (${messageList.length})';
        participantCount = openChannel.participantCount;
      });

      Future.delayed(
        const Duration(milliseconds: 100),
        () => _scroll(messageList.length - 1),
      );
    });
  }

  void _updateParticipantCount() {
    OpenChannel.getChannel(channelUrl).then((openChannel) {
      setState(() {
        participantCount = openChannel.participantCount;
      });
    });
  }

  void _scroll(int index) async {
    if (messageList.length <= 1) return;

    while (!itemScrollController.isAttached) {
      await Future.delayed(const Duration(milliseconds: 1));
    }

    itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.fastOutSlowIn,
    );
  }
}

class MyOpenChannelHandler extends OpenChannelHandler {
  final OpenChannelPageState _state;

  MyOpenChannelHandler(this._state);

  @override
  void onMessageReceived(BaseChannel channel, BaseMessage message) {
    _state._addMessage(message);
  }

  @override
  void onUserEntered(OpenChannel channel, User user) {
    _state._updateParticipantCount();
  }

  @override
  void onUserExited(OpenChannel channel, User user) {
    _state._updateParticipantCount();
  }
}

class MyConnectionHandler extends ConnectionHandler {
  final OpenChannelPageState _state;

  MyConnectionHandler(this._state);

  @override
  void onConnected(String userId) {}

  @override
  void onDisconnected(String userId) {}

  @override
  void onReconnectStarted() {}

  @override
  void onReconnectSucceeded() {
    _state._initialize();
  }

  @override
  void onReconnectFailed() {}
}
