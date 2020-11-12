import 'dart:io';

import 'package:dtspider/common/config.dart';
import 'package:dtspider/common/user_config.dart';
import 'package:dtspider/db/wh_db_impl.dart';
import 'package:dtspider/utils/http_client.dart';
import 'package:dtspider/utils/utils.dart';
import 'package:html/parser.dart';

loginWallHaven() async {
  var cachedCookie = await WhDbServiceImpl().getCookie();
  if (!isEmpty(cachedCookie)) {
    print('use cached cookie->[$cachedCookie]');
    print('welcome ${userName} to access WallHaven again.');
    whCookies = cachedCookie;
    return;
  }

  var url = '$whUrlAddress/login';
  var resp = await httpRequest(url, type: 'get', headers: {});
  if (resp == null || resp.statusCode > 400) {
    print(
        'get login page failed. http code:${resp.statusCode}, msg:${resp.toString()}');
    return;
  }

  var document = await parse(resp.body);
  var loginForm = document.querySelector(
      '.auth-form form[action~="https://wallhaven.cc/auth/login"]');
  if (loginForm != null) {
    var token =
        loginForm.querySelector('input[name="_token"]')?.attributes['value'];
    print('login page token:$token');

    await sleep(Duration(seconds: 2));
    // send request to login
    resp = await httpRequest('$whUrlAddress/auth/login', type: 'post', body: {
      '_token': '$token',
      'username': '$userName',
      'password': '$userCred'
    }, headers: {
      'referer': '$whUrlAddress/login',
      'origin': '$whUrlAddress',
      'sec-fetch-site': 'same-origin',
      'sec-fetch-dest': 'document',
      'sec-fetch-mode': 'navigate',
      'sec-fetch-user': '?1',
      'upgrade-insecure-requests': '1',
    });

    print(
        'login request code:${resp.statusCode}, headers:${resp.headers.toString()}');
    if (resp != null && resp.statusCode == 302) {
      print('get redirect location->${resp.headers['location']} success.');
      if (equalsIgnoreCase(
          resp.headers['location'], '$whUrlAddress/user/$userName')) {
        print('welcome ${userName} to access WallHaven.');
      } else {
        print('username or password is wrong, }');
      }
    } else {
      throw Exception('login in WallHaven failed.');
    }
  }
}
