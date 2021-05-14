import 'package:migchat_flutter/chat_model.dart';
import 'package:test/test.dart';
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
  DateTime created = DateTime.fromMillisecondsSinceEpoch(CREATED * 1000);

  test('ChatModel.from(chat) has to be equal to its source', () {
    Chat chat = Chat(
        id: Int64(ID),
        permanent: PERMANENT,
        description: DESCRIPTION,
        users: <Int64>[Int64(USER0_ID), Int64(USER1_ID), Int64(USER2_ID)],
        created: Int64(CREATED));
    ChatModel model = ChatModel.from(chat, resolveUserName, resolveChatName);

    expect(model.id, ID);
    expect(model.permanent, PERMANENT);
    expect(model.description, DESCRIPTION);
    expect(model.userIds, <int>[USER0_ID, USER1_ID, USER2_ID]);
    expect(model.invitations.length, 0);
    expect(model.created, created);
    expect(model.viewed, false);
  });

  test('ChatModel must return !viewed only once', () {
    ChatModel model = ChatModel.from(Chat(), resolveUserName, resolveChatName);
    expect(model.viewed, false);
    expect(model.viewed, true);
    expect(model.viewed, true);
  });

  test('ChatModel is constructable from empty chat', () {
    ChatModel model = ChatModel.from(Chat(), resolveUserName, resolveChatName);
    expect(model.id, 0);
    expect(model.permanent, false);
    expect(model.description, '');
    expect(model.userIds.length, 0);
    expect(model.invitations.length, 0);
    expect(model.created, DateTime.fromMillisecondsSinceEpoch(0));
    expect(model.viewed, false);
    expect(model.members, '');
    expect(model.name, resolveChatName(0));
  });
}
