class SpriteData {
  String name;
  String id;
  int x;
  int y;
  int width;
  int height;
  int rotation;
  int frame;
  String fillColor;
  String strokeColor;
  int rtl = 0, rtr = 0, rbl = 0, rbr = 0; 

  SpriteData({
    required this.name,
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.rotation,
    required this.frame,
    required this.fillColor,
    required this.strokeColor,
    required this.rtl,
    required this.rtr,
    required this.rbl,
    required this.rbr,
  });

  // Factory method to create an instance from a CSV row
  factory SpriteData.fromCsvRow(List<dynamic> row) {
    return SpriteData(
      name: row[0] as String,
      id: row[1] as String,
      x: row[2] as int,
      y: row[3] as int,
      width: row[4] as int,
      height: row[5] as int,
      rotation: row[6] as int,
      frame: row[7] as int,
      fillColor: row[8].toString().padLeft(8,'0'),
      strokeColor: row[9].toString().padLeft(8,'0'),
      rtl: row[10] as int,
      rtr: row[11] as int,
      rbl: row[12] as int,
      rbr: row[13] as int,
    );
  }

  List<dynamic> toCsvRow() {
    return [name, id, x, y, width, height, rotation, frame, fillColor, strokeColor,rtl, rtr, rbl, rbr];
  }
}



class TileData {
  String name;
  String animName;
  int x;
  int y;
  double scale;
  int rotation;
  String metadata;

  TileData({
    required this.name,
    required this.animName,
    required this.x,
    required this.y,
    required this.scale,
    required this.rotation,
    required this.metadata,
  });

  // Convert instance to a CSV row
  List<dynamic> toCsvRow() {
    return [name, animName, x, y, scale, rotation, metadata];
  }

  // Factory method to create an instance from a CSV row
  factory TileData.fromCsvRow(List<dynamic> row) {
    return TileData(
      name: row[0] as String,
      animName: row[1] as String,
      x: row[2] as int,
      y: row[3] as int,
      scale: row[4] is int ? (row[3] as int).toDouble() : row[3] as double,
      rotation: row[5] as int,
      metadata: row[6] as String,
    );
  }
}
