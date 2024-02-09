import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class LoginView extends StatefulWidget {
  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  final _appIdController =
      TextEditingController(text: "BC823AD1-FBEA-4F08-8F41-CF0D9D280FBF");
  final _userIdController = TextEditingController();
  bool _enableSignInButton = false;
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(child: body(context)),
    );
  }

  Widget navigationBar() {
    return AppBar(
      toolbarHeight: 65,
      elevation: 0,
      automaticallyImplyLeading: true,
      title: const Text('Assessment', style: TextStyle(color: Colors.black)),
      actions: [],
      centerTitle: true,
    );
  }

  Widget body(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 250),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text('Assessment',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 40),
            Visibility(
              visible: false,
              child: TextField(
                controller: _appIdController,
                onChanged: (value) {
                  setState(() {
                    _enableSignInButton = _shouldEnableSignInButton();
                  });
                },
                decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'App Id',
                    filled: true,
                    fillColor: Colors.grey[200],
                    suffixIcon: IconButton(
                      onPressed: () {
                        _appIdController.clear();
                      },
                      icon: Icon(Icons.clear),
                    )),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _userIdController,
              onChanged: (value) {
                setState(() {
                  _enableSignInButton = _shouldEnableSignInButton();
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  gapPadding: 1.0,
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                      color: Color(0xFF1A1A1A)), // Set border color to grey
                ),
                hintText: 'User Id',
                hintStyle: const TextStyle(color: Color(0xFF666666)),
                filled: true,
                fillColor: const Color(
                    0xFF3A3A3A), // Set background color to dark grey

                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF666666),
                  ), // Set border color when focused
                ), // Set label color to light grey
              ),
            ),
            const SizedBox(height: 30),
            FractionallySizedBox(
              widthFactor: 1,
              child: _signInButton(
                context,
                _enableSignInButton,
              ),
            )
          ],
        ));
  }

  bool _shouldEnableSignInButton() {
    if (_appIdController.text.isEmpty) {
      return false;
    }
    if (_userIdController.text.isEmpty) {
      return false;
    }
    return true;
  }

  Widget _signInButton(BuildContext context, bool enabled) {
    if (enabled == false) {
      // Disable the sign in button if required data not entered
      return TextButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(const Color(0xFF1A1A1A)),
          foregroundColor: MaterialStateProperty.all<Color>(
              const Color.fromARGB(255, 227, 226, 226)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10.0), // Set the border radius
              side: const BorderSide(
                  color: Color(0xFF3A3A3A)), // Set the border color
            ),
          ),
        ),
        onPressed: () {},
        child: const Text(
          "Sign In",
          style: TextStyle(fontSize: 20.0, color: Color(0xFF666666)),
        ),
      );
    }
    return TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        backgroundColor:
            MaterialStateProperty.all<Color>(const Color(0xFF131313)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Set the border radius
            side: const BorderSide(
                color: Color(0xFF3A3A3A)), // Set the border color
          ),
        ),
      ),
      onPressed: () {
        setState(() {
          _isSigningIn = true; // Set signing in state
        });
        connect(_appIdController.text, _userIdController.text).then((user) {
          setState(() {
            _isSigningIn = false; // Reset signing in state
          });
          Navigator.pushNamed(context, '/channel_list');
        }).catchError((error) {
          setState(() {
            _isSigningIn = false; // Reset signing in state on error
          });
        });
      },
      child: _isSigningIn
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 1.0,
              ),
            )
          : const Text(
              "Sign In",
              style: TextStyle(fontSize: 18.0),
            ),
    );
  }

  Future<User> connect(String appId, String userId) async {
    try {
      final sendbird = SendbirdSdk(appId: appId);
      final user = await sendbird.connect(userId);
      return user;
    } catch (e) {
      throw e;
    }
  }
}
