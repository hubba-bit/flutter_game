import 'package:flutter/material.dart';
import 'package:maufriends/board/boardPage.dart';
import 'package:maufriends/common/enums.dart';
import 'package:maufriends/entities/baseEntity.dart';
import 'package:maufriends/entities/player.dart';
import 'package:maufriends/entities/session.dart';
import 'package:maufriends/services/sessionService.dart';

class SessionDialog extends StatefulWidget {
  final String player;
  final SessionMode mode;

  const SessionDialog({this.player, this.mode});
  @override
  _SessionDialogState createState() => new _SessionDialogState();
}

class _SessionDialogState extends State<SessionDialog> {
  final codeController = TextEditingController();
  int players = 3;
  String error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create new session'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            if (widget.mode == SessionMode.join)
              (TextField(
                controller: codeController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Session Code',
                ),
              )),
            if (widget.mode == SessionMode.create) ...[
              Text("Number of Players"),
              DropdownButton<int>(
                isExpanded: true,
                value: players,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (int newValue) {
                  setState(() {
                    players = newValue;
                  });
                },
                items:
                    <int>[2, 3, 4, 5].map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text("$value"),
                  );
                }).toList(),
              )
            ],
            if (error != null)
              Text(
                error,
                style:
                    TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
              )
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text(widget.mode == SessionMode.create ? 'Create' : 'Join'),
          onPressed: () async {
            Map<String, BaseEntity> sessionData;
            if (widget.mode == SessionMode.create) {
              sessionData = await SessionService()
                  .createSession(host: widget.player, totalPlayers: players);
            } else {
              sessionData = await SessionService().joinSession(
                  code: codeController.text, playerName: widget.player);
            }
            final session = sessionData['session'] as Session;
            final currentPlayer = sessionData['player'] as Player;

            if (currentPlayer == null || session == null) {
              setState(() {
                error = "Invalid session code";
              });
              return;
            }
            Navigator.of(context).pop();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => BoardPage(
                          sessionId: session.id,
                          currentPlayer: currentPlayer,
                        )));
          },
        ),
      ],
    );
  }
}
