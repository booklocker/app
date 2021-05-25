import 'package:flutter/material.dart';
import 'package:openreader/widget/buttons.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScrenState createState() => _LoginScrenState();
}

class _LoginScrenState extends State<LoginScreen> {
  var _hasAccount = false;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  void switchLoginMode() {
    setState(() {
      _hasAccount = !_hasAccount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          child: LayoutBuilder(
            builder: (context, constraint) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraint.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top + 40),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Voltpaper",
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Container(height: 5),
                            Text(
                              _hasAccount ? "Enter your email and password below to access your bookshelf" : "Create a free account below to start reading",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            Container(height: 30),
                            Container(
                              child: TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: "Email",
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                                ),
                              ),
                            ),
                            Container(height: 10),
                            Container(
                              child: TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(5)),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: "Password",
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                                ),
                              ),
                            ),
                            Container(height: 20),
                            GradientButton(
                              onPressed: () {},
                              colors: [Colors.green, Colors.lightGreen],
                              child: Center(
                                child: Text(
                                  _hasAccount ? "Log In" : "Create Account",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Divider(
                                      thickness: 1,
                                      height: 20,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 5),
                                    child: Text(
                                      "OR",
                                      style: TextStyle(
                                        fontFamily: "Roboto",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15.0,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      thickness: 1,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GradientButton(
                              onPressed: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    "assets/images/google-logo.png",
                                    width: 25,
                                    height: 25,
                                  ),
                                  SizedBox(width: 24),
                                  Text("Sign in with Google"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: RichText(
                              text: TextSpan(text: "By ${_hasAccount ? "logging in" : "signing up"}, you agree to our ", children: <TextSpan>[
                                TextSpan(
                                  text: "Terms & Conditions",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: "."),
                              ]),
                            ),
                          ),
                          Divider(height: 1, color: Colors.white.withOpacity(0.7)),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.1),
                              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                            ),
                            onPressed: switchLoginMode,
                            child: Container(
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(
                                  text: _hasAccount ? "Don't have an account? " : "Already have an account? ",
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: _hasAccount ? "Sign up" : "Log in",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(text: "."),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).padding.bottom,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
