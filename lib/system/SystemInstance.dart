
class SystemInstance {
  static final SystemInstance _instance = SystemInstance._internal();

  String _userId;
  String _token;
  String _fcmToken;


  factory SystemInstance(){
    return _instance;
  }

  SystemInstance._internal(){}

  String get userId => _userId;

  set userId(String value) {
    _userId = value;
  }

  String get token => _token;

  set token(String token) {
    _token = token;
  }

  String get fcmToken => _fcmToken;

  set fcmToken(String fcmToken){
    _fcmToken = fcmToken;
  }
}