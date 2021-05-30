import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:openreader/page/books.dart';
import 'package:openreader/server/auth.dart';
import 'package:openreader/widget/buttons.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScrenState createState() => _LoginScrenState();
}

class _LoginScrenState extends State<LoginScreen> {
  var _hasAccount = false;
  var _googleSignInLoading = false;
  var _mainButtonLoading = false;
  String? _signInError;

  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late Future<FirebaseApp> _firebaseFuture;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _firebaseFuture = Authentication.initializeFirebase();

    _firebaseFuture.then((firebase) {
      var user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        _finishLogin(context, user);
      }
    });
  }

  void _switchLoginMode() {
    if (_mainButtonLoading || _googleSignInLoading) return;

    setState(() {
      _hasAccount = !_hasAccount;
      _signInError = null;
    });
  }

  void _finishLogin(BuildContext context, User user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => new BookListScreen(user: user),
      ),
    );
  }

  void _logInOrCreateAccount(BuildContext context, {ignoreBasicErrors = false}) async {
    if (_mainButtonLoading || _googleSignInLoading) return;

    var email = _emailController.value.text;
    var password = _passwordController.value.text;

    var emailEmpty = email == "";
    var passwordEmpty = password == "";

    if (ignoreBasicErrors && (emailEmpty || passwordEmpty)) {
      setState(() {
        _mainButtonLoading = false;
      });
      return;
    }

    setState(() {
      _mainButtonLoading = true;
      _signInError = null;
    });

    AuthenticationResult res;

    if (emailEmpty) {
      res = AuthenticationResult(error: "An email address is required");
    } else if (passwordEmpty) {
      res = AuthenticationResult(error: "Your password cannot be left empty");
    } else if (_hasAccount)
      res = await Authentication.signInWithEmail(email: email, password: password);
    else
      res = await Authentication.signUpWithEmail(email: email, password: password);

    if (res.error != null) {
      setState(() {
        _mainButtonLoading = false;
        _signInError = res.error;
      });
      return;
    } else if (res.user != null) {
      _finishLogin(context, res.user!);
      return;
    }

    setState(() {
      _mainButtonLoading = false;
    });
  }

  void _signInWithGoogle(BuildContext context) async {
    if (_mainButtonLoading || _googleSignInLoading) return;

    setState(() {
      _googleSignInLoading = true;
      _signInError = null;
    });

    AuthenticationResult res = await Authentication.signInWithGoogle();

    if (res.error != null) {
      setState(() {
        _googleSignInLoading = false;
        _signInError = res.error;
      });
      return;
    } else if (res.user != null) {
      _finishLogin(context, res.user!);
      return;
    }

    setState(() {
      _googleSignInLoading = false;
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
                  child: FutureBuilder(
                    future: _firebaseFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Serious Internal Error",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              Container(height: 5),
                              Text(
                                snapshot.error.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Container(height: 10),
                              Text(
                                snapshot.stackTrace.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.connectionState != ConnectionState.done || FirebaseAuth.instance.currentUser != null) {
                        return CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        );
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: MediaQuery.of(context).padding.top + 40),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 3),
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
                                        _signInError == null
                                            ? Text(
                                                _hasAccount ? "Enter your email and password below to access your bookshelf" : "Create a free account below to start reading",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Text(
                                                _signInError!,
                                                style: TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 20,
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                  Container(height: 30),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 3),
                                    child: Text(
                                      "Email",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Container(height: 2),
                                  Container(
                                    child: TextFormField(
                                      controller: _emailController,
                                      autofillHints: [AutofillHints.email, AutofillHints.username],
                                      keyboardType: TextInputType.emailAddress,
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
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                                      ),
                                    ),
                                  ),
                                  Container(height: 10),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 3),
                                    child: Text(
                                      "Password",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Container(height: 2),
                                  Container(
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      onFieldSubmitted: (_) => _logInOrCreateAccount(context, ignoreBasicErrors: true),
                                      autofillHints: [AutofillHints.password],
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
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                                      ),
                                    ),
                                  ),
                                  Container(height: 20),
                                  _mainButtonLoading
                                      ? Container(
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator(
                                            color: Colors.lightGreen,
                                          ),
                                        )
                                      : GradientButton(
                                          onPressed: () => _logInOrCreateAccount(context),
                                          colors: [Colors.green, Colors.lightGreen],
                                          child: Container(
                                            height: 50,
                                            alignment: Alignment.center,
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
                                  _googleSignInLoading
                                      ? Container(
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        )
                                      : GradientButton(
                                          onPressed: () => _signInWithGoogle(context),
                                          child: Container(
                                            alignment: Alignment.center,
                                            height: 50,
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
                                        ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                width: double.infinity,
                                padding: EdgeInsets.all(15),
                                child: RichText(
                                  text: TextSpan(
                                    text: "By ${_hasAccount ? "logging in" : "signing up"}, you agree to our ",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: "Terms & Conditions",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(text: "."),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(height: 1, color: Colors.white.withOpacity(0.7)),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.black.withOpacity(0.1),
                                  primary: Colors.white
                                ),
                                onPressed: _switchLoginMode,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                                  child: RichText(
                                    text: TextSpan(
                                      text: _hasAccount ? "Don't have an account? " : "Already have an account? ",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
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
                      );
                    },
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
