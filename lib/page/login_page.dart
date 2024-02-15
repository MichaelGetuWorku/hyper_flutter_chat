import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sendbird_chat_sample/component/widgets.dart';
import 'package:sendbird_chat_sample/main.dart';
import 'package:sendbird_chat_sample/notifications/push_manager.dart';
import 'package:sendbird_chat_sample/utils/app_prefs.dart';
import 'package:sendbird_chat_sample/utils/user_prefs.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:sendbird_chat_widget/sendbird_chat_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final textEditingController = TextEditingController();

  bool? isLoginUserId;
  bool useCollectionCaching = AppPrefs.defaultUseCollectionCaching;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    PushManager.removeBadge();

    final loginUserId = await UserPrefs.getLoginUserId();
    final useCaching = AppPrefs().getUseCollectionCaching();

    setState(() {
      isLoginUserId = (loginUserId != null);
      useCollectionCaching = useCaching;
    });

    if (loginUserId != null) {
      _login(loginUserId);
    }
  }

  Future<void> _login(String userId) async {
    final isGranted = await PushManager.requestPermission();
    if (isGranted) {
      await SendbirdChat.init(
        appId: yourAppId,
        options: SendbirdChatOptions(
          useCollectionCaching: useCollectionCaching,
        ),
      );

      await SendbirdChat.connect(userId);

      await UserPrefs.setLoginUserId();
      if (SendbirdChat.getPendingPushToken() != null) {
        await PushManager.registerPushToken();
      }
      await SendbirdChatWidget.cacheNotificationInfo();

      if ((await PushManager.checkPushNotification()) == false) {
        Get.offAndToNamed('/main');
      }
    } else {
      Fluttertoast.showToast(
        msg: 'The permission was not granted regarding push notifications.',
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Widgets.pageTitle('Tree vally Chat')),
          ],
        ),
        actions: const [],
      ),
      body: isLoginUserId != null
          ? isLoginUserId!
              ? Container()
              : _loginBox()
          : Container(),
    );
  }

  Widget _loginBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textEditingController,
                  style: const TextStyle(color: Colors.white),
                  // Set text color to white
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.0),
                      borderSide: const BorderSide(color: Colors.purple),
                    ),
                    hintText: 'User ID',
                    hintStyle: const TextStyle(
                      color: Colors.white30,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () async {
                          if (textEditingController.value.text.isEmpty) return;
                          _login(textEditingController.value.text);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.pink,
                          ),
                          child: const Icon(Icons.login,color: Colors.white,),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
          if (!kIsWeb) const SizedBox(width: 8.0),
          if (!kIsWeb)
            Row(
              children: [
                Checkbox(
                  value: useCollectionCaching,
                  onChanged: (value) async {
                    if (value != null) {
                      if (await AppPrefs().setUseCollectionCaching(value)) {
                        setState(() => useCollectionCaching = value);
                      }
                    }
                  },
                ),
                const Expanded(
                  child: Text('Remember me',style: TextStyle(color: Colors.white54),),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
