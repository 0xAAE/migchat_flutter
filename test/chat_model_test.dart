import 'package:migchat_flutter/chat_model.dart';
import 'package:migchat_flutter/post_model.dart';
import 'mock.dart';
import 'package:test/test.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:fixnum/fixnum.dart';

void main() {
  const int USER0_ID = 0;
  const int USER1_ID = 555;
  const int USER2_ID = -333;
  const int ID = 777;
  const String DESCRIPTION = 'chat description';
  const int CREATED = 1234567;
  const bool PERMANENT = true;
  DateTime created = DateTime.fromMillisecondsSinceEpoch(CREATED * 1000);
  const int HISTORY = 77;

  test('ChatModel.from(chat) has to be equal to its source', () {
    var mock = ChatScreenServicesMock(0, USER0_ID);
    ChatUpdate update = ChatUpdate(
        chat: Chat(
            id: Int64(ID),
            permanent: PERMANENT,
            description: DESCRIPTION,
            users: <Int64>[Int64(USER0_ID), Int64(USER1_ID), Int64(USER2_ID)],
            created: Int64(CREATED)),
        currentlyPosts: Int64(HISTORY));
    ChatModel model = ChatModel.from(update, mock);

    expect(model.id, ID);
    expect(model.permanent, PERMANENT);
    expect(model.description, DESCRIPTION);
    expect(model.userIds, <int>[USER0_ID, USER1_ID, USER2_ID]);
    expect(model.invitations.length, 0);
    expect(model.created, created);
    expect(model.historyAvailable, HISTORY);
    expect(model.viewed, false);
  });

  test('ChatModel must return !viewed only once', () {
    var mock = ChatScreenServicesMock(0, USER0_ID);
    ChatModel model = ChatModel.from(ChatUpdate(), mock);
    expect(model.viewed, false);
    expect(model.viewed, true);
    expect(model.viewed, true);
  });

  test('ChatModel is constructable from empty chat', () {
    var mock = ChatScreenServicesMock(0, USER0_ID);
    ChatModel model = ChatModel.from(ChatUpdate(), mock);
    expect(model.id, 0);
    expect(model.permanent, false);
    expect(model.description, '');
    expect(model.userIds.length, 0);
    expect(model.invitations.length, 0);
    expect(model.created, DateTime.fromMillisecondsSinceEpoch(0));
    expect(model.viewed, false);
    expect(model.members, '');
    expect(model.historyAvailable, 0);
    expect(model.name, mock.resolveChatName(0));
  });

  test('ChatModel handles the chat history', () {
    var mock = ChatScreenServicesMock(HISTORY, USER1_ID);
    ChatUpdate update = ChatUpdate(
        chat: Chat(
            id: Int64(ID),
            permanent: PERMANENT,
            description: DESCRIPTION,
            users: <Int64>[Int64(USER0_ID), Int64(USER1_ID), Int64(USER2_ID)],
            created: Int64(CREATED)),
        currentlyPosts: Int64(HISTORY));
    ChatModel model = ChatModel.from(update, mock);

    // test overall posts counting
    expect(model.totalPosts, HISTORY);
    // and particularly history
    expect(model.historyAvailable, HISTORY);
    for (var i = 0; i < HISTORY; i++) {
      var postModel = model.getPost(i);
      // test that posts arrive in reverse order, from recent to older one
      expect(postModel.id, HISTORY - i);
    }
    // test that iterating through all the posts doesn't affect the total posts count
    expect(model.totalPosts, HISTORY);
    // test that iterating through all the posts forces downloading them
    expect(model.historyAvailable, 0);
  });

  test('ChatModel must distinct outgoing posts from incoming', () {
    var mock = ChatScreenServicesMock(0, USER0_ID);
    ChatUpdate update = ChatUpdate(
        chat: Chat(
            id: Int64(ID),
            permanent: PERMANENT,
            description: DESCRIPTION,
            users: <Int64>[Int64(USER0_ID), Int64(USER1_ID), Int64(USER2_ID)],
            created: Int64(CREATED)),
        currentlyPosts: Int64(0));
    ChatModel model = ChatModel.from(update, mock);

    // outgoing new post
    model.insertNewPost(PostModel.from(Post(userId: Int64(USER0_ID))));
    expect(model.getPost(0).runtimeType, OutgoingPostModel);
    // incoming new post
    model.insertNewPost(PostModel.from(Post(userId: Int64(USER2_ID))));
    expect(model.getPost(0).runtimeType, PostModel);
    // outgoing old post
    model.addOldPost(PostModel.from(Post(userId: Int64(USER0_ID))));
    expect(model.getPost(model.totalPosts - 1).runtimeType, OutgoingPostModel);
    // incoming old post
    model.addOldPost(PostModel.from(Post(userId: Int64(USER2_ID))));
    expect(model.getPost(model.totalPosts - 1).runtimeType, PostModel);
  });
}
