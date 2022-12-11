import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oilstock/constants/app_constants.dart';
import 'package:oilstock/constants/color_constants.dart';
import 'package:oilstock/constants/constants.dart';
import 'package:oilstock/models/models.dart';
import 'package:oilstock/providers/providers.dart';
import 'package:oilstock/widgets/loading_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:validators/validators.dart';

class ExportAdd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.exportADDTitle,
          style: TextStyle(color: ColorConstants.primaryColor),
        ),
        centerTitle: true,
      ),
      body: ExportAddPage(),
    );
  }
}

class ExportAddPage extends StatefulWidget {
  const ExportAddPage({super.key});

  @override
  State createState() => _ExportAddPageState();
}

class _ExportAddPageState extends State<ExportAddPage> {
  TextEditingController? controllerName;
  TextEditingController? controllerExp;
  TextEditingController? controllerTitle;
  TextEditingController? controllerEmail;
  TextEditingController? controllerTelNo;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String id = '';
  String name = '';
  String title = '';
  String exp = '';
  String photoUrl = '';
  String email = '';
  String telNo = '';

  bool isLoading = false;
  File? avatarImageFile;
  late SettingProvider settingProvider;

  final FocusNode focusNodeName = FocusNode();
  final FocusNode focusNodeTitle = FocusNode();
  final FocusNode focusNodeEmail = FocusNode();
  final FocusNode focusNodeExp = FocusNode();
  final FocusNode focusNodeTelNo = FocusNode();

  @override
  void initState() {
    super.initState();
    settingProvider = context.read<SettingProvider>();
    readLocal();
  }

