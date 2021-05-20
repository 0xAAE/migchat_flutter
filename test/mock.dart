import 'package:migchat_flutter/post_model.dart';
import 'package:migchat_flutter/chat_model.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:fixnum/fixnum.dart';

class ChatScreenServicesMock implements ChatServiceProvider {
  int _historyLen;
  final int _userId;

  ChatScreenServicesMock(this._historyLen, this._userId);

  String resolveUserName(int id) {
    return 'User<${id.toString()}>';
  }

  String resolveChatName(int id) {
    return 'Chat<${id.toString()}>';
  }

  void loadChatHistory(
      int chatId, int idxFrom, int count, HistoryLoadedCallback handler) {
    if (idxFrom + count > _historyLen) {
      count = _historyLen - idxFrom;
      assert(count >= 0);
    }
    var ret = List<PostModel>.generate(count,
        (int index) => PostModel.from(Post(id: Int64(_historyLen - index))));
    _historyLen -= count;
    handler(ret.reversed.toList());
  }

  int get registeredUserId => _userId;
}
