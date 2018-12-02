import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'mutation.dart';

export 'package:http/http.dart' show Request, Response;

class HttpEffects implements SideEffects<Request, Future<Response>> {
  Future<void> future;

  @override
  Future<Response> branch(Request result) async {
    var completer = Completer<void>();
    future = completer.future;
    Response response;
    try {
      response = await Response.fromStream(await result.send());
      if (response.statusCode == 200)
        success(response);
      else
        fail(response);
    } on Exception catch (e, s) {
      error(e, s);
    }

    completer.complete();
    return response;
  }

  void success(Response response) {}
  void fail(Response response) {}
  void error(Exception exception, StackTrace stackTrace) {}
}

Request HttpRequest({
  String method,
  String url,
  Map<String, String> params,
  Map<String, String> headers,
  String body,
  List<int> bodyBytes,
  Map<String, String> bodyFields,
  Map<String, String> bodyJSON,
  List<MultipartFile> bodyFiles,
}) {
  var uri = Uri.parse(url)..queryParameters.addAll(params);
  BaseRequest request;
  if (bodyFiles == null) {
    request = Request(method, uri);

    if (body != null) (request as Request).body = body;
    if (bodyBytes != null) (request as Request).bodyBytes = bodyBytes;
    if (bodyFields != null) (request as Request).bodyFields = bodyFields;
    if (bodyJSON != null) {
      (request as Request).body = json.encode(bodyJSON);
      request.headers['content-type'] = 'application/json';
    }
  } else {
    request = MultipartRequest(method, uri);
    (request as MultipartRequest).files.addAll(bodyFiles);
    if (bodyFields != null)
      (request as MultipartRequest).fields.addAll(bodyFields);
  }
  request.headers.addAll(headers);

  return request;
}
