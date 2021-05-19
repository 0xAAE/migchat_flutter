import 'package:migchat_flutter/post_model.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:fixnum/fixnum.dart';

class ChatScreenServicesMock {
  int _historyLen;

  ChatScreenServicesMock(this._historyLen);

  String resolveUserName(int id) {
    return 'User<${id.toString()}>';
  }

  String resolveChatName(int id) {
    return 'Chat<${id.toString()}>';
  }

  List<PostModel> historyLoader(int chatId, int idxFrom, int count) {
    if (idxFrom + count > _historyLen) {
      count = _historyLen - idxFrom;
      assert(count >= 0);
    }
    var ret = List<PostModel>.generate(count,
        (int index) => PostModel.from(Post(id: Int64(_historyLen - index))));
    _historyLen -= count;
    return ret;
  }
}
