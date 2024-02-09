// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'group_channel_view.dart';

class ChannelListView extends StatefulWidget {
  const ChannelListView({super.key});

  @override
  _ChannelListViewState createState() => _ChannelListViewState();
}

class _ChannelListViewState extends State<ChannelListView>
    with ChannelEventHandler {
  Future<List<GroupChannel>> getGroupChannels() async {
    try {
      final query = GroupChannelListQuery()
        ..includeEmptyChannel = true
        ..order = GroupChannelListOrder.latestLastMessage
        ..limit = 15;
      return await query.loadNext();
    } catch (e) {
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    SendbirdSdk().addChannelEventHandler('channel_list_view', this);
  }

  @override
  void dispose() {
    SendbirdSdk().removeChannelEventHandler("channel_list_view");
    super.dispose();
  }

  @override
  void onChannelChanged(BaseChannel channel) {
    setState(() {});
  }

  @override
  void onChannelDeleted(String channelUrl, ChannelType channelType) {
    setState(() {});
  }

  @override
  void onUserJoined(GroupChannel channel, User user) {
    setState(() {});
  }

  @override
  void onUserLeaved(GroupChannel channel, User user) {
    setState(() {});
    super.onUserLeaved(channel, user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: navigationBar(),
      body: Container(
        child: body(
          context,
        ),
      ),
    );
  }

  navigationBar() {
    return AppBar(
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
      ),
      centerTitle: true,
      title: const Text(
        'Channels',
        textAlign: TextAlign.left,
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
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
    );
  }

  Widget body(BuildContext context) {
    return FutureBuilder(
      future: getGroupChannels(),
      builder: (context, snapshot) {
        if (snapshot.hasData == false || snapshot.data == null) {
          return Container();
        }
        List<GroupChannel>? channels = snapshot.data;
        return ListView.builder(
            itemCount: channels!.length,
            itemBuilder: (context, index) {
              GroupChannel channel = channels[index];
              return Container(
                padding: const EdgeInsets.all(4.0),
                child: Card(
                  color: const Color(0xFF1A1A1A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                      [for (final member in channel.members) member.userId]
                          .join(", "),
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(channel.lastMessage?.message ?? ''),
                    onTap: () {
                      gotoChannel(channel.channelUrl);
                    },
                  ),
                ),
              );
            });
      },
    );
  }

  void gotoChannel(String channelUrl) {
    GroupChannel.getChannel(channelUrl).then((channel) {
      Navigator.pushNamed(context, '/channel_list');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChannelView(groupChannel: channel),
        ),
      );
    }).catchError((e) {});
  }
}
