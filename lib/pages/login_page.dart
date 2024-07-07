import 'package:firebase_chatapp/const.dart';
import 'package:firebase_chatapp/services/alert_service.dart';
import 'package:firebase_chatapp/services/auth_services.dart';
import 'package:firebase_chatapp/services/navigation_service.dart';
import 'package:firebase_chatapp/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GetIt _getIt=GetIt.instance;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();

  late AuthServices _authServices;
  late NavigationService _navigationService;
  late AlertService _alertService;
  String? password,email;
  @override
  void initState(){
    super.initState();
    _authServices=_getIt.get<AuthServices>();
    _navigationService=_getIt.get<NavigationService>();
    _alertService=_getIt<AlertService>();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(context, _loginFormKey), // Pass the BuildContext here
    );
  }


  Widget _buildUI(BuildContext context, Key loginFormKey) {
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 20.0,
        ),
        child: Column(
          children: [
            _headerText(),
            _loginForm(),
            _createAnAccountLink(),
          ],
        ),
      ),
    );
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            "Hi Welcome Back!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            "Hello again you've been missed",
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

  Widget _loginForm() {
    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height * 0.40,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery
            .of(context)
            .size
            .height * 0.05,
      ),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
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
            _loginButton(),
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: MaterialButton(
        color: Theme
            .of(context)
            .colorScheme
            .primary,
        child: Text(
          "Login",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        onPressed: () async {
          if (_loginFormKey.currentState?.validate() ?? false) {
            _loginFormKey.currentState?.save();
            bool result=await _authServices.login(email!, password!);
           if(result){
             _navigationService.pushReplacementNamed("/home");
           }
           else{
             _alertService.showToast(text: "Failed to login Please try again",icon: Icons.error);
           }
          }
        },
      ),
    );
  }

  Widget _createAnAccountLink() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text("Don't have an account? "),
          GestureDetector(
            onTap: (){
              _navigationService.pushNamed("/register");
            },
            child: Text(
              "Sign Up",
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