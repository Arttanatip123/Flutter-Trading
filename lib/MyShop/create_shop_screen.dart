import 'dart:io';
import 'dart:async';
import 'package:cool_alert/cool_alert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:myapp/config.dart';
import 'dart:convert';
import 'package:myapp/system/SystemInstance.dart';

class CreateShop extends StatefulWidget {
  @override
  _CreateShopState createState() => _CreateShopState();
}

class _CreateShopState extends State<CreateShop> {

  TextEditingController _shopName = TextEditingController();
  TextEditingController _shopPhone = TextEditingController();
  TextEditingController _shopComment = TextEditingController();
  TimeOfDay _time1 = TimeOfDay.now();
  TimeOfDay _time2 = TimeOfDay.now();
  TimeOfDay _timePicked1, _timePicked2;
  SystemInstance systemInstance = SystemInstance();
  String shopName='', latitude='', longtitude='', officeHours='', shopComment='', shopStatus = '', shopImg='', time1 ='', time2 = '';
  var positions;
  double lat,lng;
  Set<Marker> markers = Set.from([]);
  GoogleMapController _controller;
  Position position;
  File _image;
  final picker = ImagePicker();
  var pickedFile;
  bool _isLoading = false;


  Future<Null> selectTime1(BuildContext context) async {
    _timePicked1 = await showTimePicker(
        context: context,
        initialTime: _time1,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child,
          );
        }
    );
    if(_timePicked1 != null && _timePicked1 != _time1){
      setState(() {
        _time1 = _timePicked1;
        time1 = _time1.toString().substring(10,15);

      });
    }
  }

  Future<Null> selectTime2(BuildContext context) async {
    _timePicked2 = await showTimePicker(
        context: context,
        initialTime: _time2,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child,
          );
        }
    );
    if(_timePicked2 != null && _timePicked2 != _time2){
      setState(() {
        _time2 = _timePicked2;
        time2 = _time2.toString().substring(10,15);
      });
    }
  }


  Future _getCerrentLocation() async {
    position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      positions = position;
      lat = position.latitude.toDouble();
      lng = position.longitude.toDouble();
      print(position);
      movetoGPS(lat,lng);
    });
  }

  Future getImage() async{
    pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }
  Future getCamera() async{
    pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future movetoGPS(double la, double ln){
    _controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(la, ln),zoom: 16.0)
    ));
    Marker mrker = Marker(markerId: MarkerId('1'),position: LatLng(la,ln));
    setState(() {
      markers.add(mrker);
    });
  }

  Future createShop() async{
    Dio dio = Dio();
    Map<String, dynamic> params = Map();
    params['idUserShop'] = systemInstance.userId;
    params['shopName'] = _shopName.text;
    params['shopPhone'] = _shopPhone.text;
    params['latitude'] = lat.toString();
    params['longtitude'] = lng.toString();
    params['officeHours'] = time1 + '-' + time2;
    params['shopComment'] = _shopComment.text;
    if(_image != null){
      params['fileImg'] = MultipartFile.fromBytes(_image.readAsBytesSync(), filename: "filename.png");
    }else{
      params['shopImg'] = shopImg;
    }

    params['shopStatus'] = shopStatus;
    FormData formData = FormData.fromMap(params);
    dio.options.headers["Authorization"] = "Bearer ${systemInstance.token}";
    dio
        .post('${Config.API_URL}/shop/save', data: formData)
        .then((response) {
      print(response);
      Map retMap = jsonDecode(response.toString());
      int status = retMap['status'];
      if (status == 0) {
        CoolAlert.show(context: context, type: CoolAlertType.success, text: 'ทำรายการสำเร็จ');
      }else{
        CoolAlert.show(context: context, type: CoolAlertType.error, text: 'ทำรายการไม่สำเร็จ');
      }
    });
  }

  Future getData() async{
    Map<String, String> header = {"Authorization": "Bearer ${systemInstance.token}"};
    var data = await http.post('${Config.API_URL}/shop/detail?idUserShop=${int.parse(systemInstance.userId)}',headers: header);
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    print(jsonData);
    if(jsonData['shopName'] != null){
        _shopName.text = jsonData['shopName'];
        _shopPhone.text = jsonData['shopPhone'];
        time1 = jsonData['officeHours'].toString().substring(0,5);
        time2 = jsonData['officeHours'].toString().substring(6,11);
        shopImg = jsonData['shopImg'];
        shopStatus = jsonData['shopStatus'];
        _shopComment.text = jsonData['shopComment'];
        lat = double.parse(jsonData['latitude']);
        lng = double.parse(jsonData['longtitude']);
        await movetoGPS(lat,lng);
        setState(() {
          
        });

    }
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    getData();
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ตั้งค่าร้าน'),
        actions: [
          IconButton(icon: Icon(Icons.check),
              onPressed: (){
                if(shopImg.isEmpty && _image?.path?.isEmpty != false || _shopName.text.isEmpty | _shopPhone.text.isEmpty | time1.isEmpty | time2.isEmpty | lat.toString().isEmpty){
                  CoolAlert.show(context: context, type: CoolAlertType.warning, text: 'กรุณากรอกข้อมูลให้ครบถ้วน');

                }else{
                  createShop();
                }
              },
          )
        ],
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.teal),),) : SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 3.5,
              width: MediaQuery.of(context).size.width - 20,
              child: _image == null ? Container(
                  child: Center(
                      child: Image.network(
                        "${Config.API_URL}/shop/image?imageName=${shopImg}",
                        headers: {"Authorization": "Bearer ${systemInstance.token}"},
                        fit: BoxFit.cover,
                      ),
                  ),
                  color: Colors.grey[200],
                )  : Image.file(_image,fit: BoxFit.cover,),

            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton.icon(
                  label: Text('รูปภาพ', style: TextStyle(color: Colors.white),),
                  icon: Icon(Icons.add_photo_alternate, color: Colors.white,),
                  color: Colors.teal,
                  onPressed: getImage,
                ),
                SizedBox(width: 15.0,),
                RaisedButton.icon(
                  label: Text('รูปถ่าย', style: TextStyle(color: Colors.white),),
                  icon: Icon(Icons.add_a_photo, color: Colors.white,),
                  color: Colors.teal,
                  onPressed: getCamera,
                ),
              ],
            ),

            ListTile(
              leading: Icon(Icons.label_outline, color: Colors.teal,),
              title: TextField(
                enabled: true,
                decoration: InputDecoration(hintText: 'ชื่อร้านค้า'),
                maxLength: 35,
                keyboardType: TextInputType.text,
                controller: _shopName,
              ),
            ),
            ListTile(
              leading: Icon(Icons.phone, color: Colors.teal,),
              title: TextField(
                decoration: InputDecoration(hintText: 'หมายเลขโทรศัพร้าน'),
                maxLength: 10,
                keyboardType: TextInputType.phone,
                controller: _shopPhone,
              ),
            ),
            ListTile(
              leading: Icon(Icons.timer, color: Colors.teal,),
              title:Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          OutlineButton(
                            borderSide: BorderSide(color: Colors.teal),
                            child: Text('เปิดร้าน'),
                            onPressed: (){
                              selectTime1(context);
                            },
                          ),
                          Text('     '+'${time1}'),
                        ],
                      ),

                      Row(
                        children: <Widget>[
                          OutlineButton(
                            borderSide: BorderSide(color: Colors.teal),
                            child: Text('ปิดร้าน '),
                            onPressed: (){
                              selectTime2(context);
                            },
                          ),
                          Text('     '+'${time2}'),
                        ],
                      ),
                    ],
                  )
              ),
            ListTile(
              leading: Icon(Icons.location_pin, color: Colors.teal,),
              title: OutlineButton(
                borderSide: BorderSide(color: Colors.teal),
                child: Text('กดปุ่มเพื่อปักหมุดร้าน'),
                onPressed: (){
                  _getCerrentLocation();
                },
              ),
            ),
            Container(
              child: Container(
                height: 200.0,
                width: 350.0,
                //width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(16.439625, 102.828728),
                      zoom: 10.0
                  ),
                  markers: Set.from(markers),
                  onMapCreated: (controller){
                    setState(() {
                      _controller = controller;
                    });
                  },
               ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.comment),
              title: TextField(
                decoration: InputDecoration(hintText: 'จุดสังเกตเช่น ซอย ถนน หรือจุดสำคัญ'),
                maxLength: 100,
                maxLines: 5,
                keyboardType: TextInputType.text,
                controller: _shopComment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
