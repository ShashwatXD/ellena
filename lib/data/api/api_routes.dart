abstract final class ApiRoutes {
  static String geminiStreamGenerateContent(String model) =>
      '/v1beta/models/$model:streamGenerateContent';
}
