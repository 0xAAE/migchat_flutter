import 'package:migchat_flutter/post_model.dart';
import 'package:test/test.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:fixnum/fixnum.dart';

void main() {
  const int USER_ID = 777;
  const int CHAT_ID = 555;
  const int ID = 333;
  const String TEXT = 'some text';
  const int CREATED = 1234567;
  DateTime created = DateTime.fromMillisecondsSinceEpoch(CREATED * 1000);
  const PostStatus STATUS = PostStatus.SENT;

  test('PostModel() constructor', () {
    var model = PostModel(
        chatId: CHAT_ID, userId: USER_ID, created: created, text: TEXT, id: ID);

    expect(model.id, ID);
    expect(model.chatId, CHAT_ID);
    expect(model.userId, USER_ID);
    expect(model.text, TEXT);
    expect(model.created, created);
  });

  test('PostModel.from(post) constructor', () {
    var model = PostModel.from(Post(
        chatId: Int64(CHAT_ID),
        userId: Int64(USER_ID),
        created: Int64(CREATED),
        text: TEXT,
        id: Int64(ID)));

    expect(model.id, ID);
    expect(model.chatId, CHAT_ID);
    expect(model.userId, USER_ID);
    expect(model.text, TEXT);
    expect(model.created, created);
  });

  test('PostModel must be constructable from empty post', () {
    var model = PostModel.from(Post());

    expect(model.id, 0);
    expect(model.chatId, 0);
    expect(model.userId, 0);
    expect(model.text, '');
    expect(model.created, DateTime.fromMillisecondsSinceEpoch(0));
  });

  test('OutgoingPostModel() constructor', () {
    var model = OutgoingPostModel(
        chatId: CHAT_ID, userId: USER_ID, text: TEXT, status: STATUS);

    expect(model.id, 0);
    expect(model.chatId, CHAT_ID);
    expect(model.userId, USER_ID);
    expect(model.text, TEXT);
    expect(model.status, STATUS);
  });

  test('OutgoingPostModel.from(model) constructor', () {
    var model = OutgoingPostModel.from(
        PostModel.from(Post(
            chatId: Int64(CHAT_ID),
            userId: Int64(USER_ID),
            created: Int64(CREATED),
            text: TEXT,
            id: Int64(ID))),
        STATUS);

    expect(model.id, ID);
    expect(model.chatId, CHAT_ID);
    expect(model.userId, USER_ID);
    expect(model.text, TEXT);
    expect(model.created, created);
    expect(model.status, STATUS);
  });

  test('OutgoingPostModel must be constructable from empty post model', () {
    var model = OutgoingPostModel.from(PostModel.from(Post()), STATUS);

    expect(model.id, 0);
    expect(model.chatId, 0);
    expect(model.userId, 0);
    expect(model.text, '');
    expect(model.created, DateTime.fromMillisecondsSinceEpoch(0));
    expect(model.status, STATUS);
  });
}
