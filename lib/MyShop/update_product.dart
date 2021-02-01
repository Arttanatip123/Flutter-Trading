import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:cool_alert/cool_alert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:myapp/config.dart';
import 'package:myapp/system/SystemInstance.dart';
import 'package:path_provider/path_provider.dart';

class UpdateProduct extends StatefulWidget {
  final int idProduct;
  final String productImg;

  const UpdateProduct({Key key, this.idProduct, this.productImg})
      : super(key: key);

  @override
  _UpdateProductState createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {
  TextEditingController _productName = TextEditingController();
  TextEditingController _productPrice = TextEditingController();
  TextEditingController _productAmount = TextEditingController();
  List _lstType = ['พืชไร่', 'พืชสวน', 'ปศุสัตว์', 'ประมง'];
  List _lstSubType = ['ผลผลิต', 'อุปกรณ์'];
  String _type;
  String _subType;
  int productPrice;

  String status = '';
  String errMessage = 'Error Uploading Image';
  File _image;
  File tmpFile;
  final picker = ImagePicker();
  var pickedFile;

  _getProduct() async {
    var data =
        await http.get('${Config.API_URL}/product/detail/${widget.idProduct}');
    var da = utf8.decode(data.bodyBytes);
    var jsonData = jsonDecode(da);
    _productName.text = jsonData['productName'];
    _productPrice.text = jsonData['productPrice'].toString();
    _productAmount.text = jsonData['productAmount'].toString();
    setState(() {
      _type = jsonData['productType'];
      _subType = jsonData['productSubType'];
    });
  }

  @override
  void initState() {
    super.initState();
    _getProduct();
  }

  @override
  Widget build(BuildContext context) {
    SystemInstance instance = SystemInstance();
    String userId = instance.userId;

    Future getImage() async {
      pickedFile = await picker.getImage(
          source: ImageSource.gallery, maxHeight: 300.0, maxWidth: 300.0);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {}
      });
    }

    Future getCamera() async {
      pickedFile = await picker.getImage(
          source: ImageSource.camera, maxHeight: 300.0, maxWidth: 300.0);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {}
      });
    }

    onClickUpdate() {
      CoolAlert.show(context: context, type: CoolAlertType.loading);
      Dio dio = Dio();
      Map<String, dynamic> params = Map();
      params['idProduct'] = widget.idProduct.toString();
      params['idUserShop'] = userId.toString();
      params['productName'] = _productName.text;
      params['productPrice'] = _productPrice.text;
      params['productAmount'] = _productAmount.text;
      params['productType'] = _type;
      params['productSubType'] = _subType;
      if (_image != null) {
        params['fileImg'] = MultipartFile.fromBytes(_image.readAsBytesSync(),
            filename: "filename.png");
      }
      FormData formData = FormData.fromMap(params);
      dio
          .post('${Config.API_URL}/product/update', data: formData)
          .then((response) {
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

    removeProduct() async{
      var data = await http.post('${Config.API_URL}/product/remove/?productId=${widget.idProduct}');
      var jsonData = json.decode(data.body);
      if(jsonData['status'] == 0){
        Navigator.pop(context);
        setState(() {

        });
      }else{
        CoolAlert.show(context: context, type: CoolAlertType.error, text: 'ทำรายการไม่สำเร็จ');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขสินค้า'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              onClickUpdate();
              //startUpload();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.label,
                color: Colors.teal,
              ),
              title: TextFormField(
                controller: _productName,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'ชื่อสินค้า',
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.monetization_on,
                color: Colors.teal,
              ),
              title: TextFormField(
                controller: _productPrice,
                decoration: InputDecoration(labelText: 'ราคาสินค้า'),
                keyboardType: TextInputType.number,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.inbox,
                color: Colors.teal,
              ),
              title: TextFormField(
                controller: _productAmount,
                decoration: InputDecoration(labelText: 'จำนวนสินค้า'),
                keyboardType: TextInputType.number,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: DropdownButton(
                hint: Text('ประเภทสินค้า'),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.teal,
                ),
                iconSize: 36.0,
                isExpanded: true,
                value: _type,
                onChanged: (value) {
                  setState(() {
                    _type = value;
                  });
                },
                items: _lstType.map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: DropdownButton(
                hint: Text('ประเภทสินค้าย่อย'),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.teal,
                ),
                iconSize: 36.0,
                isExpanded: true,
                value: _subType,
                onChanged: (value) {
                  setState(() {
                    _subType = value;
                  });
                },
                items: _lstSubType.map((value) {
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
                child: _image == null
                    ? Container(
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: NetworkImage(
                                "${Config.API_URL}/product/image?imageName=${widget.productImg}"),
                          )),
                        ),
                        color: Colors.grey[200],
                        width: 250.0,
                        height: 250.0,
                      )
                    : Image.file(_image),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton.icon(
                  label: Text(
                    'รูปภาพ',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.teal,
                  icon: Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                  onPressed: getImage,
                ),
                SizedBox(
                  width: 20.0,
                ),
                RaisedButton.icon(
                  label: Text(
                    'ถ่ายรูป',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.teal,
                  icon: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                  onPressed: getCamera,
                ),
              ],
            ),
            Container(
              width: 300.0,
              child: RaisedButton.icon(
                label: Text(
                  'ลบสินค้า',
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.red,
                icon: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                onPressed: (){
                  removeProduct();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
