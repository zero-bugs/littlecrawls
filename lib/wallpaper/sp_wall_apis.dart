import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dtspider/db/wh_picattr_dao.dart';
import 'package:dtspider/model/wh_paper_items.dart';
import 'package:dtspider/utils/http_client.dart';

startSearchUseApi({
  String url,
  int currentPage: 1,
  int totalPage: 2,
}) async {
  print('begin to execute search url:$url');
  var rand = Random(DateTime.now().millisecondsSinceEpoch);
  while (currentPage <= totalPage) {
    var curUrl = url.contains('?')
        ? url + '&page=$currentPage'
        : url + '?page=$currentPage';

    var data = await httpRequestWithExcepHandle(curUrl);
    if (data == null) {
      print('something wrong ');
      continue;
    }
    var meta = data['meta'];
    print(
        'current page:${meta['current_page']}, last page:${meta['last_page']}, total:${meta['total']}, query:${meta['query']}, seed:${meta['seed']}');

    currentPage = meta['current_page'] as int;
    totalPage = meta['last_page'] as int;
    var seed = meta['seed'];
    ++currentPage;

    List<WallPicAttr> picList = List<WallPicAttr>();
    var value = data['data'] as List;
    value?.forEach((element) {
      WallPicAttr pic = WallPicAttr(
        colors: List<String>(),
        tags: List<WallPicTag>(),
        type: PicType.fullSize,
      );
      pic.id = element['id'];
      pic.size = '${element['file_size']}';
      pic.category = element['category'];
      pic.purity = element['purity'];
      pic.viewsCount = '${element['views']}';
      pic.favsCount = '${element['favorites']}';
      pic.datetime = element['created_at'];
      pic.resolution = ImgResolution(
          height: '${element['dimension_x']}',
          width: '${element['dimension_y']}');
      pic.resourceHref = element['url'];
      pic.downloadLink = element['path'];
      pic.relatedHref = '';
      (element['colors'] as List).forEach((c) {
        pic.colors.add(c as String);
      });
      picList.add(pic);
    });

    for (var p in picList) {
      await WhPicAttrDao().insertOneImage(p);
    }

    await sleep(Duration(milliseconds: (rand.nextInt(400) + 800)));
  }
}

Future httpRequestWithExcepHandle(String url) async {
  try {
    print('current url:$url');
    var resp = await httpClient.get(url);
    if (resp.statusCode != 200) {
      print('url:$url, resp:${resp.statusCode}, message:${resp.body}');
    }

    var data = json.decode(resp.body);
    return data;
  } catch (e) {
    print('http exception, url:$url, e:${e.toString()}');
  }
}
