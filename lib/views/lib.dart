import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiUrl = "luckytransportca.cafe24.com";
const String imgUrl = "https://luckytransportca.cafe24.com/mrfact";

class NetworkHelper {
  //NetworkHelper(this.url3 ,this.postData);
  final String url3;
  // final Object postData;

  NetworkHelper(this.url3);
  Future getData() async {
    var url = Uri.https(apiUrl, url3);
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }

  Future getPostData(postData, gubun) async {
    print(apiUrl + url3);
    var url = Uri.https(apiUrl, url3, gubun);
    http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body:
          postData/*<String, String>{
        'user_id': 'user_id_value',
        'user_pwd': 'user_pwd_value'
      }*/
      ,
    );
    if (response.statusCode == 200) {
      String data = response.body;
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }
}
