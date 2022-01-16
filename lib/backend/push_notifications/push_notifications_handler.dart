import 'dart:async';
import 'dart:convert';

import 'serialization_util.dart';
import '../backend.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../login/login_widget.dart';
import '../../create_account/create_account_widget.dart';
import '../../create_dog_profile/create_dog_profile_widget.dart';
import '../../create_your_profile/create_your_profile_widget.dart';
import '../../forgot_password/forgot_password_widget.dart';
import '../../create_post/create_post_widget.dart';
import '../../create_story/create_story_widget.dart';
import '../../post_details/post_details_widget.dart';
import '../../story_details/story_details_widget.dart';
import '../../edit_settings/edit_settings_widget.dart';
import '../../edit_user_profile/edit_user_profile_widget.dart';
import '../../edit_dog_profile/edit_dog_profile_widget.dart';
import '../../change_password/change_password_widget.dart';
import '../../create_dog_profile_new/create_dog_profile_new_widget.dart';
import '../../view_profile_page_other/view_profile_page_other_widget.dart';
import '../../chat_page/chat_page_widget.dart';
import '../../add_chat_users/add_chat_users_widget.dart';
import '../../create_group_chat/create_group_chat_widget.dart';

class PushNotificationsHandler extends StatefulWidget {
  const PushNotificationsHandler(
      {Key key, this.handlePushNotification, this.child})
      : super(key: key);

  final Function(BuildContext) handlePushNotification;
  final Widget child;

  @override
  _PushNotificationsHandlerState createState() =>
      _PushNotificationsHandlerState();
}

class _PushNotificationsHandlerState extends State<PushNotificationsHandler> {
  bool _loading = false;

  Future handleOpenedPushNotification() async {
    final notification = await FirebaseMessaging.instance.getInitialMessage();
    if (notification != null) {
      await _handlePushNotification(notification);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handlePushNotification);
  }

  Future _handlePushNotification(RemoteMessage message) async {
    setState(() => _loading = true);
    try {
      final initialPageName = message.data['initialPageName'] as String;
      final initialParameterData = getInitialParameterData(message.data);
      final pageBuilder = pageBuilderMap[initialPageName];
      if (pageBuilder != null) {
        final page = await pageBuilder(initialParameterData);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    handleOpenedPushNotification();
  }

  @override
  Widget build(BuildContext context) => _loading
      ? Container(
          color: Colors.transparent,
          child: Center(
            child: Builder(
              builder: (context) => Image.asset(
                'assets/images/Sniff_0.0_Splash@2x.png',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 1,
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
      : widget.child;
}

final pageBuilderMap = <String, Future<Widget> Function(Map<String, dynamic>)>{
  'login': (data) async => LoginWidget(),
  'createAccount': (data) async => CreateAccountWidget(),
  'createDogProfile': (data) async => CreateDogProfileWidget(),
  'createYourProfile': (data) async => CreateYourProfileWidget(),
  'forgotPassword': (data) async => ForgotPasswordWidget(),
  'profilePage': (data) async => NavBarPage(initialPage: 'ProfilePageWidget'),
  'createPost': (data) async => CreatePostWidget(),
  'createStory': (data) async => CreateStoryWidget(),
  'postDetails': (data) async => PostDetailsWidget(
        postReference: getParameter(data, 'postReference'),
        userRecord: await getDocumentParameter(
            data, 'userRecord', UsersRecord.serializer),
      ),
  'storyDetails': (data) async => StoryDetailsWidget(
        initialStoryIndex: getParameter(data, 'initialStoryIndex'),
      ),
  'editSettings': (data) async => EditSettingsWidget(),
  'editUserProfile': (data) async => EditUserProfileWidget(),
  'editDogProfile': (data) async => EditDogProfileWidget(
        dogProfile: await getDocumentParameter(
            data, 'dogProfile', DogsRecord.serializer),
      ),
  'changePassword': (data) async => ChangePasswordWidget(),
  'createDogProfile_New': (data) async => CreateDogProfileNewWidget(),
  'viewProfilePageOther': (data) async => ViewProfilePageOtherWidget(
        userDetails: await getDocumentParameter(
            data, 'userDetails', UsersRecord.serializer),
      ),
  'chatPage': (data) async => ChatPageWidget(
        chatUser: await getDocumentParameter(
            data, 'chatUser', UsersRecord.serializer),
        chatRef: getParameter(data, 'chatRef'),
      ),
  'allChatsPage': (data) async => NavBarPage(initialPage: 'AllChatsPageWidget'),
  'addChatUsers': (data) async => AddChatUsersWidget(
        chat: await getDocumentParameter(data, 'chat', ChatsRecord.serializer),
      ),
  'createGroupChat': (data) async => CreateGroupChatWidget(),
};

bool hasMatchingParameters(Map<String, dynamic> data, Set<String> params) =>
    params.any((param) => getParameter(data, param) != null);

Map<String, dynamic> getInitialParameterData(Map<String, dynamic> data) {
  try {
    final parameterDataStr = data['parameterData'];
    if (parameterDataStr == null ||
        parameterDataStr is! String ||
        parameterDataStr.isEmpty) {
      return {};
    }
    return jsonDecode(parameterDataStr) as Map<String, dynamic>;
  } catch (e) {
    print('Error parsing parameter data: $e');
    return {};
  }
}
