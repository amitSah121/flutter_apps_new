import 'package:flutter/material.dart';
import 'package:page_editor/file_funcs.dart';

class RowMap implements JsonConvertible {
  Map<int, String> rows;
  // note for media node format is
  // customUrl/media/images/....[imageformat] __5050__media__5050__ 300
  // https://....[imageformat] __5050__media__5050__ 300
  // customUrl/media/images/....[videoFormat] __5050__media__5050__ 300
  // https://....[videoformat] __5050__media__5050__ 300

  RowMap({required this.rows});

  factory RowMap.fromJson(Map<String, dynamic> json) {
    return RowMap(
      rows: json.map((key, value) => MapEntry(int.parse(key), value as String)),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return rows.map((key, value) => MapEntry(key.toString(), value));
  }
}

class PageNode implements JsonConvertible {
  RowMap rows; // row number and text input
  String
      metadata; // includes arguments as key value pair separated by ";", so fileName=$time;title=Untitled;backgroundColor=Colors.White.value.toString();.....

  PageNode({
    required this.rows,
    this.metadata = "",
  });

  factory PageNode.fromJson(Map<String, dynamic> json) {
    return PageNode(
      rows: RowMap.fromJson(json['rows']),
      metadata: json['metadata'] ?? "",
    );
  }

  String getType(){
    return "page";
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'rows': rows.toJson(),
      'metadata': metadata,
    };
  }
}
