///
//  Generated code. Do not modify.
//  source: migchat.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,unnecessary_const,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type,unnecessary_this,prefer_final_fields

// ignore_for_file: UNDEFINED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class AttachmentType extends $pb.ProtobufEnum {
  static const AttachmentType None = AttachmentType._(0, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'None');
  static const AttachmentType Image = AttachmentType._(1, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'Image');
  static const AttachmentType Audio = AttachmentType._(2, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'Audio');
  static const AttachmentType Video = AttachmentType._(3, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'Video');
  static const AttachmentType File = AttachmentType._(4, const $core.bool.fromEnvironment('protobuf.omit_enum_names') ? '' : 'File');

  static const $core.List<AttachmentType> values = <AttachmentType> [
    None,
    Image,
    Audio,
    Video,
    File,
  ];

  static final $core.Map<$core.int, AttachmentType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static AttachmentType? valueOf($core.int value) => _byValue[value];

  const AttachmentType._($core.int v, $core.String n) : super(v, n);
}

