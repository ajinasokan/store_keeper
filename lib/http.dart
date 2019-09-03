import 'dart:async';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'mutation.dart';
import 'package:flutter/foundation.dart' show required;
import 'dart:typed_data';

abstract class HTTPInterceptor {
  Future beforeRequest(Request request);
  Future afterResponse(Response response);
}

class HTTPClient {
  static List<HTTPInterceptor> interceptors = [];

  static Future<Response> send(Request request) async {
    // process interceptors
    for (var i in interceptors) {
      var _fut = i.beforeRequest(request);
      if (_fut != null) await _fut;
    }

    // make actual request
    http.BaseRequest _request;

    var uri = Uri.parse(request.url).replace(queryParameters: request.params);

    if (request.bodyFiles == null) {
      _request = http.Request(request.method, uri);

      if (request.body != null) (_request as http.Request).body = request.body;
      if (request.bodyBytes != null)
        (_request as http.Request).bodyBytes = request.bodyBytes;
      if (request.bodyFields != null) {
        (_request as http.Request).bodyFields = request.bodyFields;
        _request.headers['content-type'] =
            'application/x-www-form-urlencoded; charset=utf-8';
      }
      if (request.bodyJSON != null) {
        (_request as http.Request).body = convert.json.encode(request.bodyJSON);
        _request.headers['content-type'] = 'application/json; charset=utf-8';
      }
    } else {
      _request = http.MultipartRequest(request.method, uri);
      (_request as http.MultipartRequest).files.addAll(request.bodyFiles);
      if (request.bodyFields != null)
        (_request as http.MultipartRequest).fields.addAll(request.bodyFields);
    }
    _request.headers.addAll(request.headers);

    var _response = await http.Response.fromStream(await _request.send());

    var res = Response(
      statusCode: _response.statusCode,
      headers: _response.headers,
      body: _response.bodyBytes,
    );
    res.request = request;

    // process interceptors
    for (var i in interceptors) {
      var _fut = i.afterResponse(res);
      if (_fut != null) await _fut;
    }

    return res;
  }
}

class Request {
  String method;
  String url;
  Map<String, String> params;
  Map<String, String> headers;
  String body;
  List<int> bodyBytes;
  Map<String, String> bodyFields;
  Map<String, String> bodyJSON;
  List<http.MultipartFile> bodyFiles;
  Response success;
  Response fail;
  Map<String, dynamic> meta;

  Request({
    this.method,
    @required this.url,
    this.params,
    this.headers,
    this.body,
    this.bodyBytes,
    this.bodyFields,
    this.bodyFiles,
    this.bodyJSON,
    this.success,
    this.fail,
    this.meta,
  }) {
    method ??= "GET";
    params ??= {};
    headers ??= {};
    success ??= Response();
    fail ??= Response();
    meta ??= {};
  }
}

class Response {
  Request request;
  int statusCode;
  Uint8List body;
  Map<String, String> headers;
  String Function(List<int> codeUnits) decode;

  Response({
    this.statusCode,
    this.headers,
    this.body,
  });

  String text() {
    if (decode != null)
      return decode(body);
    else
      return convert.utf8.decode(body);
  }

  Map json() => convert.json.decode(text());

  void parse() {}
}

abstract class HttpEffects<S extends Response, F extends Response>
    implements SideEffects<Request> {
  var _completer = Completer<void>();
  Future<void> get future => _completer.future;

  Response response;

  @override
  Future<void> branch(Request result) async {
    assert(result.success is S, "Provide correct success model to request.");
    assert(result.fail is F, "Provide correct fail model to request.");

    response = await HTTPClient.send(result);

    if (response.statusCode == 200) {
      result.success.statusCode = response.statusCode;
      result.success.body = response.body;
      result.success.headers = response.headers;
      result.success.decode ??= response.decode;
      result.success.request = result;
      result.success.parse();

      success(result.success);
    } else {
      result.fail.statusCode = response.statusCode;
      result.fail.body = response.body;
      result.fail.headers = response.headers;
      result.fail.decode ??= response.decode;
      result.fail.request = result;
      result.fail.parse();

      fail(result.fail);
    }

    _completer.complete();
  }

  void success(S response) {}
  void fail(F response) {}
}
