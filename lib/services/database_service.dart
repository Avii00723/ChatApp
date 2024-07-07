import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_chatapp/Model/chat.dart';
import 'package:firebase_chatapp/Model/message.dart';
import 'package:firebase_chatapp/Model/user_profile.dart';
import 'package:firebase_chatapp/services/auth_services.dart';
import 'package:firebase_chatapp/utils.dart';
import 'package:get_it/get_it.dart';

class DatabaseService {
  final GetIt _getIt = GetIt.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late AuthServices _authServices;
  CollectionReference? _usersCollection;
  CollectionReference? _chatsCollection;
  DatabaseService() {
    _authServices = _getIt.get<AuthServices>();
    _setupCollectionReferences();
  }

  void _setupCollectionReferences() {
    _usersCollection =
        _firebaseFirestore.collection('users').withConverter<UserProfile>(
              fromFirestore: (snapshots, _) =>
                  UserProfile.fromJson(snapshots.data()!),
              toFirestore: (userProfile, _) => userProfile.toJson(),
            );
    _chatsCollection=_firebaseFirestore.collection('chats').withConverter<Chat>(fromFirestore: (snapshots,_)=>Chat.fromJson(snapshots.data()!),toFirestore: (chat,_)=>chat.toJson());
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await _usersCollection?.doc(userProfile.uid).set(userProfile);
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _usersCollection
        ?.where("uid", isNotEqualTo: _authServices.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExists(String uid1,String uid2) async{
    String chatID=generateChatID(uid1: uid1, uid2: uid2);
    final result=await _chatsCollection?.doc(chatID).get();
    if(result!=null){
      return result.exists;
    }
    return false;
  }
  Future<void> createNewChat(String uid1,String uid2) async{
    String chatID=generateChatID(uid1: uid1, uid2: uid2);
    final docRef=_chatsCollection!.doc(chatID);
    final chat=Chat(id: chatID, participants:[uid1,uid2],
        messages: [],);
    await docRef.set(chat);
  }
  Future<void> sendChatMessage(String uid1,String uid2,Message message)async{
    String chatID=generateChatID(uid1: uid1, uid2: uid2);
    final docRef=_chatsCollection!.doc(chatID);
    await docRef.update({
      "messages":FieldValue.arrayUnion([message.toJson(),])
    });
  }
  Stream<DocumentSnapshot> getChatData(String uid1,String uid2){
    String chatID=generateChatID(uid1: uid1, uid2: uid2);
    return _chatsCollection?.doc(chatID).snapshots()
    as Stream<DocumentSnapshot<Chat>>;
  }
}
