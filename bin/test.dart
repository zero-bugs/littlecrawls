import 'dart:io';
import 'dart:math';

import 'package:dtspider/common/config.dart';
import 'package:dtspider/db/create_tables.dart';
import 'package:dtspider/db/sq_lite3_dao.dart';
import 'package:dtspider/db/wh_constant.dart';
import 'package:dtspider/utils/http_client.dart';
import 'package:dtspider/wallpaper/sp_wall_apis.dart';
import 'package:dtspider/wallpaper/sp_wall_haven.dart';
import 'package:dtspider/wallpaper/sp_wall_login.dart';

//https://w.wallhaven.cc/full/y8/wallhaven-y87v8k.jpg
void main() async {
  await DBProvider().initDB();

  // await startSearchUseApi(
  //   url:
  //       'https://wallhaven.cc/api/v1/search?purity=001&sorting=date_added&order=desc&seed=$randomSeed&apikey=$apiKey',
  // );
  //
  // await startSearchUseApi(
  //   url:
  //       'https://wallhaven.cc/api/v1/search?purity=010&sorting=date_added&order=desc&seed=$randomSeed&apikey=$apiKey',
  // );

  // await startSearchUseApi(
  //   url:
  //       'https://wallhaven.cc/api/v1/search?purity=100&sorting=date_added&order=desc&seed=$randomSeed&apikey=$apiKey',
  //   currentPage: 7963,
  //   totalPage: 17737,
  // );

  //total 165436
  await startDownloadFullSizeImg(purity: 'nsfw', offset: 23232);
  // await startDownloadFullSizeImg(purity: 'sketchy');
  // await startDownloadFullSizeImg(purity: 'sfw');
}
