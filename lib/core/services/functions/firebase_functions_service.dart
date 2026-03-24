import 'package:cloud_functions/cloud_functions.dart';

import 'functions_service.dart';

class FirebaseFunctionsService implements FunctionsService {
  FirebaseFunctionsService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  @override
  Future<Map<String, dynamic>?> call(
    String functionName, {
    Map<String, dynamic>? payload,
  }) async {
    final HttpsCallable callable = _functions.httpsCallable(functionName);
    final HttpsCallableResult<dynamic> result = await callable.call(payload ?? <String, dynamic>{});

    final dynamic data = result.data;
    if (data is Map<String, dynamic>) {
      return data;
    }

    return <String, dynamic>{'result': data};
  }
}
