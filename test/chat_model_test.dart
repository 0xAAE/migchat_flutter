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
  test('ChatModel.from(chat) has to be equal to its source', () {
    Chat chat = Chat(
        id: Int64(1),
        permanent: true,
        description: 'chat description',
        users: <Int64>[Int64(0), Int64(1), Int64(-1)],
        created: Int64(1234567));
    ChatModel model = ChatModel.from(chat, resolveUserName, resolveChatName);

    expect(model.id, chat.id.toInt());

    expect(model.permanent, chat.permanent);

    expect(model.description, chat.description);

    expect(model.userIds, <int>[
      chat.users[0].toInt(),
      chat.users[1].toInt(),
      chat.users[2].toInt()
    ]);

    expect(model.invitations.length, 0);

    expect(model.created,
        DateTime.fromMillisecondsSinceEpoch(chat.created.toInt() * 1000));

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
