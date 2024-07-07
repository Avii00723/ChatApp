import 'dart:io';

import 'package:firebase_chatapp/Model/user_profile.dart';
import 'package:firebase_chatapp/const.dart';
import 'package:firebase_chatapp/services/alert_service.dart';
import 'package:firebase_chatapp/services/auth_services.dart';
import 'package:firebase_chatapp/services/database_service.dart';
import 'package:firebase_chatapp/services/media_service.dart';
import 'package:firebase_chatapp/services/navigation_service.dart';
import 'package:firebase_chatapp/services/storage_service.dart';
import 'package:firebase_chatapp/widgets/custom_form_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? name,email,password;
  final GetIt _getIt=GetIt.instance;
  late AuthServices _authServices;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late StorageService _storageService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  final GlobalKey<FormState> _registerKey=GlobalKey();
  File? selectedImage;
  bool isLoading=false;
  @override
  void initState() {
    super.initState();
    _alertService=_getIt.get<AlertService>();
    _authServices=_getIt.get<AuthServices>();
    _mediaService=_getIt.get<MediaService>();
    _navigationService=_getIt.get<NavigationService>();
    _storageService=_getIt.get<StorageService>();
    _databaseService=_getIt.get<DatabaseService>();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
        child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 20.0,
      ),
      child: Column(
        children: [
          _headerText(),
          if(!isLoading) _registerForm(),
          if(!isLoading) _loginAccountLink(),
          if(isLoading) const Expanded(child: Center(
            child: CircularProgressIndicator(),
          ))
        ],
      ),
    ));
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            "Let's get going",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            "Register an account using the form below",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerForm() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.60,
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.05,
        ),
        child: Form(
          key: _registerKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              _pfpSelectionFiled(),
              CustomFormField(
                hintText: "Name",
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.1,
                validationRegExp: NAME_VALIDATION_REGEX,
                onSaved: (value){
                  setState(() {
                    name=value;
                  });
                },
              ),
              CustomFormField(
                hintText: "Email",
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.1,
                validationRegExp: EMAIL_VALIDATION_REGEX,
                onSaved: (value){
                  setState(() {
                    email=value;
                  });
                },
              ),
              CustomFormField(
                hintText: "Password",
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.1,
                validationRegExp: PASSWORD_VALIDATION_REGEX,
                obscureText: true,
                onSaved: (value){
                  setState(() {
                    password=value;
                  });
                },
              ),
              _registerButton(),
            ],
          ),
        ));
  }

  Widget _pfpSelectionFiled() {
    return GestureDetector(
      onTap: () async {
        File? file=await _mediaService.getImageFromGallery();
        if(file!=null){
          setState(() {
            selectedImage=file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }
  Widget _registerButton(){
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        onPressed: () async {
          setState(() {
            isLoading=true;
          });
          try{
            if((_registerKey.currentState?.validate() ?? false)&& selectedImage!=null ){
              _registerKey.currentState?.save();
              bool result=await _authServices.signup(email!, password!);
              if(result){
                String? pfpUrl=await _storageService.uploadUserPfp(file: selectedImage!, uid: _authServices.user!.uid!);
                if(pfpUrl!=null){
                  await _databaseService.createUserProfile(
                      userProfile: UserProfile(
                          uid: _authServices.user!.uid,
                          name: name,
                          pfpURL: pfpUrl));
                  _alertService.showToast(text: "User Registered Successfully!",icon: Icons.check
                  );
                  _navigationService.goback();
                  _navigationService.pushReplacementNamed('/home');
                }
                else{
                  throw Exception("Unable to register user");
                }
              }
              else{
                throw Exception("Unable to register user");
              }
             
            }
          }
          catch(e){
            if (kDebugMode) {
              print(e);
              _alertService.showToast(text: "Failed to register Please try again",icon: Icons.error);
            }
          }
          setState(() {
            isLoading=false;
          });
        },
        color: Theme.of(context).colorScheme.primary,
        child: Text(
          "Register"
              ,style: TextStyle(
          color: Colors.white
        ),
        ),
      ),
    );
  }
  Widget _loginAccountLink() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text("Already have an Account "),
          GestureDetector(
            onTap: (){
              _navigationService.goback();
            },
            child: Text(
              "Login",
              style: TextStyle(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
