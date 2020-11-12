//https://bz.zzzmh.cn/#anime

import 'dart:convert';

import 'package:dtspider/model/bz_paper_items.dart';
import 'package:dtspider/utils/http_client.dart';

String BZ_ZZZMH_ADDRESS = 'https://api.zzzmh.cn/bz';

//获取json数据，target可以为index、anime
Future<BzzzzmhItems> getBzAnimeFromJson({
  String target: 'anime',
  int current: 1,
}) async {
  var requestBody = {'target': '$target', 'pageNum': '$current'};

  var resp = await httpClient.post(
    BZ_ZZZMH_ADDRESS + '/getJson',
    headers: {
      'referer': 'https://bz.zzzmh.cn/',
      'origin': 'https://bz.zzzmh.cn',
      'access':
          '0592cdb2efa5fde6ea96f6478cd01ed047c37fb5cf21dd6297cf4fff167276df',
      'location': 'bz.zzzmh.cn',
      'sign': 'facb9d7ee849d171cbf57ba899651819',
    },
    body: requestBody,
  );
  print(resp.body);
  return BzzzzmhItems.fromJson(json.decode(resp.body)['result']);
}
