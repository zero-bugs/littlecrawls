// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wh_paper_items.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StandardPageItems _$StandardPageItemsFromJson(Map<String, dynamic> json) {
  return StandardPageItems(
    currentPage: json['currentPage'] as int,
    totalPage: json['totalPage'] as int,
    topListItem: (json['topListItem'] as List)
        ?.map((e) => e == null
            ? null
            : StandardPageItem.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$StandardPageItemsToJson(StandardPageItems instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('currentPage', instance.currentPage);
  writeNotNull('totalPage', instance.totalPage);
  writeNotNull('topListItem', instance.topListItem);
  return val;
}

StandardPageItem _$StandardPageItemFromJson(Map<String, dynamic> json) {
  return StandardPageItem(
    imgId: json['imgId'] as String,
    favs: json['favs'] as String,
    fullImg: json['fullImg'] == null
        ? null
        : WallPicAttr.fromJson(json['fullImg'] as Map<String, dynamic>),
    thumbNailImg: json['thumbNailImg'] == null
        ? null
        : WallPicAttr.fromJson(json['thumbNailImg'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$StandardPageItemToJson(StandardPageItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('imgId', instance.imgId);
  writeNotNull('favs', instance.favs);
  writeNotNull('fullImg', instance.fullImg);
  writeNotNull('thumbNailImg', instance.thumbNailImg);
  return val;
}

WallPicTag _$WallPicTagFromJson(Map<String, dynamic> json) {
  return WallPicTag(
    id: json['id'] as String,
    name: json['name'] as String,
    alias: json['alias'] as String,
    href: json['href'] as String,
    category: json['category'] as String,
    categoryId: json['categoryId'] as String,
    purity: json['purity'] as String,
    createTime: json['createTime'] as String,
    description: json['description'] as String,
  );
}

Map<String, dynamic> _$WallPicTagToJson(WallPicTag instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('alias', instance.alias);
  writeNotNull('href', instance.href);
  writeNotNull('category', instance.category);
  writeNotNull('categoryId', instance.categoryId);
  writeNotNull('purity', instance.purity);
  writeNotNull('createTime', instance.createTime);
  writeNotNull('description', instance.description);
  return val;
}

WallPicAttr _$WallPicAttrFromJson(Map<String, dynamic> json) {
  return WallPicAttr(
    id: json['id'] as String,
    name: json['name'] as String,
    type: json['type'] as String,
    size: json['size'] as String,
    category: json['category'] as String,
    purity: json['purity'] as String,
    viewsCount: json['viewsCount'] as String,
    favsCount: json['favsCount'] as String,
    datetime: json['datetime'] as String,
    resolution: json['resolution'] == null
        ? null
        : ImgResolution.fromJson(json['resolution'] as Map<String, dynamic>),
    resourceHref: json['resourceHref'] as String,
    downloadLink: json['downloadLink'] as String,
    relatedHref: json['relatedHref'] as String,
    description: json['description'] as String,
    uploader: json['uploader'] == null
        ? null
        : Uploader.fromJson(json['uploader'] as Map<String, dynamic>),
    uploadTimeDescription: json['uploadTimeDescription'] as String,
    colors: (json['colors'] as List)?.map((e) => e as String)?.toList(),
    tags: (json['tags'] as List)
        ?.map((e) =>
            e == null ? null : WallPicTag.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$WallPicAttrToJson(WallPicAttr instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('name', instance.name);
  writeNotNull('type', instance.type);
  writeNotNull('size', instance.size);
  writeNotNull('category', instance.category);
  writeNotNull('purity', instance.purity);
  writeNotNull('viewsCount', instance.viewsCount);
  writeNotNull('favsCount', instance.favsCount);
  writeNotNull('datetime', instance.datetime);
  writeNotNull('resolution', instance.resolution);
  writeNotNull('resourceHref', instance.resourceHref);
  writeNotNull('downloadLink', instance.downloadLink);
  writeNotNull('relatedHref', instance.relatedHref);
  writeNotNull('description', instance.description);
  writeNotNull('uploader', instance.uploader);
  writeNotNull('uploadTimeDescription', instance.uploadTimeDescription);
  writeNotNull('colors', instance.colors);
  writeNotNull('tags', instance.tags);
  return val;
}

ImgResolution _$ImgResolutionFromJson(Map<String, dynamic> json) {
  return ImgResolution(
    width: json['width'] as String,
    height: json['height'] as String,
  );
}

Map<String, dynamic> _$ImgResolutionToJson(ImgResolution instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('width', instance.width);
  writeNotNull('height', instance.height);
  return val;
}

Uploader _$UploaderFromJson(Map<String, dynamic> json) {
  return Uploader(
    userName: json['userName'] as String,
    groupName: json['groupName'] as String,
    avatarImg: json['avatarImg'] as String,
    avatar: json['avatar'] as String,
  );
}

Map<String, dynamic> _$UploaderToJson(Uploader instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('userName', instance.userName);
  writeNotNull('groupName', instance.groupName);
  writeNotNull('avatarImg', instance.avatarImg);
  writeNotNull('avatar', instance.avatar);
  return val;
}
