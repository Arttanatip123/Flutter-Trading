
class SystemInstance {
  static final SystemInstance _instance = SystemInstance._internal();

  String _userId;
  String _token;


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
}