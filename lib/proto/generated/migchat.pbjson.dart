///
//  Generated code. Do not modify.
//  source: migchat.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields,deprecated_member_use_from_same_package

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use attachmentTypeDescriptor instead')
const AttachmentType$json = const {
  '1': 'AttachmentType',
  '2': const [
    const {'1': 'None', '2': 0},
    const {'1': 'Image', '2': 1},
    const {'1': 'Audio', '2': 2},
    const {'1': 'Video', '2': 3},
    const {'1': 'File', '2': 4},
  ],
};

/// Descriptor for `AttachmentType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List attachmentTypeDescriptor = $convert.base64Decode('Cg5BdHRhY2htZW50VHlwZRIICgROb25lEAASCQoFSW1hZ2UQARIJCgVBdWRpbxACEgkKBVZpZGVvEAMSCAoERmlsZRAE');
@$core.Deprecated('Use userInfoDescriptor instead')
const UserInfo$json = const {
  '1': 'UserInfo',
  '2': const [
    const {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'short_name', '3': 2, '4': 1, '5': 9, '10': 'shortName'},
  ],
};

/// Descriptor for `UserInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userInfoDescriptor = $convert.base64Decode('CghVc2VySW5mbxISCgRuYW1lGAEgASgJUgRuYW1lEh0KCnNob3J0X25hbWUYAiABKAlSCXNob3J0TmFtZQ==');
@$core.Deprecated('Use registrationDescriptor instead')
const Registration$json = const {
  '1': 'Registration',
  '2': const [
    const {'1': 'user_id', '3': 1, '4': 1, '5': 4, '10': 'userId'},
  ],
};

/// Descriptor for `Registration`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registrationDescriptor = $convert.base64Decode('CgxSZWdpc3RyYXRpb24SFwoHdXNlcl9pZBgBIAEoBFIGdXNlcklk');
@$core.Deprecated('Use registrationInfoDescriptor instead')
const RegistrationInfo$json = const {
  '1': 'RegistrationInfo',
  '2': const [
    const {'1': 'registration', '3': 1, '4': 1, '5': 11, '6': '.migchat.Registration', '10': 'registration'},
    const {'1': 'created', '3': 2, '4': 1, '5': 4, '10': 'created'},
  ],
};

/// Descriptor for `RegistrationInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registrationInfoDescriptor = $convert.base64Decode('ChBSZWdpc3RyYXRpb25JbmZvEjkKDHJlZ2lzdHJhdGlvbhgBIAEoCzIVLm1pZ2NoYXQuUmVnaXN0cmF0aW9uUgxyZWdpc3RyYXRpb24SGAoHY3JlYXRlZBgCIAEoBFIHY3JlYXRlZA==');
@$core.Deprecated('Use updateUsersDescriptor instead')
const UpdateUsers$json = const {
  '1': 'UpdateUsers',
  '2': const [
    const {'1': 'added', '3': 1, '4': 3, '5': 11, '6': '.migchat.User', '10': 'added'},
    const {'1': 'offline', '3': 2, '4': 3, '5': 4, '10': 'offline'},
    const {'1': 'online', '3': 3, '4': 3, '5': 4, '10': 'online'},
  ],
};

