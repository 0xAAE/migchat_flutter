import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user_model.dart';

class CurrentUser {
  String name;
  String shortName;

  CurrentUser.from(UserModel model)
      : name = model.name,
        shortName = model.shortName;

  CurrentUser({required this.name, required this.shortName});
}

class CurrentUserInfo extends StatefulWidget {
  final UserModel user;

  CurrentUserInfo(this.user);

  @override
  _CurrentUserInfoState createState() =>
      _CurrentUserInfoState(CurrentUser.from(user));
}

class _CurrentUserInfoState extends State<CurrentUserInfo> {
  CurrentUser user;

  late FocusNode _fieldShortName;
  late FocusNode _button;

  _CurrentUserInfoState(this.user);

  @override
  void initState() {
    super.initState();
    _fieldShortName = FocusNode();
    _button = FocusNode();
  }

  @override
  void dispose() {
    _fieldShortName.dispose();
    _button.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const sizedBox = SizedBox(height: 24);
    return Scaffold(
      appBar: AppBar(
        title: Text("User info"),
      ),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  sizedBox,
                  Container(
                    child: Text(
                      "Enter your user information to register on server. Then press button 'Register' to submit the info",
                      textAlign: TextAlign.left,
                    ),
                    width: double.infinity,
                  ),
                  sizedBox,
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      filled: true,
                      icon: const Icon(Icons.login),
                      hintText: "login",
                      labelText: "Short name",
                    ),
                    initialValue: user.shortName,
                    onChanged: (value) => user.shortName = value,
                    onSaved: (value) {
                      //user.shortName = value ?? '';
                      _fieldShortName.requestFocus();
                    },
                  ),
                  sizedBox,
                  TextFormField(
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                          filled: true,
                          icon: const Icon(Icons.person),
                          hintText: "actual",
                          labelText: "Name"),
                      initialValue: user.name,
                      onChanged: (value) => user.name = value,
                      onSaved: (value) {
                        // user.name = value ?? '';
                        _button.requestFocus();
                      }),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate back to first route when tapped.
                      Navigator.pop(context, user);
                    },
                    child: Text('Register'),
                  ),
                  sizedBox,
                ],
              ))),
    );
  }
}
