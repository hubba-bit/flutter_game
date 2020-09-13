import 'package:flutter/material.dart';
import 'package:maufriends/common/customButton.dart';
import 'package:maufriends/common/enums.dart';
import 'package:maufriends/services/sharedPrefService.dart';
import 'package:maufriends/session/sessionDialog.dart';
import 'package:random_string/random_string.dart';

class SessionPage extends StatelessWidget {
  final playerController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(future: () async {
      return await SharedPrefService().getPlayer() ??
          'Player ${randomAlphaNumeric(2)}';
    }(), builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return CircularProgressIndicator();
      }

      playerController.text = snapshot.data;
      return Scaffold(
        backgroundColor: Colors.blue[100],
        body: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: playerController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Player Name',
                ),
              ),
              SizedBox(
                height: 45.0,
              ),
              SizedBox(
                height: 10.0,
              ),
              SizedBox(
                height: 47.0,
                child: CustomButton(
                  text: 'New Session',
                  icon: Icon(Icons.add),
                  color: Colors.white,
                  onPressed: () async {
                    await _createOrJoin(context, SessionMode.create);
                  },
                  borderRadius: 5.0,
                ),
              ),
              SizedBox(
                height: 14.0,
              ),
              SizedBox(
                height: 47.0,
                child: CustomButton(
                  text: 'Join Session',
                  icon: Icon(
                    Icons.supervised_user_circle,
                  ),
                  color: Colors.blue[400],
                  onPressed: () async {
                    await _createOrJoin(context, SessionMode.join);
                  },
                  borderRadius: 5.0,
                ),
              ),
              SizedBox(
                height: 14.0,
              ),
            ],
          ),
        ),
      );
    });
  }

  _createOrJoin(BuildContext context, SessionMode mode) async {
    await SharedPrefService().setPlayer(playerController.text);
    showDialog(
      context: context,
      builder: (context) => SessionDialog(
        player: playerController.text,
        mode: mode,
      ),
    );
  }
}
