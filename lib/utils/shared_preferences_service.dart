import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferences? _sharedPreferences;
  static late String? userOrg;
  ///creates a sharePreference instance to [_sharedPreferences]
  static Future<void> init() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    userOrg = await getUserOrganisation();
  }
  ///calls[init] if the instance is not created.
  static Future<void> waitForInitialization() async {
    if(_sharedPreferences == null) {
      await init();
    }
  }
  ///returns [_sharedPreferences] instance
  static SharedPreferences? get sharedPreferences {
    return _sharedPreferences;
  }
  ///get user's organisation
  static Future<String?> getUserOrganisation()async{
    await waitForInitialization();
    return  _sharedPreferences!.getString('userOrganisation');
  }
  ///set user's organisation
  static Future<void> setUserOrganisation(String organisation)async{
    await waitForInitialization();
    userOrg = organisation;
    await _sharedPreferences!.setString('userOrganisation', organisation);
  }
}