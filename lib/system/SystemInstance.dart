
class SystemInstance {
  static final SystemInstance _instance = SystemInstance._internal();

  String _userId;


  factory SystemInstance(){
    return _instance;
  }

  SystemInstance._internal(){}

  String get userId => _userId;

  set userId(String value) {
    _userId = value;
  }
}