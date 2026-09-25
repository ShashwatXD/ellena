abstract final class ApiRoutes {
  static String geminiStreamGenerateContent(String model) =>
      '/v1beta/models/$model:streamGenerateContent';

  static String geminiGenerateContent(String model) =>
      '/v1beta/models/$model:generateContent';

  static String historyUser(String installId) => '/api/users/$installId';

  static String historyChat(String installId, String chatId) =>
      '/api/users/$installId/chats/$chatId';
}
