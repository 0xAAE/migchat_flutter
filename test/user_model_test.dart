import 'package:migchat_flutter/user_model.dart';
import 'package:test/test.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:fixnum/fixnum.dart';

void main() {
  test('UserModel() must not have empty name and shortName', () {
    UserModel model = UserModel(
        name: '',
        shortName: '',
        created: DateTime.fromMicrosecondsSinceEpoch(0));
    expect(model.name.length, greaterThan(0));
    expect(model.shortName.length, greaterThan(0));
  });

  test('UserModel.from(user) must not have empty name and shortName', () {
    User user = User();
    UserModel model = UserModel.from(user);
    expect(model.name.length, greaterThan(0));
    expect(model.shortName.length, greaterThan(0));
  });

  test('UserModel.from(user) has to be equal to its source', () {
    User user = User(
        id: Int64(1),
        name: 'name',
        shortName: 'short name',
        created: Int64(1234567));
    UserModel model = UserModel.from(user);
    expect(model.id, user.id.toInt());
    expect(model.shortName, user.shortName);
    expect(model.name, user.name);
    expect(model.created,
        DateTime.fromMillisecondsSinceEpoch(user.created.toInt() * 1000));
  });

  test('UserModel is constructable from empty User', () {
    UserModel model = UserModel.from(User());

    expect(model.id, 0);
    expect(model.name, '0');
    expect(model.shortName, '?');
    expect(model.created, DateTime.fromMillisecondsSinceEpoch(0));
    expect(model.createdText, '01.01.1970');
  });
}
