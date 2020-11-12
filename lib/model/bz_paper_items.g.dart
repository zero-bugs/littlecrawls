// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bz_paper_items.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BzzzzmhItems _$BzzzzmhItemsFromJson(Map<String, dynamic> json) {
  return BzzzzmhItems(
    current: json['current'] as int,
    total: json['total'] as int,
    pages: json['pages'] as int,
    size: json['size'] as int,
    records: (json['records'] as List)
        ?.map((e) =>
            e == null ? null : BzzzzmhItem.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$BzzzzmhItemsToJson(BzzzzmhItems instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('current', instance.current);
  writeNotNull('total', instance.total);
  writeNotNull('pages', instance.pages);
  writeNotNull('size', instance.size);
  writeNotNull('records', instance.records);
  return val;
}

BzzzzmhItem _$BzzzzmhItemFromJson(Map<String, dynamic> json) {
  return BzzzzmhItem(
    width: json['width'] as String,
    height: json['height'] as String,
    thumbnail: json['thumbnail'] as String,
    fullImg: json['fullImg'] as String,
  )..id = json['id'] as String;
}

Map<String, dynamic> _$BzzzzmhItemToJson(BzzzzmhItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('width', instance.width);
  writeNotNull('height', instance.height);
  writeNotNull('thumbnail', instance.thumbnail);
  writeNotNull('fullImg', instance.fullImg);
  return val;
}
