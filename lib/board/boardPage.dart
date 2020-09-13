import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maufriends/common/customButton.dart';
import 'package:maufriends/common/enums.dart';
import 'package:maufriends/common/uiCard.dart';
import 'package:maufriends/entities/PlayerCard.dart';
import 'package:maufriends/entities/player.dart';
import 'package:maufriends/entities/session.dart';
import 'package:maufriends/entities/turn.dart';
import 'package:maufriends/services/sessionService.dart';

class BoardPage extends StatelessWidget {
  final String sessionId;
  final Player currentPlayer;
  Session session;
  int currentPlayerIndex;
  List<Player> players;
  PlayerCard lastDrawnCard;
  Turn turn;

  BoardPage({this.sessionId, this.currentPlayer});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return StreamBuilder<Session>(
        stream: SessionService().getSession(id: sessionId),
        builder: (context, sessionSnapshot) {
          if (sessionSnapshot.hasError) {
            return Text('Error: ${sessionSnapshot.error}');
          } else if (sessionSnapshot.connectionState ==
              ConnectionState.waiting) {
            return Text('Loading...');
          }

          session = sessionSnapshot.data;
          final Stream<Turn> turnStream = session.gameStarted
              ? SessionService().getTurn(sessionId: sessionId)
              : Stream.empty();
          return Scaffold(
            body: Container(
              color: Colors.blue[100],
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: screenSize.height * .03,
                  ),
                  SizedBox(
                    height: screenSize.height * .07,
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(currentPlayer.name),
                      subtitle: StreamBuilder<Turn>(
                          stream: turnStream,
                          builder: (context, turnSnapshot) {
                            if (turnSnapshot.connectionState ==
                                    ConnectionState.waiting ||
                                turnSnapshot.data == null) {
                              return SizedBox();
                            }
                            turn = turnSnapshot.data;
                            return turn.nextTurn == currentPlayer.id
                                ? Text(
                                    'Your Turn',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : SizedBox();
                          }),
                    ),
                  ),
                  SizedBox(
                    height: screenSize.height * .05,
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Session code: ${session.code}",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          height: 30,
                          width: 70,
                          child: CustomButton(
                            color: Colors.transparent,
                            borderRadius: 10,
                            foreColor: Colors.white,
                            onPressed: () async {
                              Clipboard.setData(
                                  ClipboardData(text: session.code));
                            },
                            icon: Icon(
                              Icons.content_copy,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder<List<Player>>(
                    stream: SessionService().getPlayers(sessionId),
                    builder: (_, playerSnapshot) {
                      if (playerSnapshot.hasError) {
                        return Text('Error: ${playerSnapshot.error}');
                      }
                      switch (playerSnapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Text('Loading...');
                        default:
                          players = playerSnapshot.data;
                          currentPlayerIndex = players
                              .indexWhere((e) => e.id == currentPlayer.id);
                          final opponents = players
                              .where((p) => p.id != currentPlayer.id)
                              .toList();
                          bool displayCards = false;
                          Player playerOnLeft;
                          Player playerOnRight;

                          Player playerOnTop;
                          bool playerOnTopEnabled = false;

                          if (session.totalPlayers == 2) {
                            if (opponents.length == 1) {
                              playerOnTop = opponents.first;
                              displayCards = true;
                            }
                            playerOnTopEnabled = true;
                          } else if (session.totalPlayers == 3) {
                            if (players.length >= 2) playerOnLeft = players[1];
                            if (players.length == 3) playerOnRight = players[2];
                          }

                          return Column(
                            children: <Widget>[
                              SizedBox(
                                  height: screenSize.height * .85,
                                  child: SizedBox(
                                    height: screenSize.height * .85,
                                    child: Column(
                                      children: <Widget>[
                                        // Top player panel
                                        SizedBox(
                                          height: screenSize.height * .25,
                                          width: screenSize.width * .96,
                                          child: Row(
                                            children: <Widget>[
                                              Column(
                                                children: <Widget>[
                                                  SizedBox(
                                                    width:
                                                        screenSize.width * .96,
                                                    child: playerOnTopEnabled
                                                        ? _opponentCard(
                                                            screenSize.height *
                                                                .05,
                                                            playerOnTop,
                                                          )
                                                        : SizedBox(),
                                                  ),
                                                  if (displayCards)
                                                    _diplayCards(
                                                      context,
                                                      screenSize.height * .2,
                                                      screenSize.width - 20,
                                                      false,
                                                      playerOnTop.id,
                                                    )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Middle Section
                                        SizedBox(
                                          height: screenSize.height * .40,
                                          child: Row(
                                            children: <Widget>[
                                              // Left player panel
                                              SizedBox(
                                                width: screenSize.width * .23,
                                                child: Container(
                                                  child: false
                                                      ? _opponentCard(
                                                          screenSize.height *
                                                              .1,
                                                          playerOnTop)
                                                      : SizedBox(),
                                                ),
                                              ),

                                              // Pile and Draw cards Section
                                              SizedBox(
                                                width: screenSize.width * .5,
                                                child: session.gameStarted
                                                    ? Column(
                                                        children: <Widget>[
                                                          //Pile section
                                                          SizedBox(
                                                            height: screenSize
                                                                    .height *
                                                                .15,
                                                            child: Row(
                                                              children: <
                                                                  Widget>[
                                                                SizedBox(
                                                                  width: screenSize
                                                                          .width *
                                                                      .35,
                                                                ),
                                                                SizedBox(
                                                                  width: screenSize
                                                                          .width *
                                                                      .15,
                                                                  child:
                                                                      TransformedCard(
                                                                    faceUp:
                                                                        false,
                                                                    height:
                                                                        screenSize.height *
                                                                            .2,
                                                                    width: (screenSize.width -
                                                                            20) /
                                                                        6,
                                                                    onTap:
                                                                        () async {
                                                                      if (turn.nextTurn ==
                                                                              currentPlayer.id &&
                                                                          !turn.pickedFromPile) {
                                                                        await SessionService()
                                                                            .pickFromPile(
                                                                          sessionId:
                                                                              sessionId,
                                                                          playerId:
                                                                              currentPlayer.id,
                                                                        );
                                                                        turn.pickedFromPile =
                                                                            true;
                                                                      }
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                          // Draw Section
                                                          SizedBox(
                                                            height: screenSize
                                                                    .height *
                                                                .25,
                                                            child: Row(
                                                              children: <
                                                                  Widget>[
                                                                SizedBox(
                                                                    width: screenSize
                                                                            .width *
                                                                        .25,
                                                                    child:
                                                                        _getLastDrawnCardStream(
                                                                      screenSize
                                                                              .height *
                                                                          .2,
                                                                      (screenSize.width -
                                                                              20) /
                                                                          5,
                                                                    )),
                                                                SizedBox(
                                                                  width: screenSize
                                                                          .width *
                                                                      .25,
                                                                  child: Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width: 70,
                                                                      child:
                                                                          CustomButton(
                                                                        color: Colors
                                                                            .blue[400],
                                                                        icon: Icon(
                                                                            Icons.arrow_forward),
                                                                        onPressed:
                                                                            () async {
                                                                          if (turn != null &&
                                                                              turn.pickedFromPile &&
                                                                              currentPlayer.id == turn.nextTurn) {
                                                                            final nextPlayerId =
                                                                                players[currentPlayerIndex < players.length - 1 ? currentPlayerIndex + 1 : 0].id;
                                                                            await SessionService().skipTurn(sessionId,
                                                                                nextPlayerId);
                                                                          }
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : session.totalPlayers ==
                                                                players
                                                                    .length &&
                                                            currentPlayer.isHost
                                                        ? CustomButton(
                                                            color: players
                                                                        .length ==
                                                                    session
                                                                        .totalPlayers
                                                                ? Colors
                                                                    .blue[400]
                                                                : Colors.grey,
                                                            text: 'Start',
                                                            onPressed:
                                                                () async {
                                                              if (players
                                                                      .length ==
                                                                  session
                                                                      .totalPlayers) {
                                                                await SessionService().drawCards(
                                                                    session.id,
                                                                    players
                                                                        .map((e) =>
                                                                            e.id)
                                                                        .toList());
                                                              }
                                                            },
                                                          )
                                                        : Center(
                                                            child:
                                                                CircularProgressIndicator()),
                                              ),

                                              // Right player section
                                              SizedBox(
                                                width: screenSize.width * .23,
                                                child: Container(
                                                  child: session.totalPlayers >
                                                          2
                                                      ? _opponentCard(
                                                          screenSize.height *
                                                              .1,
                                                          null,
                                                        )
                                                      : SizedBox(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Current player section.
                                        SizedBox(
                                          height: screenSize.height * .20,
                                          width: screenSize.width * .96,
                                          child: Row(
                                            children: <Widget>[
                                              Column(
                                                children: <Widget>[
                                                  if (displayCards)
                                                    _diplayCards(
                                                      context,
                                                      screenSize.height * .20,
                                                      screenSize.width - 20,
                                                      true,
                                                      currentPlayer.id,
                                                    )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          );
                      }
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _diplayCards(
    BuildContext context,
    double height,
    double screenWidth,
    bool faceUp,
    String playerId,
  ) {
    return StreamBuilder<List<PlayerCard>>(
        stream: SessionService().getCards(sessionId, playerId),
        builder: (_, cardSnapshot) {
          if (cardSnapshot.hasError) {
            return Text('Error: ${cardSnapshot.error}');
          } else if (cardSnapshot.data == null) {
            return Text('Loading...');
          }
          switch (cardSnapshot.connectionState) {
            case ConnectionState.waiting:
              return Text('Loading...');
            default:
              final cards = cardSnapshot.data;
              final cardWidh = screenWidth / 5;
              double availableWidth = screenWidth;
              if (cards.length < 5) {
                availableWidth -= cardWidh * (5 - cards.length);
              }
              return SizedBox(
                height: height,
                width: screenWidth,
                child: Center(
                  child: Stack(
                    children: cards.map((card) {
                      return Positioned(
                        left: ((screenWidth - availableWidth) / 2) +
                            (cards.indexOf(card) *
                                ((availableWidth - cardWidh) /
                                    (cards.length - 1))),
                        child: TransformedCard(
                          playerCard: card,
                          faceUp: faceUp,
                          height: height * .8,
                          width: cardWidh,
                          onTap: () async {
                            if (faceUp && turn.nextTurn == currentPlayer.id) {
                              if (card.type == CardType.jack &&
                                  lastDrawnCard.type != CardType.jack) {
                                card.jackSuitCall =
                                    await _changeSuitAlert(context);
                              }
                              await SessionService().playTurn(
                                card: card,
                                lastDrawnCard: lastDrawnCard,
                                playerId: currentPlayer.id,
                                sessionId: sessionId,
                                nextPlayer: players[
                                    currentPlayerIndex < players.length - 1
                                        ? currentPlayerIndex + 1
                                        : 0],
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
          }
        });
  }

  StreamBuilder<PlayerCard> _getLastDrawnCardStream(
      double height, double width) {
    return StreamBuilder<PlayerCard>(
        stream: SessionService().getLastDrawnCard(sessionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return SizedBox();

          lastDrawnCard = snapshot.data;
          return TransformedCard(
            playerCard: lastDrawnCard,
            faceUp: true,
            height: height,
            width: width,
          );
        });
  }

  Widget _opponentCard(double height, Player player) {
    return Container(
      child: SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            player == null ? CircularProgressIndicator() : CircleAvatar(),
            SizedBox(
              width: 10,
            ),
            Text(
              player?.name ?? 'Waiting for player to join.',
            ),
          ],
        ),
      ),
    );
  }
}

Future<CardSuit> _changeSuitAlert(BuildContext context) async {
  final getButton = (String imageUri) => Padding(
        padding: const EdgeInsets.all(0.5),
        child: SizedBox(
          height: 65,
          width: 65,
          child: CustomButton(
              color: Colors.blue[400],
              image: Image.asset(
                imageUri,
                height: 32,
                width: 32,
              ),
              onPressed: () {
                Navigator.of(context).pop(CardSuit.hearts);
              }),
        ),
      );

  return await showDialog<CardSuit>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Select suit'),
      content: Row(
        children: <Widget>[
          getButton('images/clubs.png'),
          getButton('images/diamonds.png'),
          getButton('images/spades.png'),
          getButton('images/hearts.png'),
        ],
      ),
    ),
  );
}