/// Descriptor for `UpdateUsers`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateUsersDescriptor = $convert.base64Decode('CgtVcGRhdGVVc2VycxIjCgVhZGRlZBgBIAMoCzINLm1pZ2NoYXQuVXNlclIFYWRkZWQSGAoHb2ZmbGluZRgCIAMoBFIHb2ZmbGluZRIWCgZvbmxpbmUYAyADKARSBm9ubGluZQ==');
@$core.Deprecated('Use userDescriptor instead')
const User$json = const {
  '1': 'User',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'short_name', '3': 3, '4': 1, '5': 9, '10': 'shortName'},
    const {'1': 'created', '3': 4, '4': 1, '5': 4, '10': 'created'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode('CgRVc2VyEg4KAmlkGAEgASgEUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEh0KCnNob3J0X25hbWUYAyABKAlSCXNob3J0TmFtZRIYCgdjcmVhdGVkGAQgASgEUgdjcmVhdGVk');
@$core.Deprecated('Use chatUpdateDescriptor instead')
const ChatUpdate$json = const {
  '1': 'ChatUpdate',
  '2': const [
    const {'1': 'chat', '3': 1, '4': 1, '5': 11, '6': '.migchat.Chat', '10': 'chat'},
    const {'1': 'currently_posts', '3': 2, '4': 1, '5': 4, '10': 'currentlyPosts'},
  ],
};

/// Descriptor for `ChatUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatUpdateDescriptor = $convert.base64Decode('CgpDaGF0VXBkYXRlEiEKBGNoYXQYASABKAsyDS5taWdjaGF0LkNoYXRSBGNoYXQSJwoPY3VycmVudGx5X3Bvc3RzGAIgASgEUg5jdXJyZW50bHlQb3N0cw==');
@$core.Deprecated('Use updateChatsDescriptor instead')
const UpdateChats$json = const {
  '1': 'UpdateChats',
  '2': const [
    const {'1': 'updated', '3': 1, '4': 3, '5': 11, '6': '.migchat.ChatUpdate', '10': 'updated'},
    const {'1': 'gone', '3': 2, '4': 3, '5': 4, '10': 'gone'},
  ],
};

/// Descriptor for `UpdateChats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateChatsDescriptor = $convert.base64Decode('CgtVcGRhdGVDaGF0cxItCgd1cGRhdGVkGAEgAygLMhMubWlnY2hhdC5DaGF0VXBkYXRlUgd1cGRhdGVkEhIKBGdvbmUYAiADKARSBGdvbmU=');
@$core.Deprecated('Use chatInfoDescriptor instead')
const ChatInfo$json = const {
  '1': 'ChatInfo',
  '2': const [
    const {'1': 'user_id', '3': 1, '4': 1, '5': 4, '10': 'userId'},
    const {'1': 'permanent', '3': 2, '4': 1, '5': 8, '10': 'permanent'},
    const {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    const {'1': 'auto_enter', '3': 4, '4': 1, '5': 8, '10': 'autoEnter'},
    const {'1': 'desired_users', '3': 5, '4': 3, '5': 4, '10': 'desiredUsers'},
  ],
};

/// Descriptor for `ChatInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatInfoDescriptor = $convert.base64Decode('CghDaGF0SW5mbxIXCgd1c2VyX2lkGAEgASgEUgZ1c2VySWQSHAoJcGVybWFuZW50GAIgASgIUglwZXJtYW5lbnQSIAoLZGVzY3JpcHRpb24YAyABKAlSC2Rlc2NyaXB0aW9uEh0KCmF1dG9fZW50ZXIYBCABKAhSCWF1dG9FbnRlchIjCg1kZXNpcmVkX3VzZXJzGAUgAygEUgxkZXNpcmVkVXNlcnM=');
@$core.Deprecated('Use chatDescriptor instead')
const Chat$json = const {
  '1': 'Chat',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    const {'1': 'permanent', '3': 2, '4': 1, '5': 8, '10': 'permanent'},
    const {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    const {'1': 'users', '3': 4, '4': 3, '5': 4, '10': 'users'},
    const {'1': 'created', '3': 5, '4': 1, '5': 4, '10': 'created'},
  ],
};

/// Descriptor for `Chat`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatDescriptor = $convert.base64Decode('CgRDaGF0Eg4KAmlkGAEgASgEUgJpZBIcCglwZXJtYW5lbnQYAiABKAhSCXBlcm1hbmVudBIgCgtkZXNjcmlwdGlvbhgDIAEoCVILZGVzY3JpcHRpb24SFAoFdXNlcnMYBCADKARSBXVzZXJzEhgKB2NyZWF0ZWQYBSABKARSB2NyZWF0ZWQ=');
@$core.Deprecated('Use chatReferenceDescriptor instead')
const ChatReference$json = const {
  '1': 'ChatReference',
  '2': const [
    const {'1': 'user_id', '3': 1, '4': 1, '5': 4, '10': 'userId'},
    const {'1': 'chat_id', '3': 2, '4': 1, '5': 4, '10': 'chatId'},
  ],
};

/// Descriptor for `ChatReference`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatReferenceDescriptor = $convert.base64Decode('Cg1DaGF0UmVmZXJlbmNlEhcKB3VzZXJfaWQYASABKARSBnVzZXJJZBIXCgdjaGF0X2lkGAIgASgEUgZjaGF0SWQ=');
@$core.Deprecated('Use invitationDescriptor instead')
const Invitation$json = const {
  '1': 'Invitation',
  '2': const [
    const {'1': 'from_user_id', '3': 1, '4': 1, '5': 4, '10': 'fromUserId'},
    const {'1': 'to_user_id', '3': 2, '4': 1, '5': 4, '10': 'toUserId'},
    const {'1': 'chat_id', '3': 3, '4': 1, '5': 4, '10': 'chatId'},
  ],
};

/// Descriptor for `Invitation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List invitationDescriptor = $convert.base64Decode('CgpJbnZpdGF0aW9uEiAKDGZyb21fdXNlcl9pZBgBIAEoBFIKZnJvbVVzZXJJZBIcCgp0b191c2VyX2lkGAIgASgEUgh0b1VzZXJJZBIXCgdjaGF0X2lkGAMgASgEUgZjaGF0SWQ=');
@$core.Deprecated('Use resultDescriptor instead')
const Result$json = const {
  '1': 'Result',
  '2': const [
    const {'1': 'ok', '3': 1, '4': 1, '5': 8, '10': 'ok'},
    const {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `Result`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resultDescriptor = $convert.base64Decode('CgZSZXN1bHQSDgoCb2sYASABKAhSAm9rEiAKC2Rlc2NyaXB0aW9uGAIgASgJUgtkZXNjcmlwdGlvbg==');
@$core.Deprecated('Use attachmentDescriptor instead')
const Attachment$json = const {
  '1': 'Attachment',
  '2': const [
    const {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.migchat.AttachmentType', '10': 'type'},
    const {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    const {'1': 'content', '3': 3, '4': 1, '5': 12, '10': 'content'},
  ],
};

/// Descriptor for `Attachment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachmentDescriptor = $convert.base64Decode('CgpBdHRhY2htZW50EisKBHR5cGUYASABKA4yFy5taWdjaGF0LkF0dGFjaG1lbnRUeXBlUgR0eXBlEhIKBG5hbWUYAiABKAlSBG5hbWUSGAoHY29udGVudBgDIAEoDFIHY29udGVudA==');
@$core.Deprecated('Use postDescriptor instead')
const Post$json = const {
  '1': 'Post',
  '2': const [
    const {'1': 'id', '3': 1, '4': 1, '5': 4, '10': 'id'},
    const {'1': 'user_id', '3': 2, '4': 1, '5': 4, '10': 'userId'},
    const {'1': 'chat_id', '3': 3, '4': 1, '5': 4, '10': 'chatId'},
    const {'1': 'text', '3': 4, '4': 1, '5': 9, '10': 'text'},
    const {'1': 'created', '3': 5, '4': 1, '5': 4, '10': 'created'},
    const {'1': 'attachments', '3': 9, '4': 3, '5': 11, '6': '.migchat.Attachment', '10': 'attachments'},
  ],
};

/// Descriptor for `Post`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List postDescriptor = $convert.base64Decode('CgRQb3N0Eg4KAmlkGAEgASgEUgJpZBIXCgd1c2VyX2lkGAIgASgEUgZ1c2VySWQSFwoHY2hhdF9pZBgDIAEoBFIGY2hhdElkEhIKBHRleHQYBCABKAlSBHRleHQSGAoHY3JlYXRlZBgFIAEoBFIHY3JlYXRlZBI1CgthdHRhY2htZW50cxgJIAMoCzITLm1pZ2NoYXQuQXR0YWNobWVudFILYXR0YWNobWVudHM=');
@$core.Deprecated('Use historyParamsDescriptor instead')
const HistoryParams$json = const {
  '1': 'HistoryParams',
  '2': const [
    const {'1': 'chat_id', '3': 1, '4': 1, '5': 4, '10': 'chatId'},
    const {'1': 'idx_from', '3': 2, '4': 1, '5': 4, '10': 'idxFrom'},
    const {'1': 'count', '3': 3, '4': 1, '5': 4, '10': 'count'},
  ],
};

/// Descriptor for `HistoryParams`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List historyParamsDescriptor = $convert.base64Decode('Cg1IaXN0b3J5UGFyYW1zEhcKB2NoYXRfaWQYASABKARSBmNoYXRJZBIZCghpZHhfZnJvbRgCIAEoBFIHaWR4RnJvbRIUCgVjb3VudBgDIAEoBFIFY291bnQ=');
@$core.Deprecated('Use chatHistoryDescriptor instead')
const ChatHistory$json = const {
  '1': 'ChatHistory',
  '2': const [
    const {'1': 'posts', '3': 1, '4': 3, '5': 11, '6': '.migchat.Post', '10': 'posts'},
  ],
};

/// Descriptor for `ChatHistory`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatHistoryDescriptor = $convert.base64Decode('CgtDaGF0SGlzdG9yeRIjCgVwb3N0cxgBIAMoCzINLm1pZ2NoYXQuUG9zdFIFcG9zdHM=');
