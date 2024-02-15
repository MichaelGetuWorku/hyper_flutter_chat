import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';

class OpenChannelListPage extends StatefulWidget {
  const OpenChannelListPage({Key? key}) : super(key: key);

  @override
  State<OpenChannelListPage> createState() => OpenChannelListPageState();
}

class OpenChannelListPageState extends State<OpenChannelListPage> {
  late OpenChannelListQuery query;

  String title = 'OpenChannels';
  bool hasNext = false;
  List<OpenChannel> channelList = [];

  @override
  void initState() {
    super.initState();

    query = OpenChannelListQuery()
      ..next().then((value) {
        setState(() {
          // final vals = value.where((element) => element.channelUrl == "");
          channelList.addAll(value);
          title = _getTitle();
          hasNext = query.hasNext;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Widgets.pageTitle(title),
      ),
      body: Column(
        children: [
          Expanded(child: channelList.isNotEmpty ? _list() : Container()),
          hasNext ? _nextButton() : Container(),
        ],
      ),
    );
  }

  Widget _list() {
    return ListView.builder(
      itemCount: channelList.length,
      itemBuilder: (BuildContext context, int index) {
        if (index >= channelList.length) return Container();

        final openChannel = channelList[index];

        return GestureDetector(
          onDoubleTap: () {
            Get.toNamed(
                    '/open_channel/update/sendbird_open_channel_14092_bf4075fbb8f12dc0df3ccc5c653f027186ac9211')
                ?.then((openChannel) {
              if (openChannel != null) {
                _refresh(openChannel);
              }
            });
          },
          onLongPress: () async {
            await openChannel.deleteChannel();
            setState(() {
              channelList.remove(openChannel);
              title = _getTitle();
            });
          },
          child: Column(
            children: [
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        openChannel.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                subtitle: Container(
                  margin: const EdgeInsets.only(left: 16),
                  alignment: Alignment.centerRight,
                  child: Text(
                    DateTime.fromMillisecondsSinceEpoch(
                      openChannel.createdAt! * 1000,
                    ).toString(),
                    style: const TextStyle(fontSize: 12.0),
                  ),
                ),
                onTap: () async {
                  Get.toNamed('/open_channel/${openChannel.channelUrl}')
                      ?.then((value) => _refresh(openChannel));
                },
              ),
              const Divider(height: 1),
            ],
          ),
        );
      },
    );
  }

  Widget _nextButton() {
    return Container(
      width: double.maxFinite,
      height: 32.0,
      color: Colors.purple[200],
      child: IconButton(
        icon: const Icon(Icons.expand_more, size: 16.0),
        color: Colors.white,
        onPressed: () async {
          if (query.hasNext && !query.isLoading) {
            final channels = await query.next();
            setState(() {
              channelList.addAll(channels);
              title = _getTitle();
              hasNext = query.hasNext;
            });
          }
        },
      ),
    );
  }

  void _refresh(OpenChannel openChannel) {
    for (int index = 0; index < channelList.length; index++) {
      if (channelList[index].channelUrl == openChannel.channelUrl) {
        setState(() => channelList[index] = openChannel);
        break;
      }
    }
  }

  String _getTitle() {
    return channelList.isEmpty
        ? 'OpenChannels'
        : 'OpenChannels (${channelList.length})';
  }
}
