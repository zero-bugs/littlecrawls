import 'dart:io';
import 'dart:math';

import 'package:dtspider/common/config.dart';
import 'package:dtspider/db/create_tables.dart';
import 'package:dtspider/db/wh_constant.dart';
import 'package:dtspider/db/wh_picattr_dao.dart';
import 'package:dtspider/db/wh_uploader_dao.dart';
import 'package:dtspider/model/wh_paper_items.dart';
import 'package:dtspider/utils/http_client.dart';
import 'package:dtspider/utils/logging.dart';
import 'package:dtspider/utils/utils.dart';
import 'package:dtspider/wallpaper/sp_wall_login.dart';
import 'package:html/parser.dart' show parse;
import 'package:image/image.dart';

Future<List<StandardPageItems>> _getPicFromStandardPage({
  String url: '$whUrlAddress/toplist',
  int page: 1,
}) async {
  List<StandardPageItems> resultList = List<StandardPageItems>();
  if (page >= 2) {
    url = url.contains('?') ? url + '&page=$page' : url + '?page=$page';
  }

  var resp = await httpRequest(url, type: 'get', headers: {});

  if (resp?.statusCode == 401) {
    // refresh cookies, again.
    await loginWallHaven();
    resp = await httpRequest(url, type: 'get', headers: {});
  } else if (resp?.statusCode != 200) {
    print('request url:$url, status code: ${resp.statusCode}');
    return resultList;
  }

  var document = parse(resp.body);
  var items = document.querySelectorAll('.thumb-listing-page');

  //抓取每页的图片
  if (items != null) {
    items.forEach((pageItem) {
      //抓取当前页面图片
      StandardPageItems resultItems = StandardPageItems(
        currentPage: 0,
        totalPage: 0,
        topListItem: List<StandardPageItem>(),
      );

      //获取页码信息
      var currentPg = pageItem
          .querySelector(
              '.thumb-listing-page-header h2 .thumb-listing-page-num')
          ?.innerHtml;
      if (currentPg != null) {
        resultItems.currentPage = int.parse(currentPg.trim());
        resultItems.totalPage = int.parse(pageItem
            .querySelector('.thumb-listing-page-header h2')
            ?.innerHtml
            ?.replaceAll(RegExp('.*/'), '')
            ?.trim());
      }

      pageItem.querySelectorAll('.thumb')?.forEach((element) async {
        var vItem = StandardPageItem(
          imgId: element?.attributes['data-wallpaper-id'],
          thumbNailImg: WallPicAttr(
            type: PicType.thumbnail,
          ),
          fullImg: WallPicAttr(
            type: PicType.fullSize,
          ),
        );

        //获取略缩图信息
        var styleRes = element.attributes['style']
            ?.replaceAll(RegExp(r'^.*width:'), '')
            ?.replaceAll(RegExp(r'height:'), '')
            ?.replaceAll('px', '')
            ?.split(';');
        vItem.thumbNailImg.resolution = ImgResolution(
            width: styleRes[0]?.trim(), height: styleRes[1].trim());
        vItem.thumbNailImg.id = element.attributes['data-wallpaper-id'];
        vItem.thumbNailImg.downloadLink =
            element.querySelector('img')?.attributes['data-src'];
        vItem.thumbNailImg.resourceHref =
            element.querySelector('.preview')?.attributes['href'];

        var favsItem =
            element.querySelector('.thumb-info')?.querySelector('.wall-favs');
        if (favsItem != null) {
          vItem.thumbNailImg.relatedHref = favsItem.attributes['data-href'];
          vItem.favs = favsItem.innerHtml
              ?.replaceAll(RegExp(r'"'), '')
              ?.replaceAll(RegExp(r'<.*'), '')
              ?.trim();
          vItem.fullImg.favsCount = vItem.favs;
          vItem.thumbNailImg.favsCount = vItem.favs;
        }

        resultItems.topListItem.add(vItem);
      });

      resultList.add(resultItems);
    });
  }
  return resultList;
}

