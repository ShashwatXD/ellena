import '../../core/models/conversation.dart';

Conversation preferLater({
  required Conversation local,
  required Conversation remote,
}) {
  if (remote.updatedAt.isAfter(local.updatedAt)) return remote;
  return local;
}
