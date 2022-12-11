import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:oilstock/constants/constants.dart';
import 'package:oilstock/providers/providers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/message_memo.dart';
import '../widgets/widgets.dart';
import 'full_photo_page_byte.dart';
import 'pages.dart';
import 'package:oilstock/utils/database_memo.dart';
import 'package:image/image.dart' as ImageProcess;

class MemoPage extends StatefulWidget {
  MemoPage({Key? key, required this.arguments}) : super(key: key);

  final MemoPageArguments arguments;

  @override
  MemoPageState createState() => MemoPageState();
}

class MemoPageState extends State<MemoPage> {
  late String currentUserId;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<QueryDocumentSnapshot> listMessage = [];
  int _limit = 20;
  int _limitIncrement = 20;
  String groupMemoId = "";

  File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late MemoProvider memoProvider;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    memoProvider = context.read<MemoProvider>();
    authProvider = context.read<AuthProvider>();
    memoList = getAllDatas();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
    registerNotification();
  }

  Future<List<MessageMemo>> getAllDatas() async {
    return await DatabaseMemo().getAllDatas();
  }

  late Future<List<MessageMemo>> memoList;
  _scrollListener() {
    if (!listScrollController.hasClients) return;
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= listMessage.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void registerNotification() {
    firebaseMessaging.requestPermission();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void readLocal() {
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
    String peerId = widget.arguments.peerId;
    if (currentUserId.compareTo(peerId) > 0) {
      groupMemoId = '$currentUserId-$peerId';
    } else {
      groupMemoId = '$peerId-$currentUserId';
    }

    memoProvider.updateDataFirestore(
      FirestoreConstants.pathUserCollection,
      currentUserId,
      {FirestoreConstants.chattingWith: peerId},
    );
  }

  var _byteImage;
  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();

    PickedFile? pickedFile;

    pickedFile = await imagePicker.getImage(
      source: ImageSource.gallery,
      maxWidth: 400.0,
      maxHeight: 400.0,
    );
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);

      final _imageFile = ImageProcess.decodeImage(imageFile!.readAsBytesSync());
      _byteImage = base64Encode(ImageProcess.encodePng(_imageFile!));

      onSendMessage(_byteImage.toString(), TypeMessage.imageByte);
      if (imageFile != null) {
        setState(() {
          // isLoading = true;
        });
      }
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      memoProvider
          .sendMessage(content, type, groupMemoId, currentUserId,
              widget.arguments.peerId)
          .then((value) {
        setState(() {
          memoList = getAllDatas();
        });
      });
      if (listScrollController.hasClients) {
        listScrollController.animateTo(0,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send', backgroundColor: ColorConstants.greyColor);
    }
  }

  String formatISOTime(DateTime date) {
    //converts date into the following format:
// or 2019-06-04T12:08:56.235-0700
    var duration = date.timeZoneOffset;
    if (duration.isNegative)
      return (DateFormat("yyyy-MM-ddTHH:mm:ss.mmm").format(date) +
          "-${duration.inHours.toString().padLeft(2, '0')}${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
    else
      return (DateFormat("yyyy-MM-ddTHH:mm:ss.mmm").format(date) +
          "+${duration.inHours.toString().padLeft(2, '0')}${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, '0')}");
  }

  Widget buildItem(int index, MessageMemo messageMemo) {
    if (messageMemo != null) {
      // Right (my message)
      final splitted = messageMemo.content.split(' ');
      var date = new DateTime.fromMicrosecondsSinceEpoch(
          int.parse(messageMemo.timestamp));

      var time = DateFormat('M/d h:m').format(date);

      return Row(
        children: <Widget>[
          messageMemo.type == TypeMessage.text

              // Text
              ? Container(
                  child: GestureDetector(
                    child: RichText(
                        text: TextSpan(children: [
                      for (var str in splitted)
                        if (str.indexOf('www') > -1 || str.indexOf('http') > -1)
                          TextSpan(
                            style: TextStyle(color: Colors.blue),
                            text: str,
                            /* recognizer: new TapGestureRecognizer()
                                ..onTap = () {
                                  launchUrl(Uri.parse(str),
                                      mode: LaunchMode.externalApplication);
                                }*/
                          )
                        else
                          TextSpan(
                            style: TextStyle(color: Colors.black),
                            text: str,
                          ),
                      /*TextSpan(
                        style: TextStyle(color: Colors.green),
                        text: "\n\r" + time,
                      )
                      */
                    ])),
                    onTap: () {
                      var _url = '';
                      final splitted = messageMemo.content.split(' ');
                      for (var _url in splitted) {
                        var urlPattern =
                            r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
                        RegExpMatch? match =
                            RegExp(urlPattern, caseSensitive: false)
                                .firstMatch(_url);
                        if (match != null) {
                          launchUrl(Uri.parse(match![0]!),
                              mode: LaunchMode.externalApplication);
                        } else {
                          var urlPattern2 =
                              r"([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
                          RegExpMatch? match2 =
                              RegExp(urlPattern2, caseSensitive: false)
                                  .firstMatch(_url);

                          if (match2 != null)
                            launchUrl(Uri.parse('http://' + match2![0]!),
                                mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                  ),
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                  //width: 200,
                  decoration: BoxDecoration(
                      color: ColorConstants.greyColor2,
                      borderRadius: BorderRadius.circular(8)),
                  margin: EdgeInsets.only(bottom: 10, right: 10),
                )
              : messageMemo.type == TypeMessage.imageByte
                  ? Container(
                      child: GestureDetector(
                        child: Image.memory(
                          Base64Decoder().convert(messageMemo.content),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        onHorizontalDragDown: (details) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              String contentText = "Content of Dialog";
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    title: Text("선택한 이미지를...."),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          "닫기",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          DatabaseMemo()
                                              .deleteData(int.parse(
                                                  messageMemo.timestamp))
                                              .then((value) {
                                            setState(() {
                                              memoList = getAllDatas();
                                              Navigator.pop(context);
                                            });
                                          });
                                        },
                                        child: Text(
                                          "삭제",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FullPhotoBytePage(
                                                byte: messageMemo.content,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          "확대보기",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );

                          //s _delete(context, messageMemo);
                        },
                      ),
                      margin: EdgeInsets.only(bottom: 20, right: 10),
                    )
                  : Container(
                      child: Image.asset(
                        'images/${messageMemo.content}.gif',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20 : 10,
                          right: 10),
                    ),
          Container(
              child: GestureDetector(
            child: Text(
              time,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            onTap: () {
              //   final Uri _url = Uri.parse('https://www.naver.com');

              showDialog(
                context: context,
                builder: (context) {
                  String contentText = "Content of Dialog";
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Text("선택한 메모를...."),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "닫기",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              DatabaseMemo()
                                  .deleteData(int.parse(messageMemo.timestamp))
                                  .then((value) {
                                setState(() {
                                  memoList = getAllDatas();
                                  Navigator.pop(context);
                                });
                              });
                            },
                            child: Text(
                              "삭제",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          )),
        ],
        mainAxisAlignment: MainAxisAlignment.start,
      );
    } else {
      return SizedBox.shrink();
    }
  }

  void _delete(BuildContext context, MessageMemo messageMemo) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: const Text('삭제하기'),
            content: const Text('해당물건을 삭제하시겠습니까?'),
            actions: [
              // The "Yes" button
              CupertinoDialogAction(
                onPressed: () {
                  DatabaseMemo()
                      .deleteData(int.parse(messageMemo.timestamp))
                      .then((value) {
                    setState(() {
                      memoList = getAllDatas();
                      Navigator.pop(context);
                    });
                  });

                  //  Navigator.of(context).pop();
                },
                child: const Text('삭제'),
                isDefaultAction: true,
                isDestructiveAction: true,
              ),
              // The "No" button
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullPhotoBytePage(
                        byte: messageMemo.content,
                      ),
                    ),
                  );
                },
                child: const Text('확대'),
                isDefaultAction: false,
                isDestructiveAction: false,
              )
            ],
          );
        });
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) ==
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage[index - 1].get(FirestoreConstants.idFrom) !=
                currentUserId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      memoProvider.updateDataFirestore(
        FirestoreConstants.pathUserCollection,
        currentUserId,
        {FirestoreConstants.chattingWith: null},
      );
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            this.widget.arguments.peerNickname,
            style: TextStyle(color: ColorConstants.primaryColor),
          ),
          centerTitle: true,
          actions: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Color.fromARGB(255, 179, 109, 5),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(
                    color: Colors.white,
                    // <-- Icon
                    Icons.delete,
                    size: 24.0,
                  ),
                  label: const Text('전체삭제',
                      style: TextStyle(color: Colors.white)), // <-- Text
                ),
              ],
            )
          ]),
      body: SafeArea(
        child: WillPopScope(
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  // List of messages
                  buildListMessage(),

                  // Sticker
                  // isShowSticker ? buildSticker() : SizedBox.shrink(),

                  // Input content
                  buildInput(),
                ],
              ),

              // Loading
              buildLoading()
            ],
          ),
          onWillPop: onBackPress,
        ),
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? LoadingView() : SizedBox.shrink(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: getImage,
                color: ColorConstants.primaryColor,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, TypeMessage.text);
                },
                style:
                    TextStyle(color: ColorConstants.primaryColor, fontSize: 15),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: '메모 입력...',
                  hintStyle: TextStyle(color: ColorConstants.greyColor),
                ),
                focusNode: focusNode,
                autofocus: true,
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: Icon(Icons.add_card),
                onPressed: () =>
                    onSendMessage(textEditingController.text, TypeMessage.text),
                color: ColorConstants.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: ColorConstants.greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: FutureBuilder(
          future: memoList,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var memoList = snapshot.data as List<MessageMemo>;
              if (memoList.length > 0) {
                return ListView.builder(
                  itemCount: memoList.length,
                  itemBuilder: (context, index) => (memoList[index].type == 3)
                      ? buildItem(index, memoList[index])
                      : buildItem(index, memoList[index]),
                  reverse: true,
                  controller: listScrollController,
                );
              } else {
                return Center(child: Text("No message here yet..."));
              }
            } else {
              return Center(
                  child: CircularProgressIndicator(
                color: ColorConstants.themeColor,
              ));
            }
          }),
    );
  }
}

class MemoPageArguments {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;
  final String token;
  MemoPageArguments(
      {required this.peerId,
      required this.peerAvatar,
      required this.peerNickname,
      required this.token});
}
