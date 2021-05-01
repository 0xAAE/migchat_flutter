///
//  Generated code. Do not modify.
//  source: migchat.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'migchat.pb.dart' as $0;
export 'migchat.pb.dart';

class ChatRoomServiceClient extends $grpc.Client {
  static final _$register =
      $grpc.ClientMethod<$0.UserInfo, $0.RegistrationInfo>(
          '/migchat.ChatRoomService/Register',
          ($0.UserInfo value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.RegistrationInfo.fromBuffer(value));
  static final _$logout = $grpc.ClientMethod<$0.Registration, $0.Result>(
      '/migchat.ChatRoomService/Logout',
      ($0.Registration value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Result.fromBuffer(value));
  static final _$getInvitations =
      $grpc.ClientMethod<$0.Registration, $0.Invitation>(
          '/migchat.ChatRoomService/GetInvitations',
          ($0.Registration value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.Invitation.fromBuffer(value));
  static final _$getUsers = $grpc.ClientMethod<$0.Registration, $0.UpdateUsers>(
      '/migchat.ChatRoomService/GetUsers',
      ($0.Registration value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.UpdateUsers.fromBuffer(value));
  static final _$getChats = $grpc.ClientMethod<$0.Registration, $0.UpdateChats>(
      '/migchat.ChatRoomService/GetChats',
      ($0.Registration value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.UpdateChats.fromBuffer(value));
  static final _$getPosts = $grpc.ClientMethod<$0.Registration, $0.Post>(
      '/migchat.ChatRoomService/GetPosts',
      ($0.Registration value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Post.fromBuffer(value));
  static final _$createPost = $grpc.ClientMethod<$0.Post, $0.Result>(
      '/migchat.ChatRoomService/CreatePost',
      ($0.Post value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Result.fromBuffer(value));
  static final _$createChat = $grpc.ClientMethod<$0.ChatInfo, $0.Chat>(
      '/migchat.ChatRoomService/CreateChat',
      ($0.ChatInfo value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Chat.fromBuffer(value));
  static final _$inviteUser = $grpc.ClientMethod<$0.Invitation, $0.Result>(
      '/migchat.ChatRoomService/InviteUser',
      ($0.Invitation value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Result.fromBuffer(value));
  static final _$enterChat = $grpc.ClientMethod<$0.ChatReference, $0.Result>(
      '/migchat.ChatRoomService/EnterChat',
      ($0.ChatReference value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Result.fromBuffer(value));
  static final _$leaveChat = $grpc.ClientMethod<$0.ChatReference, $0.Result>(
      '/migchat.ChatRoomService/LeaveChat',
      ($0.ChatReference value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Result.fromBuffer(value));

  ChatRoomServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.RegistrationInfo> register($0.UserInfo request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$register, request, options: options);
  }

  $grpc.ResponseFuture<$0.Result> logout($0.Registration request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$logout, request, options: options);
  }

  $grpc.ResponseStream<$0.Invitation> getInvitations($0.Registration request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$getInvitations, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseStream<$0.UpdateUsers> getUsers($0.Registration request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$getUsers, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseStream<$0.UpdateChats> getChats($0.Registration request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$getChats, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseStream<$0.Post> getPosts($0.Registration request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$getPosts, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.Result> createPost($0.Post request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createPost, request, options: options);
  }

  $grpc.ResponseFuture<$0.Chat> createChat($0.ChatInfo request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createChat, request, options: options);
  }

  $grpc.ResponseFuture<$0.Result> inviteUser($0.Invitation request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$inviteUser, request, options: options);
  }

  $grpc.ResponseFuture<$0.Result> enterChat($0.ChatReference request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$enterChat, request, options: options);
  }

  $grpc.ResponseFuture<$0.Result> leaveChat($0.ChatReference request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$leaveChat, request, options: options);
  }
}

abstract class ChatRoomServiceBase extends $grpc.Service {
  $core.String get $name => 'migchat.ChatRoomService';

  ChatRoomServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.UserInfo, $0.RegistrationInfo>(
        'Register',
        register_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UserInfo.fromBuffer(value),
        ($0.RegistrationInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Registration, $0.Result>(
        'Logout',
        logout_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Registration.fromBuffer(value),
        ($0.Result value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Registration, $0.Invitation>(
        'GetInvitations',
        getInvitations_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Registration.fromBuffer(value),
        ($0.Invitation value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Registration, $0.UpdateUsers>(
        'GetUsers',
        getUsers_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Registration.fromBuffer(value),
        ($0.UpdateUsers value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Registration, $0.UpdateChats>(
        'GetChats',
        getChats_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Registration.fromBuffer(value),
        ($0.UpdateChats value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Registration, $0.Post>(
        'GetPosts',
        getPosts_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Registration.fromBuffer(value),
        ($0.Post value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Post, $0.Result>(
        'CreatePost',
        createPost_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Post.fromBuffer(value),
        ($0.Result value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatInfo, $0.Chat>(
        'CreateChat',
        createChat_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChatInfo.fromBuffer(value),
        ($0.Chat value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Invitation, $0.Result>(
        'InviteUser',
        inviteUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Invitation.fromBuffer(value),
        ($0.Result value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatReference, $0.Result>(
        'EnterChat',
        enterChat_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChatReference.fromBuffer(value),
        ($0.Result value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChatReference, $0.Result>(
        'LeaveChat',
        leaveChat_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChatReference.fromBuffer(value),
        ($0.Result value) => value.writeToBuffer()));
  }

  $async.Future<$0.RegistrationInfo> register_Pre(
      $grpc.ServiceCall call, $async.Future<$0.UserInfo> request) async {
    return register(call, await request);
  }

  $async.Future<$0.Result> logout_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Registration> request) async {
    return logout(call, await request);
  }

  $async.Stream<$0.Invitation> getInvitations_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Registration> request) async* {
    yield* getInvitations(call, await request);
  }

  $async.Stream<$0.UpdateUsers> getUsers_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Registration> request) async* {
    yield* getUsers(call, await request);
  }

  $async.Stream<$0.UpdateChats> getChats_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Registration> request) async* {
    yield* getChats(call, await request);
  }

  $async.Stream<$0.Post> getPosts_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Registration> request) async* {
    yield* getPosts(call, await request);
  }

  $async.Future<$0.Result> createPost_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Post> request) async {
    return createPost(call, await request);
  }

  $async.Future<$0.Chat> createChat_Pre(
      $grpc.ServiceCall call, $async.Future<$0.ChatInfo> request) async {
    return createChat(call, await request);
  }

  $async.Future<$0.Result> inviteUser_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Invitation> request) async {
    return inviteUser(call, await request);
  }

  $async.Future<$0.Result> enterChat_Pre(
      $grpc.ServiceCall call, $async.Future<$0.ChatReference> request) async {
    return enterChat(call, await request);
  }

  $async.Future<$0.Result> leaveChat_Pre(
      $grpc.ServiceCall call, $async.Future<$0.ChatReference> request) async {
    return leaveChat(call, await request);
  }

  $async.Future<$0.RegistrationInfo> register(
      $grpc.ServiceCall call, $0.UserInfo request);
  $async.Future<$0.Result> logout(
      $grpc.ServiceCall call, $0.Registration request);
  $async.Stream<$0.Invitation> getInvitations(
      $grpc.ServiceCall call, $0.Registration request);
  $async.Stream<$0.UpdateUsers> getUsers(
      $grpc.ServiceCall call, $0.Registration request);
  $async.Stream<$0.UpdateChats> getChats(
      $grpc.ServiceCall call, $0.Registration request);
  $async.Stream<$0.Post> getPosts(
      $grpc.ServiceCall call, $0.Registration request);
  $async.Future<$0.Result> createPost($grpc.ServiceCall call, $0.Post request);
  $async.Future<$0.Chat> createChat(
      $grpc.ServiceCall call, $0.ChatInfo request);
  $async.Future<$0.Result> inviteUser(
      $grpc.ServiceCall call, $0.Invitation request);
  $async.Future<$0.Result> enterChat(
      $grpc.ServiceCall call, $0.ChatReference request);
  $async.Future<$0.Result> leaveChat(
      $grpc.ServiceCall call, $0.ChatReference request);
}
