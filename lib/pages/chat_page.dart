import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_chatapp/Model/chat.dart';
import 'package:firebase_chatapp/Model/message.dart';
import 'package:firebase_chatapp/Model/user_profile.dart';
import 'package:firebase_chatapp/services/auth_services.dart';
import 'package:firebase_chatapp/services/database_service.dart';
import 'package:firebase_chatapp/services/media_service.dart';
import 'package:firebase_chatapp/services/storage_service.dart';
import 'package:firebase_chatapp/utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;
  const ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;
  late AuthServices _authServices;
  late MediaService _mediaService;
  late StorageService _storageService;
  ChatUser? currentUser, otherUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _storageService = _getIt.get<StorageService>();
    _mediaService = _getIt.get<MediaService>();
    _authServices = _getIt.get<AuthServices>();
    _databaseService = _getIt.get<DatabaseService>();
    currentUser = ChatUser(
        id: _authServices.user!.uid,
        firstName: _authServices.user!.displayName);
    otherUser = ChatUser(
      id: widget.chatUser.uid!,
      firstName: widget.chatUser.name,
      profileImage: widget.chatUser.pfpURL,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chatUser.name!,
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
        stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
        builder: (context, snapshot) {
          Chat? chat = snapshot.data?.data() as Chat?;
          List<ChatMessage> messages = [];
          if (chat != null && chat.messages != null) {
            messages = _generateChatMessageList(
              chat.messages!,
            );
          }
          return DashChat(
            messageOptions: const MessageOptions(
              showOtherUsersAvatar: true,
              showTime: true,
            ),
            inputOptions: InputOptions(alwaysShowSend: true, trailing: [
              _mediaMessageButton(),
            ]),
            currentUser: currentUser!,
            onSend: _sendMessage,
            messages: messages,
          );
        });
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
            senderID: chatMessage.user.id,
            content: chatMessage.medias!.first.url,
            messageType: MessageType.Image,
            sentAt: Timestamp.fromDate(chatMessage.createdAt));
        await _databaseService.sendChatMessage(currentUser!.id, otherUser!
            .id, message);
      }
    } else {
      Message message = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
      await _databaseService.sendChatMessage(
          currentUser!.id, otherUser!.id, message);
    }
  }

  List<ChatMessage> _generateChatMessageList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if(m.messageType==MessageType.Image){
        return ChatMessage(user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
            medias: [
              ChatMedia(url: m.content!, fileName: "", type: MediaType.image)
            ],
            createdAt:  m.sentAt!.toDate());
      }
      else{
        return ChatMessage(
            user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
            text: m.content!,
            createdAt: m.sentAt!.toDate());
      }
    }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
      onPressed: () async {
        String chatID =
            generateChatID(uid1: currentUser!.id, uid2: otherUser!.id);
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          String? downloadURL = await _storageService.uplaodImageToChat(
              file: file, chatID: chatID);
          if (downloadURL != null) {
            ChatMessage chatMessage = ChatMessage(
                user: currentUser!,
                createdAt: DateTime.now(),
                medias: [
                  ChatMedia(
                      url: downloadURL, fileName: "", type: MediaType.image)
                ]);
            _sendMessage(chatMessage);
          }
        }
      },
      icon: Icon(Icons.image),
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
