import 'package:assignment2/src/pages/group_channel_view.dart';
import 'package:assignment2/src/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class CreateChannelView extends StatefulWidget {
  const CreateChannelView({super.key});

  @override
  _CreateChannelViewState createState() => _CreateChannelViewState();
}

class _CreateChannelViewState extends State<CreateChannelView> {
  final Set<User> _selectedUsers = {};
  final List<User> _availableUsers = [];

  Future<List<User>> getUsers() async {
    try {
      final query = ApplicationUserListQuery();
      List<User> users = await query.loadNext();
      return users;
    } catch (e) {
      print('create_channel_view: getUsers: ERROR: $e');
      return [];
    }
  }

  Future<GroupChannel> createChannel(List<String> userIds) async {
    try {
      final params = GroupChannelParams()..userIds = userIds;
      final channel = await GroupChannel.createChannel(params);
      return channel;
    } catch (e) {
      throw e;
    }
  }

  @override
  void initState() {
    super.initState();
    getUsers().then((users) {
      setState(() {
        _availableUsers.clear();
        _availableUsers.addAll(users);
      });
    }).catchError((e) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: navigationBar(),
      body: body(context),
    );
  }

  navigationBar() {
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: true,
      title: const Text(
        'Select members',
        textAlign: TextAlign.left,
        style: TextStyle(
            color: whiteColor, fontSize: 20, fontWeight: FontWeight.w300),
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(primaryColor)),
          onPressed: () {
            if (_selectedUsers.toList().isEmpty) {
              return;
            }
            createChannel(
                    [for (final user in _selectedUsers.toList()) user.userId])
                .then((channel) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupChannelView(groupChannel: channel),
                ),
              );
            }).catchError((error) {});
          },
          child:
              const Icon(Icons.add_circle_outline_sharp, color: primaryColor),
        ),
      ],
    );
  }

  Widget body(BuildContext context) {
    return SizedBox(
      height:
          MediaQuery.of(context).size.height, // Set a specific height as needed
      child: ListView.builder(
        itemCount: _availableUsers.length,
        itemBuilder: (context, index) {
          User user = _availableUsers[index];
          return CheckboxListTile(
            title: Text(
              user.nickname.isEmpty ? user.userId : user.nickname,
              style: const TextStyle(color: whiteColor),
            ),
            controlAffinity: ListTileControlAffinity.platform,
            value: _selectedUsers.contains(user),
            activeColor: Theme.of(context).primaryColor,
            onChanged: (bool? value) {
              setState(() {
                if (value!) {
                  _selectedUsers.add(user);
                } else {
                  _selectedUsers.remove(user);
                }
              });
            },
            secondary: user.profileUrl!.isEmpty
                ? CircleAvatar(
                    child: Text(
                    (user.nickname.isEmpty ? user.userId : user.nickname)
                        .substring(0, 1)
                        .toUpperCase(),
                  ))
                : CircleAvatar(
                    backgroundImage: NetworkImage(user.profileUrl!),
                  ),
          );
        },
      ),
    );
  }
}
