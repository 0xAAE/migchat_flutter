import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migchat_flutter/chat_widget.dart';
import 'package:migchat_flutter/chat_model.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:fixnum/fixnum.dart';

String resolveUserName(int id) {
  return 'User<${id.toString()}>';
}

String resolveChatName(int id) {
  return 'Chat<${id.toString()}>';
}

void main() {
  const int USER0_ID = 0;
  const int USER1_ID = 555;
  const int USER2_ID = -333;
  const int ID = 777;
  const String DESCRIPTION = 'chat description';
  const int CREATED = 1234567;
  const bool PERMANENT = true;
  //DateTime created = DateTime.fromMillisecondsSinceEpoch(CREATED * 1000);

  testWidgets('ChatWidget displays name, short name and letter',
      (WidgetTester tester) async {
    ChatModel model = ChatModel.from(
        Chat(
            id: Int64(ID),
            permanent: PERMANENT,
            description: DESCRIPTION,
            users: <Int64>[Int64(USER0_ID), Int64(USER1_ID), Int64(USER2_ID)],
            created: Int64(CREATED)),
        resolveUserName,
        resolveChatName);
    var animationController = AnimationController(
      duration: Duration(milliseconds: 0),
      vsync: tester,
    );

    var testedWidget = ChatWidget(
        model: model,
        isSelected: true,
        letter: 'X',
        animationController: animationController);

    var supportingWidget = MaterialApp(
      home: Scaffold(body: testedWidget),
    );

    await tester.pumpWidget(supportingWidget);

    final letterFinder = find.text('X');
    final nameFinder = find.text(model.name);
    final membersFinder = find.text(model.members);

    expect(letterFinder, findsOneWidget);
    expect(nameFinder, findsOneWidget);
    expect(membersFinder, findsOneWidget);
  });
}