// 根据图片full size地址获取图片：https://wallhaven.cc/w/zm1p2j
// example:https://wallhaven.cc/w/dg9233
// 方法2使用api接口：https://wallhaven.cc/api/v1/w/5w1561
Future<WallPicAttr> getFullSizeImage({
  String url,
}) async {
  WallPicAttr pic = WallPicAttr(
    type: PicType.fullSize,
    tags: List<WallPicTag>(),
    uploader: Uploader(),
    colors: List<String>(),
  );

  if (isEmpty(url)) return pic;

  var resp = await httpRequest(url, type: 'get', headers: {});

  //print("get full size resp:${resp.statusCode} , ${resp.toString()}");

  var document = await parse(resp.body);

  //获取分辨率
  var image = document.querySelector('.scrollbox')?.querySelector('img');
  if (image != null) {
    pic.id = image.attributes['data-wallpaper-id'];
    pic.description = image.attributes['alt'];
    pic.resourceHref = url;
    pic.downloadLink = image.attributes['src'];
    pic.resolution = ImgResolution(
      width: image.attributes['data-wallpaper-width'],
      height: image.attributes['data-wallpaper-height'],
    );
  }

  //获取颜色
  var colors = document
      .querySelector('.sidebar-background .color-palette')
      ?.querySelectorAll('.color');
  if (colors != null) {
    colors.forEach((color) {
      pic.colors
          .add(color?.attributes['style']?.replaceAll(RegExp(r'.*:'), ''));
    });
  }

  // 获取其他属性
  document
      .querySelector('.sidebar-content')
      ?.querySelectorAll('.sidebar-section')
      ?.forEach((sidebars) {
    var barType = sidebars.querySelector('h2')?.innerHtml;
    if (equalsIgnoreCase('Tags', barType)) {
      sidebars.querySelectorAll('.tag')?.forEach((tag) {
        var tagName = tag.querySelector('.tagname');
        pic.tags.add(WallPicTag(
          id: tag.attributes['id'],
          name: tagName?.innerHtml?.trim(),
          href: tagName?.attributes['href'],
          category: tagName?.attributes['title'],
        ));
      });

      pic.relatedHref =
          sidebars.querySelector('.smallbutton')?.attributes['href'];
    }

    if (equalsIgnoreCase('Properties', barType)) {
      var showUpload = sidebars.querySelector('.showcase-uploader');
      if (showUpload != null) {
        pic.uploader.userName =
            showUpload.querySelector('.username')?.innerHtml;
        pic.uploader.avatar =
            showUpload.querySelector('.username')?.attributes['href'];
        pic.uploader.avatarImg =
            'https:' + showUpload.querySelector('img')?.attributes['src'];
        pic.datetime = showUpload.querySelector('time')?.attributes['datetime'];
        pic.uploadTimeDescription = showUpload.querySelector('time')?.innerHtml;

        sidebars
            .querySelector('h2')
            .nextElementSibling
            ?.querySelectorAll('dt')
            ?.forEach((element) {
          if (equalsIgnoreCase(element.innerHtml?.trim(), 'Category')) {
            pic.category = element.nextElementSibling?.innerHtml
                ?.replaceAll(RegExp(r'.*\"'), '')
                ?.replaceAll(RegExp(r'\".*'), '')
                ?.trim();
          }

          if (equalsIgnoreCase(element.innerHtml?.trim(), 'Purity')) {
            pic.purity = element.nextElementSibling
                ?.querySelector('.purity')
                ?.innerHtml
                ?.trim();
          }

          if (equalsIgnoreCase(element.innerHtml?.trim(), 'Size')) {
            pic.size = element.nextElementSibling?.innerHtml
                ?.toLowerCase()
                ?.replaceAll(RegExp(r'.*\"'), '')
                ?.replaceAll(RegExp(r'\".*'), '')
                ?.trim();
          }

          if (equalsIgnoreCase(element.innerHtml?.trim(), 'Views')) {
            pic.viewsCount = element.nextElementSibling?.innerHtml
                ?.replaceAll(RegExp(r'.*\"'), '')
                ?.replaceAll(RegExp(r'\".*'), '')
                ?.replaceAll(',', '')
                ?.trim();
          }

          if (equalsIgnoreCase(element.innerHtml?.trim(), 'Favorites')) {
            pic.favsCount = element.nextElementSibling
                ?.querySelector('.overlay-anchor')
                ?.innerHtml
                ?.trim();
          }
        });
      }
    }
  });

  return pic;
}

//https://wallhaven.cc/search?categories=111&purity=010&topRange=1M&sorting=toplist&order=desc&page=2
void startSpiderTopListThumbPic() async {
  await _startSpiderThumbPicFromStandardPage(
    url:
        '$whUrlAddress/search?categories=$category&purity=$purity&topRange=1M&sorting=toplist&order=desc',
  );
}

//https://wallhaven.cc/search?categories=111&purity=010&sorting=random&order=desc&seed=JkYiv&page=2
void startSpiderRandomThumbPic() async {
  await _startSpiderThumbPicFromStandardPage(
    url:
        '$whUrlAddress/search?categories=$category&purity=$purity&sorting=random&order=desc&seed=$randomSeed',
  );
}

//https://wallhaven.cc/search?categories=111&purity=010&sorting=date_added&order=desc&page=2
void startSpiderLatestThumbPic() async {
  await _startSpiderThumbPicFromStandardPage(
    url:
        '$whUrlAddress/search?categories=$category&purity=$purity&sorting=date_added&order=desc',
  );
}

