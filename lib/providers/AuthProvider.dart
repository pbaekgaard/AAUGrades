import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class User {
  final String username;
  final String password;

  User({required this.username, required this.password});
}

Future<bool> authenticateUser(String username, String password) async {
  const loginUrl = 'https://sb.aau.dk/sb-ad/sb';
  const loginForm = 'https://sb.aau.dk/sb-ad/sb/index.jsp';
  const redirectedUrl = 'http://sb.aau.dk/sb-ad/sb/common/velkommen.jsp';

  final dio = Dio();
  final cookieJar = CookieJar();
  dio.interceptors.add(CookieManager(cookieJar));

  try {
    await dio.get(loginUrl);

    final loginResponse = await dio.post(
      loginForm,
      data: {
        'lang': 'null',
        'submit_action': 'login',
        'brugernavn': username,
        'adgangskode': password
      },
      options: Options(
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        followRedirects: false,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
      ),
    );
    if (loginResponse.statusCode == 302 &&
        loginResponse.headers['location']?[0] == redirectedUrl) {
      return true;
    } else {
      return false;
    }
  } catch (error) {
    print(error);
    return false;
  }
}

class AuthProvider extends ChangeNotifier {
  String? _notificationMessage;
  String? get notificationMessage => _notificationMessage;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Function to check if the user is logged in
  Future<bool> isLoggedIn() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    bool usernameExists = await secureStorage.containsKey(key: 'username');
    bool passwordExists = await secureStorage.containsKey(key: 'password');
    if (usernameExists && passwordExists) {
      return true;
    }
    return false;
  }

  // Function to handle login
  Future<void> login(String username, String password) async {
    // Perform authentication (you can check against a database here)
    // For simplicity, we're just storing credentials in shared_preferences

    if (await authenticateUser(username, password) == true) {
      await _secureStorage.write(key: 'username', value: username);
      await _secureStorage.write(key: 'password', value: password);
      _notificationMessage = 'Login Success';
    } else {
      _notificationMessage = 'Username or Password is incorrect, try again!';
    }

    notifyListeners();
  }

  // Function to handle logout
  Future<void> logout() async {
    await _secureStorage.delete(key: 'username');
    await _secureStorage.delete(key: 'password');

    _notificationMessage = null;

    notifyListeners();
  }
}
