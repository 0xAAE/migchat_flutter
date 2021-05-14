import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migchat_flutter/user_widget.dart';
import 'package:migchat_flutter/user_model.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:fixnum/fixnum.dart';

void main() {
  const int ID = 777;
  const String NAME = 'some name';
  const String SHORT = 'alias';
  const int CREATED = 1234567;
  //DateTime created = DateTime.fromMillisecondsSinceEpoch(CREATED * 1000);

  testWidgets('UserWidget displays name, short name and letter',
      (WidgetTester tester) async {
    UserModel model = UserModel.from(User(
        id: Int64(ID), name: NAME, shortName: SHORT, created: Int64(CREATED)));

    var animationController = AnimationController(
      duration: Duration(milliseconds: 0),
      vsync: tester,
    );

    expect(model.name.length, greaterThan(0));

    var testedWidget = UserWidget(
        model: model,
        isSelected: true,
        animationController: animationController);

    var supportingWidget = MaterialApp(
      home: Scaffold(body: testedWidget),
    );

    await tester.pumpWidget(supportingWidget);

    final letterFinder = find.text(model.name[0]);
    final shortFinder = find.text(model.shortName);
    final nameFinder = find.text(model.name);

    expect(letterFinder, findsOneWidget);
    expect(nameFinder, findsOneWidget);
    expect(shortFinder, findsOneWidget);
  });
}
