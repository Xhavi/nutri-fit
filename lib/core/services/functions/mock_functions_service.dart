import 'functions_service.dart';

class MockFunctionsService implements FunctionsService {
  @override
  Future<Map<String, dynamic>?> call(
    String functionName, {
    Map<String, dynamic>? payload,
  }) async {
    return <String, dynamic>{
      'function': functionName,
      'payload': payload,
      'mock': true,
    };
  }
}