  void readLocal() {
    setState(() {
      id = settingProvider.getPref(FirestoreConstants.id) ?? "";
      name = settingProvider.getPref(FirestoreConstants.nickname) ?? "";
      title = settingProvider.getPref(FirestoreConstants.title) ?? "";
      exp = settingProvider.getPref(FirestoreConstants.exp) ?? "";
      photoUrl = settingProvider.getPref(FirestoreConstants.photoUrl) ?? "";
    });

    controllerName = TextEditingController(text: name);
    controllerTitle = TextEditingController(text: title);
    controllerExp = TextEditingController(text: exp);
    controllerEmail = TextEditingController(text: email);
    controllerTelNo = TextEditingController(text: telNo);
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile = await imagePicker
        .getImage(source: ImageSource.gallery)
        .catchError((err) {
      Fluttertoast.showToast(msg: err.toString());
    });
    File? image;
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = id;
    UploadTask uploadTask =
        settingProvider.uploadFile(avatarImageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      photoUrl = await snapshot.ref.getDownloadURL();
      UserChat updateInfo = UserChat(
        id: id,
        photoUrl: photoUrl,
        nickname: name,
        aboutMe: title,
      );

      settingProvider
          .updateDataFirestore(
              FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
          .then((data) async {
        await settingProvider.setPref(FirestoreConstants.photoUrl, photoUrl);
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: "Upload success");
      }).catchError((err) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: err.toString());
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  Future<http.Response> sendTokenMessage() {
    return http.post(
      Uri.parse('https://iukj.cafe24.com/SETDATA/ybauction/MENU_MGT_S005_S100'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "mb1": id,
        "mb4": photoUrl,
        "mb2": name,
        "mb3": title,
        "mb5": exp,
        "mb7": email,
        "mb8": telNo,
        "mb6": "N"
      }),
    );
  }

  void handleUpdateData() {
    focusNodeName.unfocus();
    focusNodeTitle.unfocus();
    focusNodeEmail.unfocus();
    focusNodeExp.unfocus();
    focusNodeTelNo.unfocus();

    setState(() {
      isLoading = true;
    });
    UserChat updateInfo = UserChat(
      id: id,
      photoUrl: photoUrl,
      nickname: name,
      aboutMe: title,
    );
    settingProvider
        .updateDataFirestore(
            FirestoreConstants.pathUserCollection, id, updateInfo.toJson())
        .then((data) async {
      await settingProvider.setPref(FirestoreConstants.nickname, name);
      await settingProvider.setPref(FirestoreConstants.aboutMe, title);
      await settingProvider.setPref(FirestoreConstants.photoUrl, photoUrl);

      setState(() {
        isLoading = false;
      });

      final FormState? form = _formKey.currentState;
      if (form!.validate()) {
        Future<http.Response> rs = sendTokenMessage();
        rs.then((value) => {
              showCupertinoDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return CupertinoAlertDialog(
                      title: const Text('등록'),
                      content: const Text('전문가상담등록완료'),
                      actions: [
                        // The "Yes" button

                        // The "No" button
                        CupertinoDialogAction(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('확인'),
                          isDefaultAction: false,
                          isDestructiveAction: false,
                        )
                      ],
                    );
                  }).then((value) => {Navigator.of(context).pop()}),
            });

        print('Form is valid');
      } else {
        print('Form is invalid');
      }
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Avatar
              CupertinoButton(
                onPressed: getImage,
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: avatarImageFile == null
                      ? photoUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(45),
                              child: Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                width: 90,
                                height: 90,
                                errorBuilder: (context, object, stackTrace) {
                                  return Icon(
                                    Icons.account_circle,
                                    size: 90,
                                    color: ColorConstants.greyColor,
                                  );
                                },
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 90,
                                    height: 90,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: ColorConstants.themeColor,
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.account_circle,
                              size: 90,
                              color: ColorConstants.greyColor,
                            )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(45),
                          child: Image.file(
                            avatarImageFile!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              Form(
                key: _formKey,
                // Input
                child: Column(
                  children: <Widget>[
                    // Username
                    Row(
                      children: [],
                    ),
                    Container(
                      child: Text(
                        '성명',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.primaryColor),
                      ),
                      margin: EdgeInsets.only(left: 10, bottom: 5, top: 10),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                            primaryColor: ColorConstants.primaryColor),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '성명',
                            contentPadding: EdgeInsets.all(5),
                            hintStyle:
                                TextStyle(color: ColorConstants.greyColor),
                          ),
                          controller: controllerName,
                          onChanged: (value) {
                            name = value;
                          },
                          focusNode: focusNodeName,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30, right: 30),
                    ),
                    Container(
                      child: Text(
                        '타이틀',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.primaryColor),
                      ),
                      margin: EdgeInsets.only(left: 10, bottom: 5, top: 10),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                            primaryColor: ColorConstants.primaryColor),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '타이틀',
                            contentPadding: EdgeInsets.all(5),
                            hintStyle:
                                TextStyle(color: ColorConstants.greyColor),
                          ),
                          controller: controllerTitle,
                          onChanged: (value) {
                            title = value;
                          },
                          focusNode: focusNodeTitle,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30, right: 30),
                    ),
                    // About me

                    Container(
                      child: Text(
                        '소개글',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.primaryColor),
                      ),
                      margin: EdgeInsets.only(left: 10, top: 30, bottom: 5),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                            primaryColor: ColorConstants.primaryColor),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '소개글',
                            contentPadding: EdgeInsets.all(5),
                            hintStyle:
                                TextStyle(color: ColorConstants.greyColor),
                          ),
                          controller: controllerExp,
                          onChanged: (value) {
                            exp = value;
                          },
                          focusNode: focusNodeExp,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30, right: 30),
                    ),
                    Container(
                      child: Text(
                        '이메일',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.primaryColor),
                      ),
                      margin: EdgeInsets.only(left: 10, top: 30, bottom: 5),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                            primaryColor: ColorConstants.primaryColor),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter email";
                            } else if (isEmail(value)) {
                              return "Please enter valid email";
                            }
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: '이메일',
                            contentPadding: EdgeInsets.all(5),
                            hintStyle:
                                TextStyle(color: ColorConstants.greyColor),
                          ),
                          controller: controllerEmail,
                          onChanged: (value) {
                            email = value;
                          },
                          focusNode: focusNodeEmail,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30, right: 30),
                    ),
                    Container(
                      child: Text(
                        '전화번호',
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.primaryColor),
                      ),
                      margin: EdgeInsets.only(left: 10, top: 30, bottom: 5),
                    ),
                    Container(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                            primaryColor: ColorConstants.primaryColor),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '전화번호',
                            contentPadding: EdgeInsets.all(5),
                            hintStyle:
                                TextStyle(color: ColorConstants.greyColor),
                          ),
                          controller: controllerTelNo,
                          onChanged: (value) {
                            telNo = value;
                          },
                          focusNode: focusNodeTelNo,
                        ),
                      ),
                      margin: EdgeInsets.only(left: 30, right: 30),
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ),
              // Button
              Container(
                child: TextButton(
                  onPressed: handleUpdateData,
                  child: Text(
                    '전문가 신청 하기',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        ColorConstants.primaryColor),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.fromLTRB(30, 10, 30, 10),
                    ),
                  ),
                ),
                margin: EdgeInsets.only(top: 50, bottom: 50),
              ),
            ],
          ),
          padding: EdgeInsets.only(left: 15, right: 15),
        ),

        // Loading
        Positioned(child: isLoading ? LoadingView() : SizedBox.shrink()),
      ],
    );
  }
}
