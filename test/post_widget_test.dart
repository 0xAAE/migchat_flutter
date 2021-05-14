import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:migchat_flutter/post_widget_incoming.dart';
import 'package:migchat_flutter/post_widget_outgoing.dart';
import 'package:migchat_flutter/post_model.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:fixnum/fixnum.dart';

String resolveUserName(int id) {
  return 'User<${id.toString()}>';
}

void main() {
  const int USER_ID = 777;
  const int CHAT_ID = 555;
  const int ID = 333;
  const String TEXT = 'some text';
  const String USER_NAME = 'User';
  const int CREATED = 1234567;
  const PostStatus STATUS = PostStatus.SENT;
  //DateTime created = DateTime.fromMillisecondsSinceEpoch(CREATED * 1000);

  testWidgets('IncomingPostWidget displays letter, author, date and text',
      (WidgetTester tester) async {
    var model = PostModel.from(Post(
        chatId: Int64(CHAT_ID),
        userId: Int64(USER_ID),
        created: Int64(CREATED),
        text: TEXT,
        id: Int64(ID)));

    var animationController = AnimationController(
      duration: Duration(milliseconds: 0),
      vsync: tester,
    );

    var testedWidget = IncomingPostWidget(
      model: model,
      animationController: animationController,
      resolveUserName: resolveUserName,
    );

    var supportingWidget = MaterialApp(
      home: Scaffold(body: testedWidget),
    );

    await tester.pumpWidget(supportingWidget);

    var author = resolveUserName(model.userId);
    expect(author.length, greaterThan(0));

    final letterFinder = find.text(author[0]);
    final createdFinder = find.textContaining(model.createdText);
    final authorFinder = find.textContaining(author);
    final textFinder = find.text(TEXT);

    expect(letterFinder, findsOneWidget);
    expect(createdFinder, findsOneWidget);
    expect(authorFinder, findsOneWidget);
    expect(textFinder, findsOneWidget);
  });

  testWidgets(
      'OutgoingPostWidget displays letter, author, date and text, as well an icon',
      (WidgetTester tester) async {
    var model = OutgoingPostModel.from(
        PostModel.from(Post(
            chatId: Int64(CHAT_ID),
            userId: Int64(USER_ID),
            created: Int64(CREATED),
            text: TEXT,
            id: Int64(ID))),
        STATUS);

    var animationController = AnimationController(
      duration: Duration(milliseconds: 0),
      vsync: tester,
    );

    var testedWidget = OutgoingPostWidget(
      model: model,
      animationController: animationController,
      userName: USER_NAME,
    );

    var supportingWidget = MaterialApp(
      home: Scaffold(body: testedWidget),
    );

    await tester.pumpWidget(supportingWidget);

    final letterFinder = find.text(USER_NAME[0]);
    final createdFinder = find.textContaining(model.createdText);
    final nameFinder = find.textContaining(USER_NAME);
    final textFinder = find.text(TEXT);

    expect(letterFinder, findsOneWidget);
    expect(createdFinder, findsOneWidget);
    expect(nameFinder, findsOneWidget);
    expect(textFinder, findsOneWidget);
  });
}