//https://wallhaven.cc/search?categories=111&purity=010&sorting=hot&order=desc&page=2
void startSpiderHottestThumbPic() async {
  await _startSpiderThumbPicFromStandardPage(
    url:
        '$whUrlAddress/search?categories=$category&purity=$purity&sorting=hot&order=desc',
  );
}

void startSpiderCustomSearch({
  String url,
}) async {
  await _startSpiderThumbPicFromStandardPage(
    url: url,
  );
}

void _startSpiderThumbPicFromStandardPage({
  String url: '$whUrlAddress/toplist',
}) async {
  int currentPg = 1;
  int totalPg = 2;
  var rand = Random(DateTime.now().millisecondsSinceEpoch);
  while (currentPg <= totalPg) {
    var items = await _getPicFromStandardPage(
      url: url,
      page: currentPg,
    );
    if (items == null) {
      print('something exception for this operation');
      return;
    }

    items.forEach((item) {
      currentPg = item.currentPage != 0 ? item.currentPage : currentPg;
      totalPg = item.totalPage != 0 ? item.totalPage : totalPg;
      item.topListItem.forEach((pic) {
        WhPicAttrDao()
            .insertOneImage(pic.thumbNailImg, tableName: '$thumbPicAttrTable');
      });
    });

    print('current page:$currentPg, total page:$totalPg');

    ++currentPg;

    //限制访问网页的频率，每分钟50次，单次平均1.2s
    await sleep(Duration(milliseconds: (rand.nextInt(400) + 1000)));
  }
}

startSpiderFullSizeImg() async {
  int limit = 100;
  int offset = 0;
  var rand = Random(DateTime.now().millisecondsSinceEpoch);
  while (true) {
    print('begin to get full size image,limit:$limit, offset:$offset');
    var imgList = await WhPicAttrDao().getFullPicResourceRefFromThumbTab(
      limit: limit,
      offset: offset,
    );
    if (imgList == null || imgList.isEmpty) {
      print('get full size image end.');
      break;
    }

    for (var url in imgList) {
      var img = await getFullSizeImage(url: url);
      await WhPicAttrDao().insertOneImage(
        img,
        tableName: '$fullPicAttrTable',
      );
      WhUploaderDao().insertUploader(img.uploader);
      await sleep(Duration(milliseconds: (rand.nextInt(400) + 800)));
    }
    offset += limit;
  }

  print('all tasks end.');
}

startDownloadFullSizeImg({
  String category,
  String purity,
  int offset: 0,
}) async {
  int limit = 100;
  int totalCount = offset;
  // var rand = Random(DateTime.now().millisecondsSinceEpoch);
  while (true) {
    var imgList = await WhPicAttrDao().getFullPicUrlromFullTab(
      limit: limit,
      offset: offset,
      category: category,
      purity: purity,
    );

    if (imgList == null || imgList.isEmpty) {
      print('get full size image end.');
      break;
    }

    for (var pic in imgList) {
      ++totalCount;
      print(
          'begin to download pic:${pic.downloadLink}, total count:${totalCount}');

      var time = DateTime.now();

      //do not download it any more if it exist
      var filename = pic.downloadLink
          .substring(pic.downloadLink.lastIndexOf(RegExp(r'/')) + 1)
          ?.toLowerCase();
      String directory = '$downloadRootPath/${pic.category}/${pic.purity}';

      // Save the thumbnail as a PNG.
      var direct = Directory('$directory');
      if (!await direct.exists()) {
        direct.createSync(recursive: true);
      }

      var fullFileName = '$directory/$filename';
      if (await File(fullFileName).exists()) {
        print('pic [$filename] exists, continue..');
        continue;
      }

      var resp = await httpRequest(
        pic.downloadLink,
        type: 'get',
        useCookie: false,
        headers: {},
      );

      print(
          'download pic time consume:${DateTime.now().difference(time).inMilliseconds}ms');
      if (resp == null || resp.statusCode > 204) {
        print(
            'pic not exist any more, status code:${resp?.statusCode} url:${pic.downloadLink}');
        continue;
      }

      // Read an image from http body
      try {
        Image image = decodeNamedImage(resp.bodyBytes, filename);

        print('begin to write pic ${direct.path}/$filename');

        File('${direct.path}/$filename')
          ..writeAsBytesSync(encodeNamedImage(image, filename));
      } catch (e) {
        LogUtils.log.warning('decode image:${pic.downloadLink} failed.\n $e');
      }

      print(
          'download pic end. total time consume:${DateTime.now().difference(time).inMilliseconds}ms');
      print('----${DateTime.now().toIso8601String()}---');
      // await sleep(Duration(milliseconds: (rand.nextInt(100) + 100)));
    }
    offset += limit;
  }

  print('all tasks end.');
}

// TODO 根据tag页面信息抓取相关图片：https://wallhaven.cc/tag/54059
Future<List<WallPicAttr>> getPicFromTagPage({
  String url,
}) async {}
