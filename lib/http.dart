import 'dart:async';
import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'store_keeper.dart';
import 'package:flutter/foundation.dart' show required;
import 'dart:typed_data';

abstract class HTTPInterceptor {
  Future beforeRequest(Request request);
  Future afterResponse(Response response);
}

class HTTPClient {
  // timeout to get a tcp connection with server
  static int connectTimeout = 8;
  // timeout to get first byte after the request. only for GET
  static int writeTimeout = 5;
  // timeout to get complete response from server. only for GET
  static int readTimeout = 20;

  static HttpClient client = HttpClient();
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

    // start network request
    // read and write timeouts are only for GET requests
    // because others should not get cancelled mid flight

    // connection timeout
    var httpClientReq =
        await client.openUrl(_request.method, _request.url).timeout(
      Duration(seconds: request.connectTimeout),
      onTimeout: () {
        throw TimeoutException("Connection timeout. Retry.");
      },
    );

    // add all headers
    _request.headers.forEach((key, val) {
      httpClientReq.headers.add(key, val);
    });

    // convert body to byte stream
    var bodyStream = _request.finalize();
    httpClientReq.add((await bodyStream.toBytes()).toList());

    // write timeout
    var httpClientRes = await (_request.method == "GET"
        ? httpClientReq.close().timeout(
            Duration(seconds: request.writeTimeout),
            onTimeout: () {
              throw TimeoutException("Network error. No response.");
            },
          )
        : httpClientReq.close());

    // convert byte stream to byte list

    // read timeout
    List<List<int>> packets = await (_request.method == "GET"
        ? httpClientRes.toList().timeout(
            Duration(seconds: request.readTimeout),
            onTimeout: () {
              throw TimeoutException("Connection too slow. Retry.");
            },
          )
        : httpClientRes.toList());

    List<int> bytes = [];
    packets.forEach((buff) => bytes.addAll(buff));

    // join header values
    Map<String, String> resHeaders = {};
    httpClientRes.headers.forEach((key, values) {
      resHeaders[key] = values.join(",");
    });

    // end network request

    var res = Response(
      statusCode: httpClientRes.statusCode,
      headers: resHeaders,
      body: bytes.toList(),
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
  int connectTimeout;
  int readTimeout;
  int writeTimeout;

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
    connectTimeout ??= HTTPClient.connectTimeout;
    readTimeout ??= HTTPClient.readTimeout;
    writeTimeout ??= HTTPClient.writeTimeout;
  }
}

class Response {
  Request request;
  int statusCode;
  List<int> body;
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

    try {
      response = await HTTPClient.send(result);
    } catch (e) {
      _completer.complete();
      throw e;
    }

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
