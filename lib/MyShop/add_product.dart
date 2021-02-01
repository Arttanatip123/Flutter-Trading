import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'package:cool_alert/cool_alert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:myapp/config.dart';
import 'package:myapp/system/SystemInstance.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;


class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController _productName = TextEditingController();
  TextEditingController _productPrice = TextEditingController();
  TextEditingController _productAmount = TextEditingController();
  List _lstType = ['พืชไร่','พืชสวน','ปศุสัตว์','ประมง'];
  List _lstSubType = ['ผลผลิต','อุปกรณ์'];
  String userName = "aaa";
  String _lstTypeVal;
  String _lstSubTypeVal;

  String status = '';
  String errMessage = 'Error Uploading Image';
  File tmpFile;
  String base64Image;
  final picker = ImagePicker();
  var pickedFile;
  File _image;
  File _f;

  @override
  void initState() {
    super.initState();
    defaultImage();

  }

  defaultImage() async {
    _f = await getImageFileFromAssets('NoImage.png');
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('images/$path');
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  @override
  Widget build(BuildContext context) {
    SystemInstance instance = SystemInstance();
    String userId = instance.userId;

    Future getImage() async{

        pickedFile = await picker.getImage(source: ImageSource.gallery,maxHeight: 300.0,maxWidth: 300.0);

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        }else{
          _image = _f;
        }
      });
    }
    Future getCamera() async{
      File f = await getImageFileFromAssets('images/NoImage.png');
      pickedFile = await picker.getImage(source: ImageSource.camera, maxHeight: 300.0, maxWidth: 300.0);

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        }else{
          _image = _f;
        }
      });
    }

    Future onClickAdd() async {
      CoolAlert.show(context: context, type: CoolAlertType.loading);
      Dio dio = Dio();
      Map<String, dynamic> params = Map();
      params['idUserShop'] = userId;
      params['productName'] = _productName.text;
      params['productPrice'] = _productPrice.text;
      params['productAmount'] = _productAmount.text;
      params['productType'] = _lstTypeVal;
      params['productSubType'] = _lstSubTypeVal;
      if(_image == null){
        _image = _f;
      }
      params['fileImg'] = MultipartFile.fromBytes(_image.readAsBytesSync(), filename: "filename.png");
      FormData formData = FormData.fromMap(params);
      dio.post('${Config.API_URL}/product/save', data: formData).then((response){
        print(response);
        Map retMap = jsonDecode(response.toString());
        int status = retMap['status'];
        if (status == 0) {
          Navigator.pop(context);
          Navigator.pop(context);
          setState(() {

          });
        }else{
          CoolAlert.show(context: context, type: CoolAlertType.error, text: 'ทำรายการไม่สำเร็จ');
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มสินค้า'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if(_productName.text.isNotEmpty | _productPrice.text.isNotEmpty | _productAmount.text.isNotEmpty){
                onClickAdd();
              }else {
                CoolAlert.show(context: context, type: CoolAlertType.warning, text: 'กรุณากรอกข้อมูลให้ครบถ้วน');
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.label, color: Colors.teal,),
              title: TextField(
                controller: _productName,
                decoration: InputDecoration(hintText: 'ชื่อสินค้า'),
                keyboardType: TextInputType.text,

              ),
            ),
            ListTile(
              leading: Icon(Icons.monetization_on, color: Colors.teal,),
              title: TextField(
                controller: _productPrice,
                decoration: InputDecoration(hintText: 'ราคาสินค้า'),
                keyboardType: TextInputType.number,
              ),
            ),
            ListTile(
              leading: Icon(Icons.inbox, color: Colors.teal,),
              title: TextField(
                controller: _productAmount,
                decoration: InputDecoration(hintText: 'จำนวนสินค้า'),
                keyboardType: TextInputType.number,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: DropdownButton(
                  hint: Text('ประเภทสินค้า'),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.teal,),
                  iconSize: 36.0,
                  isExpanded: true,
                  value: _lstTypeVal,
                  onChanged: (value){
                    setState(() {
                      _lstTypeVal = value;
                    });
                  },
                items: _lstType.map((value){
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value,textAlign: TextAlign.center,),
                  );
                }).toList(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: DropdownButton(
                hint: Text('ประเภทสินค้าย่อย'),
                icon: Icon(Icons.arrow_drop_down, color: Colors.teal,),
                iconSize: 36.0,
                isExpanded: true,
                value: _lstSubTypeVal,
                onChanged: (value){
                  setState(() {
                    _lstSubTypeVal = value;
                  });
                },
                items: _lstSubType.map((value){
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Center(
                child: _image == null ? Container(
                    child: Center(
                        //child: Image.file(_image),
                        child: Image.asset('images/NoImage.png'),
                    ),
                    color: Colors.grey[200],
                    width: 250.0,
                    height: 250.0,
                )  : Image.file(_image),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton.icon(
                  label: Text('รูปภาพ', style: TextStyle(color: Colors.white),),
                  color: Colors.teal,
                  icon: Icon(Icons.add_photo_alternate, color: Colors.white,),
                  onPressed: getImage,
                ),
                SizedBox(width: 20.0,),
                RaisedButton.icon(
                  label: Text('ถ่ายรูป', style: TextStyle(color: Colors.white),),
                  color: Colors.teal,
                  icon: Icon(Icons.camera_alt, color: Colors.white,),
                  onPressed: getCamera,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
