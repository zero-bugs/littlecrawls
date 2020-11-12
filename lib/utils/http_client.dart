import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dtspider/common/config.dart';
import 'package:dtspider/common/proxy_config.dart';
import 'package:dtspider/db/wh_constant.dart';
import 'package:dtspider/db/wh_db_impl.dart';
import 'package:dtspider/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as ioclient;
import 'package:uuid/uuid.dart';

import 'logging.dart';

class GtClient {
  static Dio dio = Dio(BaseOptions(
    baseUrl: 'https://github.com',
//  headers: {
//    HttpHeaders.acceptHeader: "application/vnd.github.squirrel-girl-preview,"
//        "application/vnd.github.symmetra-preview+json, application/json",
//    HttpHeaders.contentTypeHeader: 'application/json',
//  },
    connectTimeout: 5000,
    receiveTimeout: 30000,
  ));

  static bool isInit = false;

  static init() async {
    //不校验证书
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          ((X509Certificate cert, String host, int port) {
        print('graphql->x509 certificate $cert, host:$host, port:$port');
        return true;
      });

      return client;
    };
  }

  static getInstance() {
    if (!isInit) {
      isInit = true;
    }
    return dio;
  }
}

int httpClientCount = 0;
const int httpMaxUseTime = 10;
ioclient.IOClient constructNoTrustClient() {
  print("construct no trust certificate success");
  var _httpClient = HttpClient();
  _httpClient.badCertificateCallback =
      ((X509Certificate cert, String host, int port) {
    print('graphql->x509 certificate $cert, host:$host, port:$port');
    return true;
  });

  if (isProxyOpen) {
    _httpClient.findProxy = ((uri) {
      return "PROXY $proxyHost:$proxyPort";
    });
    _httpClient.addProxyCredentials('$proxyHost', proxyPort, 'admin',
        HttpClientBasicCredentials('$proxyUser', '$proxyPwd'));
  }

  _httpClient.connectionTimeout = Duration(seconds: 90);

  return ioclient.IOClient(_httpClient);
}

http.Client httpClient = constructNoTrustClient();

String whCookies = '';
List<String> cookieNamePrefixList = [
  '__cfduid',
  'XSRF-TOKEN',
  'wallhaven_session',
  'remember_web'
];

// 其中_pk_id.1.01b8每1个小时更新一次，原始cookie有效期1年
var traceCookie = ['_pk_id.1.01b8', '_pk_ses.1.01b8'];
DateTime lastUpdateUuidTime;
DateTime lastUpdateCookieTime;

httpRequest(
  String url, {
  String type: 'get',
  Map<String, String> headers,
  body,
  Encoding encoding,
  bool useCookie: true,
}) async {
  if (url == null) {
    return;
  }

  // 添加通用头域
  headers['user-agent'] =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36';
  headers['origin'] = '$whUrlAddress';
  headers['accept'] =
      'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9';
  // headers['pragma'] = 'no-cache';
  if (!isEmpty(whCookies) && useCookie) {
    headers['cookie'] = whCookies;
  }

  //print('begin to execute http request, cookies:$whCookies');
  var response = await _httpRequestRetryExecutor(
    url,
    type: type,
    body: body,
    headers: headers,
    encoding: encoding,
  );

  if (response != null && response.statusCode < 400) {
    // 更新cookies
    updateCookies(response.headers['set-cookie'], useCookie: useCookie);
  } else {
    print(
        'request exception, status code:${response?.statusCode},url:${url}\n, '
        'request header:${response?.request?.headers?.toString()}\n,'
        'response headers:${response?.headers?.toString()}\n,'
        'response body:${response?.body}\n');
  }
  //print('end to execute http request, cookies:$whCookies');
  return response;
}

