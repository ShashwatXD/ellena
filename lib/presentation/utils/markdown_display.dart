String visibleMarkdown(String text) {
  if ('```'.allMatches(text).length.isEven) return text;
  final body = text.endsWith('\n') ? text : '$text\n';
  return '$body```\n';
}
