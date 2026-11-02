part of 'chat.dart';

@freezed
abstract class ChatReaction with _$ChatReaction {
  const factory ChatReaction({
    required String emoji,
    required int count,
    @Default(<String>[]) List<String> userIds,
    @Default(<String>[]) List<String> names,
  }) = _ChatReaction;

  factory ChatReaction.fromJson(Map<String, dynamic> json) => _$ChatReactionFromJson(json);
}
