import 'package:maufriends/common/enums.dart';
import 'package:maufriends/entities/baseEntity.dart';

class PlayerCard extends BaseEntity {
  @override
  String id;
  @override
  dynamic createdAt;
  final CardSuit suit;
  final CardType type;
  CardSuit jackSuitCall;

  PlayerCard({
    this.suit,
    this.type,
  });

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      'suit': suit.toString(),
      'type': type.toString(),
      'jackSuitCall': jackSuitCall != null ? jackSuitCall.toString() : null,
    });

  PlayerCard.fromMap(Map<String, dynamic> snapshot, String id)
      : id = id ?? '',
        createdAt = snapshot['createdAt'],
        suit =
            CardSuit.values.firstWhere((e) => e.toString() == snapshot['suit']),
        type =
            CardType.values.firstWhere((e) => e.toString() == snapshot['type']),
        jackSuitCall = snapshot['jackSuitCall'] != null
            ? CardSuit.values
                .firstWhere((e) => e.toString() == snapshot['jackSuitCall'])
            : null;
}
