import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maufriends/entities/PlayerCard.dart';
import 'package:maufriends/entities/baseEntity.dart';
import 'package:maufriends/entities/player.dart';
import 'package:maufriends/entities/session.dart';
import 'package:maufriends/entities/turn.dart';
import 'package:maufriends/services/boardService.dart';
import 'package:maufriends/services/firestorage.dart';
import 'package:random_string/random_string.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  SessionService._internal();
  factory SessionService() => _instance;
  static const String COLLECTION_NAME = 'sessions';
  final _firestorage = Firestorage(COLLECTION_NAME);

  Future<Map<String, BaseEntity>> createSession(
      {String host, int totalPlayers}) async {
    final code = randomAlphaNumeric(4);
    var session = Session(code: code, totalPlayers: totalPlayers, host: host);
    final sessionSnapShot = await _firestorage.insert(data: session.toJson());
    session = Session.fromMap(sessionSnapShot.data, sessionSnapShot.documentID);
    final playerSnapshot = await _firestorage.insertSubDocument(
      docId: session.id,
      subCollection: 'players',
      data: Player(
        name: host,
        isHost: true,
      ).toJson(),
    );
    final player =
        Player.fromMap(playerSnapshot.data, playerSnapshot.documentID);
    return {'session': session, 'player': player};
  }

  Future<Map<String, BaseEntity>> joinSession(
      {String code, String playerName}) async {
    final session = await getSession(code: code).first;
    final playerSnapshot = await _firestorage.insertSubDocument(
      docId: session.id,
      subCollection: 'players',
      data: Player(
        name: playerName,
        isHost: false,
      ).toJson(),
    );
    return {
      'session': session,
      'player': Player.fromMap(playerSnapshot.data, playerSnapshot.documentID)
    };
  }

  Future drawCards(String sessionId, List<String> playerIds) async {
    List<Future> allFutures = [];
    BoardService().createCards();
    for (final playerId in playerIds) {
      allFutures.add(
        addToPlayerCards(
          sessionId: sessionId,
          playerId: playerId,
          cards: BoardService().drawCards(5),
        ),
      );
    }

    allFutures.addAll([
      addToDrawnCards(
        sessionId: sessionId,
        card: BoardService().remainingCards.first,
      ),
      addToPileCards(
        sessionId: sessionId,
        data: BoardService()
            .remainingCards
            .sublist(1)
            .map((e) => e.toJson())
            .toList(),
      ),
      _firestorage.insertSubDocument(
        docId: sessionId,
        subCollection: 'turn',
        id: sessionId,
        data: Turn(nextTurn: playerIds[Random(1).nextInt(playerIds.length - 1)])
            .toJson(),
      ),
      _firestorage.update(
        docId: sessionId,
        data: Session(
          gameStarted: true,
        ).toJson(),
      ),
    ]);

    await Future.wait(allFutures);
  }

  Future addToPlayerCards(
      {String sessionId, String playerId, List<PlayerCard> cards}) {
    return _firestorage.insertSubCollection(
      docId: sessionId,
      subCollection: 'players/$playerId/cards',
      data: cards.map((e) => e.toJson()).toList(),
    );
  }

  Future addToDrawnCards({
    String sessionId,
    PlayerCard card,
  }) {
    return _firestorage.insertSubDocument(
      docId: sessionId,
      subCollection: 'drawnCards',
      data: card.toJson(),
    );
  }

  Future addToPileCards({
    String sessionId,
    List<Map<String, dynamic>> data,
  }) {
    return _firestorage.insertSubCollection(
      docId: sessionId,
      subCollection: 'pileCards',
      data: data,
    );
  }

  Future playTurn({
    String sessionId,
    String playerId,
    PlayerCard card,
    PlayerCard lastDrawnCard,
    Player nextPlayer,
  }) async {
    bool canPlay = false;

    canPlay =
        card.suit == lastDrawnCard.suit || card.type == lastDrawnCard.type;

    // canPlay = canPlay ||
    //     (card.type == CardType.jack && lastDrawnCard.type != CardType.jack);

    if (canPlay) {
      return Future.wait([
        addToDrawnCards(sessionId: sessionId, card: card),
        _firestorage.deleteSubDocument(
          parentId: sessionId,
          subCollection: 'players/$playerId/cards',
          docId: card.id,
        ),
        _firestorage.updateSubDoc(
          parentId: sessionId,
          subCollection: 'turn',
          documentId: sessionId,
          data: Turn(nextTurn: nextPlayer.id).toJson(),
        ),
      ]);
    }
  }

  Future skipTurn(String sessionId, String nextPlayerId) {
    return _firestorage.updateSubDoc(
      parentId: sessionId,
      subCollection: 'turn',
      documentId: sessionId,
      data: Turn(nextTurn: nextPlayerId).toJson(),
    );
  }

  Future pickFromPile({
    String sessionId,
    String playerId,
  }) async {
    final lastCard = await getLastPileCard(sessionId);
    return Future.wait([
      _firestorage.deleteSubDocument(
        parentId: sessionId,
        subCollection: 'pileCards',
        docId: lastCard.id,
      ),
      addToPlayerCards(
        sessionId: sessionId,
        playerId: playerId,
        cards: [lastCard],
      )
    ]);
  }

  Stream<Session> getSession({
    String code,
    String id,
  }) {
    if (id != null) {
      return _firestorage
          .getDocumentById(documentId: id)
          .map((doc) => Session.fromMap(doc.data, doc.documentID));
    } else if (code != null) {
      return _firestorage.getDocument("code", isEqualTo: code).map((data) =>
          data.documents.length > 0
              ? Session.fromMap(
                  data.documents.first.data, data.documents.first.documentID)
              : null);
    } else {
      return Stream.empty();
    }
  }

  Stream<Turn> getTurn({
    @required String sessionId,
  }) {
    return _firestorage
        .getSubDocument(sessionId, 'turn/$sessionId')
        .map((doc) => Turn.fromMap(doc.data, doc.documentID));
  }

  Stream<List<Player>> getPlayers(String sessionId) {
    return _firestorage.getSubCollection(sessionId, 'players').map((event) =>
        event.documents
            .map((doc) => Player.fromMap(doc.data, doc.documentID))
            .toList());
  }

  Stream<List<PlayerCard>> getCards(String sessionId, String playerId) {
    return _firestorage
        .getSubCollection('$sessionId/players/$playerId', 'cards')
        .map((event) => event.documents
            .map((doc) => PlayerCard.fromMap(doc.data, doc.documentID))
            .toList());
  }

  Stream<PlayerCard> getLastDrawnCard(String sessionId) {
    return _firestorage.getSubCollection(sessionId, 'drawnCards').map((event) {
      final playerCard = PlayerCard.fromMap(
          event.documents.first.data, event.documents.first.documentID);
      return playerCard;
    });
  }

  Future<PlayerCard> getLastPileCard(String sessionId) async {
    final lastPileCard =
        (await _firestorage.getSubCollection(sessionId, 'pileCards').first)
            .documents
            .first;
    return PlayerCard.fromMap(lastPileCard.data, lastPileCard.documentID);
  }
}
