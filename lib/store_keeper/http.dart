import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'mutation.dart';
import 'package:meta/meta.dart';

class HTTPClient {
  static Future<Response> send(Request request) async {
    http.BaseRequest _request;

    var uri = Uri.parse(request.url)..replace(queryParameters: request.params);
    print(request.params);
    print(uri.toString());

    if (request.bodyFiles == null) {
      _request = http.Request(request.method, uri);

      if (request.body != null) (_request as http.Request).body = request.body;
      if (request.bodyBytes != null)
        (_request as http.Request).bodyBytes = request.bodyBytes;
      if (request.bodyFields != null)
        (_request as http.Request).bodyFields = request.bodyFields;
      if (request.bodyJSON != null) {
        (_request as http.Request).body = json.encode(request.bodyJSON);
        _request.headers['content-type'] = 'application/json';
      }
    } else {
      _request = http.MultipartRequest(request.method, uri);
      (_request as http.MultipartRequest).files.addAll(request.bodyFiles);
      if (request.bodyFields != null)
        (_request as http.MultipartRequest).fields.addAll(request.bodyFields);
    }
    _request.headers.addAll(request.headers);

    var _response = await http.Response.fromStream(await _request.send());

    print(_response.statusCode);

    return Response(
      statusCode: _response.statusCode,
      headers: _response.headers,
      body: _response.body,
    );
  }
}

class Request {
  final String method;
  final String url;
  final Map<String, String> params;
  final Map<String, String> headers;
  final String body;
  final List<int> bodyBytes;
  final Map<String, String> bodyFields;
  final Map<String, String> bodyJSON;
  final List<http.MultipartFile> bodyFiles;

  Request({
    this.method = "GET",
    @required this.url,
    this.params = const {},
    this.headers = const {},
    this.body,
    this.bodyBytes,
    this.bodyFields,
    this.bodyFiles,
    this.bodyJSON,
  });
}

class Response {
  final int statusCode;
  final String body;
  final Map<String, String> headers;

  Response({
    this.statusCode,
    this.headers,
    this.body,
  });

  static Response get instance => Response();
}

class HttpEffects implements SideEffects<Request, Future<Response>> {
  Future<void> future;

  @override
  Future<Response> branch(Request result) async {
    var completer = Completer<void>();
    future = completer.future;
    Response response;
    try {
      Response response = await HTTPClient.send(result);

      if (response.statusCode == 200) {
        success(response);
      } else {
        fail(response);
      }
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
