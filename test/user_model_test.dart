import 'package:migchat_flutter/user_model.dart';
import 'package:test/test.dart';
import 'package:migchat_flutter/proto/generated/migchat.pb.dart';
import 'package:fixnum/fixnum.dart';

void main() {
  const int ID = 777;
  const String NAME = 'some name';
  const String SHORT = 'alias';
  const int CREATED = 1234567;
  DateTime created = DateTime.fromMillisecondsSinceEpoch(CREATED * 1000);

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
        id: Int64(ID), name: NAME, shortName: SHORT, created: Int64(CREATED));
    UserModel model = UserModel.from(user);
    expect(model.id, ID);
    expect(model.shortName, SHORT);
    expect(model.name, NAME);
    expect(model.created, created);
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
