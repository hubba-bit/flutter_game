import 'package:flutter/material.dart';
import 'package:maufriends/common/enums.dart';
import 'package:maufriends/entities/PlayerCard.dart';

class TransformedCard extends StatelessWidget {
  final PlayerCard playerCard;
  final double height;
  final double width;
  final bool faceUp;
  final GestureTapCallback onTap;

  TransformedCard({
    this.playerCard,
    this.faceUp,
    this.height,
    this.width,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCard();
  }

  Widget _buildCard() {
    return InkWell(
        onTap: () {
          print("card tap deteced");
        },
        onDoubleTap: () {
          if (onTap != null) {
            onTap();
          }
          print("card double tap deteced");
        },
        child: !this.faceUp
            ? Container(
                height: this.height,
                width: this.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/flip.jpg'),
                    fit: BoxFit.fill,
                  ),
                  color: Colors.blue,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              )
            : _buildFaceUpCard());
  }

  Widget _buildFaceUpCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 0, 0, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
          border: Border.all(color: Colors.black, width: .25),
        ),
        height: this.height,
        width: this.width - 1,
        child: Stack(
          children: <Widget>[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(
                      _cardTypeToString(),
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Container(
                    height: 30.0,
                    child: _suitToImage(),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      _cardTypeToString(),
                      style: TextStyle(
                        fontSize: 10.0,
                      ),
                    ),
                    Container(
                      height: 10.0,
                      child: _suitToImage(),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RotatedBox(
                      quarterTurns: 2,
                      child: Text(
                        _cardTypeToString(),
                        style: TextStyle(
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                    Container(
                      height: 10.0,
                      child: RotatedBox(
                        quarterTurns: 2,
                        child: _suitToImage(),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cardTypeToString() {
    switch (this.playerCard.type) {
      case CardType.one:
        return "A";
      case CardType.two:
        return "2";
      case CardType.three:
        return "3";
      case CardType.four:
        return "4";
      case CardType.five:
        return "5";
      case CardType.six:
        return "6";
      case CardType.seven:
        return "7";
      case CardType.eight:
        return "8";
      case CardType.nine:
        return "9";
      case CardType.ten:
        return "10";
      case CardType.jack:
        return "J";
      case CardType.queen:
        return "Q";
      case CardType.king:
        return "K";
      default:
        return "";
    }
  }

  Image _suitToImage() {
    switch (this.playerCard.suit) {
      case CardSuit.hearts:
        return Image.asset('images/hearts.png');
      case CardSuit.diamonds:
        return Image.asset('images/diamonds.png');
      case CardSuit.clubs:
        return Image.asset('images/clubs.png');
      case CardSuit.spades:
        return Image.asset('images/spades.png');
      default:
        return null;
    }
  }
}
