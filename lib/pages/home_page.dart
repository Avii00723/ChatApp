import 'package:firebase_chatapp/Model/user_profile.dart';
import 'package:firebase_chatapp/pages/chat_page.dart';
import 'package:firebase_chatapp/services/alert_service.dart';
import 'package:firebase_chatapp/services/auth_services.dart';
import 'package:firebase_chatapp/services/database_service.dart';
import 'package:firebase_chatapp/services/navigation_service.dart';
import 'package:firebase_chatapp/widgets/chat_tile.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt _getIt = GetIt.instance;
  late AuthServices _authServices;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _databaseService = _getIt.get<DatabaseService>();
    _authServices = _getIt.get<AuthServices>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Messages",
        ),
        actions: [
          IconButton(
              onPressed: () async {
                bool result = await _authServices.logout();
                if (result) {
                  _alertService.showToast(
                    text: " Successfully Logged Out!",
                    icon: Icons.check,
                  );
                  _navigationService.pushReplacementNamed("/login");
                }
              },
              icon: Icon(
                color: Colors.red,
                Icons.logout,
              )),
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: _chatsList(),
    ));
  }

  Widget _chatsList() {
    return StreamBuilder(
        stream: _databaseService.getUserProfiles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Unable to load data"),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            final users = snapshot.data!.docs;
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  UserProfile user = users[index].data();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ChatTile(
                        userProfile: user,
                        onTap: () async {
                          final chatExists =
                              await _databaseService.checkChatExists(
                                  _authServices.user!.uid, user.uid!);
                          if (!chatExists) {
                            await _databaseService.createNewChat(
                                _authServices.user!.uid, user.uid!);
                          }
                          _navigationService
                              .push(MaterialPageRoute(builder: (context) {
                            return ChatPage(
                              chatUser: user,
                            );
                          }));
                        }),
                  );
                });
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
