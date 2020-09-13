import 'package:flutter/cupertino.dart';
import 'package:maufriends/entities/baseEntity.dart';

class Player extends BaseEntity {
  @override
  String id;
  @override
  dynamic createdAt;
  String name;
  bool isHost;

  Player({
    @required this.name,
    this.isHost,
  });

  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      'name': name,
      'isHost': isHost,
    });

  Player.fromMap(Map<String, dynamic> snapshot, String id)
      : id = id,
        createdAt = snapshot['createdAt'],
        name = snapshot['name'],
        isHost = snapshot['isHost'];
}
