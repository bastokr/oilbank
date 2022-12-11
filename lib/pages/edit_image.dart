import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oilstock/user/user_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:oilstock/views/lib.dart';
import 'package:oilstock/widgets/appbar_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class EditImagePage extends StatefulWidget {
  const EditImagePage({Key? key}) : super(key: key);

  @override
  _EditImagePageState createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  var user = UserData.myUser;

/*
  Future<String> uploadImage(File file) async {
    Dio dio = new Dio();
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
    });
    var response =
        await dio.post(imgUrl + '/users/profileimage.php', data: formData);
    return response.data['id'];
  }
*/
  bool kIsWeb = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
              width: 330,
              child: const Text(
                "Upload a photo of yourself:",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              )),
          Padding(
              padding: EdgeInsets.only(top: 20),
              child: SizedBox(
                  width: 330,
                  child: GestureDetector(
                    onTap: () async {
                      /*
                      final image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);

                      if (image == null) return;

                      final location = await getApplicationDocumentsDirectory();
                      final name = basename(image.path);
                      final imageFile = File('${location.path}/$name');
                      final newImage =
                          await File(image.path).copy(imageFile.path);
                      setState(
                          () => user = user.copy(imagePath: newImage.path));

                          */
                    },
                    child: kIsWeb
                        ? Image.network(user.image)
                        : Image.file(
                            File(user.image),
                            width: 100,
                            height: 100,
                          ),
                  ))),
          Padding(
              padding: EdgeInsets.only(top: 40),
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 330,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final ImagePicker _picker = ImagePicker();
                        XFile? selectImage = await _picker.pickImage(
                          //이미지를 선택
                          source: ImageSource.gallery, //위치는 갤러리
                          maxHeight: 75,
                          maxWidth: 75,
                          imageQuality: 30, // 이미지 크기 압축을 위해 퀄리티를 30으로 낮춤.
                        );

                        if (selectImage != null) {
                          dynamic sendData = selectImage.path;
                          kIsWeb = false;

                          user.image = selectImage.path;
                          setState(() {});

                          FormData data = FormData.fromMap({
                            "image": await MultipartFile.fromFile(
                              selectImage.path,
                              filename: "aaa.jpg",
                            ),
                          });

                          //  patchUserProfileImage(data);

                          // uploadImage(MultipartFile.fromFile(sendData).);
                        }
                      },
                      child: const Text(
                        'Update',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  )))
        ],
      ),
    );
  }
}
