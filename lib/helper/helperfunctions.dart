import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions{
  static String sharedPreferenceUserNameKey = "USERNAMEKEY";
  static String sharedPreferenceUserEmailKey = "USERNAMEKEY";

  static Future<bool> saveUserNameSharedPreference (String username) async {
    SharedPreferences pref =  await SharedPreferences.getInstance();
    return await pref.setString(sharedPreferenceUserNameKey, username);
  }

  static Future<bool> saveUserEmailSharedPreference (String userEmail) async {
    SharedPreferences pref =  await SharedPreferences.getInstance();
    return await pref.setString(sharedPreferenceUserEmailKey, userEmail);
  }

  static Future<String> getUserNameSharedPreference () async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(sharedPreferenceUserNameKey);
  }

  static Future<String> getUserEmailSharedPreference () async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(sharedPreferenceUserEmailKey);
  }

}