Future _httpRequestRetryExecutor(
  url, {
  type: 'get',
  body,
  headers,
  encoding,
}) async {

  ++httpClientCount;
  if (httpClientCount > httpMaxUseTime) {
    LogUtils.log.warning('http client max use exceed max times[$httpMaxUseTime], rebuild it.');
    await httpClient.close();
    httpClient = constructNoTrustClient();
    httpClientCount = 0;
  }

  int reqCount = 0;
  while (reqCount < maxRetryCount) {
    var response;
    try {
      ++reqCount;
      switch (type) {
        case 'post':
          print('post url:$url');
          response = await httpClient.post(url,
              body: body, headers: headers, encoding: encoding);
          break;
        case 'get':
        default:
          print('get url:$url');
          response = await httpClient.get(url, headers: headers);
          break;
      }
    } on Exception catch (e) {
      LogUtils.log.warning('execute http request:$url failed\n.$e');
      continue;
    }

    if (response == null) {
      continue;
    }

    return response;
  }
}

void updateWipikId(Map<String, String> currentMap) {
  if (currentMap == null) return;
  if (lastUpdateUuidTime == null) {
    var uuid = Uuid()
        .v5(Uuid.NAMESPACE_OID,
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36')
        .replaceAll(RegExp(r'-'), '')
        .substring(0, 16);
    var curTime = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    currentMap[traceCookie[0]] = '$uuid.$curTime.1.$curTime.$curTime';
    currentMap[traceCookie[1]] = '1';
    lastUpdateUuidTime = DateTime.now();

    print(
        'begin to update uuid, ${traceCookie[0]}:${currentMap[traceCookie[0]]}, ${traceCookie[1]}:${currentMap[traceCookie[1]]}');
    return;
  }

  // 1个小时更新1次
  if (DateTime.now().difference(lastUpdateUuidTime).inHours > 1) {
    print('begin to update uuid');
    var uuid = Uuid()
        .v5(
            Uuid.NAMESPACE_OID,
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.75 Safari/537.36'
            '${DateTime.now().toString()}${Random(DateTime.now().millisecondsSinceEpoch)}')
        .replaceAll(RegExp(r'-'), '')
        .substring(0, 16);
    var curTime = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    currentMap[traceCookie[0]] = '$uuid.$curTime.1.$curTime.$curTime';
    currentMap[traceCookie[1]] = '1';
    lastUpdateUuidTime = DateTime.now();
  }
}

void updateCookies(String cookie, {bool useCookie: true}) {
  if (!useCookie) {
    return;
  }

  print('begin to update cookies');
  Map<String, String> respCookieMap = parseCookiesToMap(cookie);
  Map<String, String> currentCookieMap = parseCookiesToMap(whCookies);
  respCookieMap.forEach((key, value) {
    if (cookieNamePrefixList.any((element) => key.startsWith(element))) {
      currentCookieMap[key] = value;
    }
  });

  updateWipikId(currentCookieMap);
  whCookies = mergeCookieMapToStr(currentCookieMap);

  //每30分钟插入一次cookie
  if (lastUpdateCookieTime == null ||
      DateTime.now().difference(lastUpdateCookieTime).inMinutes > 30 &&
          !isEmpty(whCookies)) {
    WhDbServiceImpl().insertCookieInfo(whCookies);
    lastUpdateCookieTime = DateTime.now();
  }
}

// 字符串转换成map
Map<String, String> parseCookiesToMap(String cookies) {
  Map<String, String> setCookieMap = Map<String, String>();
  if (isEmpty(cookies)) {
    return setCookieMap;
  }

  cookies.replaceAll(RegExp(r','), ';').split(';')?.forEach((e) {
    if (!isEmpty(e.trim())) {
      if (cookieNamePrefixList.any((element) => e.contains(element))) {
        var eleLst = e.split('=');
        if (eleLst?.length >= 2) {
          setCookieMap[eleLst[0].trim()] = eleLst[1].trim();
        } else {
          print('set cookie key:[${e}] without value');
        }
      }
    }
  });
  return setCookieMap;
}

// map转换成字符串
String mergeCookieMapToStr(Map<String, String> cookiesMap) {
  var cookie = "";
  cookiesMap.forEach((key, value) {
    cookie += '$key=$value; ';
  });
  return cookie?.trim()?.replaceAll(RegExp(r';$'), '');
}
