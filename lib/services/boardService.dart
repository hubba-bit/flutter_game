import 'dart:math';

import 'package:maufriends/common/enums.dart';
import 'package:maufriends/entities/PlayerCard.dart';

class BoardService {
  static final BoardService _instance = BoardService._internal();
  BoardService._internal();
  factory BoardService() => _instance;

  List<PlayerCard> _allCards = [];

  createCards() {
    _allCards.clear();
    CardSuit.values.forEach((suit) {
      CardType.values.forEach((type) {
        _allCards.add(PlayerCard(
          type: type,
          suit: suit,
        ));
      });
    });
  }

  List<PlayerCard> drawCards(int noOfCards) {
    List<PlayerCard> result = [];

    for (var i = 0; i < noOfCards; i++) {
      final index = Random(1).nextInt(_allCards.length - 1);
      result.add(_allCards[index]);
      _allCards.removeAt(index);
    }

    return result;
  }

  List<PlayerCard> get remainingCards => _allCards;
}
