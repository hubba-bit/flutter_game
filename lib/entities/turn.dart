import 'package:maufriends/entities/baseEntity.dart';

class Turn extends BaseEntity {
  @override
  String id;
  @override
  dynamic createdAt;
  String nextTurn;

  // Unmapped
  bool pickedFromPile = false;

  Turn({
    this.nextTurn,
  });

  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      if (nextTurn != null) 'nextTurn': nextTurn,
    });

  Turn.fromMap(Map<String, dynamic> snapshot, String id)
      : id = id,
        createdAt = snapshot['createdAt'],
        nextTurn = snapshot['nextTurn'] ?? '';
}
