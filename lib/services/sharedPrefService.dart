import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static final SharedPrefService _instance = SharedPrefService._internal();
  SharedPrefService._internal();
  factory SharedPrefService() => _instance;

  static const PLAYER_KEY = 'player';

  Future<bool> setPlayer(String user) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(PLAYER_KEY, user);
  }

  Future<String> getPlayer() async =>
      (await SharedPreferences.getInstance()).getString(PLAYER_KEY);
}
