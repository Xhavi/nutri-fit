abstract class FunctionsService {
  Future<Map<String, dynamic>?> call(
    String functionName, {
    Map<String, dynamic>? payload,
  });
}
