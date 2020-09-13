import 'package:maufriends/entities/baseEntity.dart';

class Session extends BaseEntity {
  @override
  String id;
  @override
  dynamic createdAt;
  String code;
  String host;
  int totalPlayers;
  bool gameStarted = false;

  Session({
    this.code,
    this.host,
    this.totalPlayers,
    this.gameStarted,
  });

  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      if (code != null) 'code': code,
      if (host != null) 'host': host,
      if (totalPlayers != null) 'totalPlayers': totalPlayers,
      if (gameStarted != null) 'gameStarted': gameStarted,
    });

  Session.fromMap(Map<String, dynamic> snapshot, String id)
      : id = id,
        createdAt = snapshot['createdAt'],
        code = snapshot['code'] ?? '',
        host = snapshot['host'] ?? '',
        totalPlayers = snapshot['totalPlayers'] ?? 0,
        gameStarted = snapshot['gameStarted'] ?? false;
}
