import 'package:flutter/material.dart';
import 'package:jungle_jumper/home/main_menu.dart';
import 'package:jungle_jumper/leaderboard/services/auth.dart';
import 'package:jungle_jumper/leaderboard/shared/costs.dart';
import 'package:jungle_jumper/leaderboard/shared/loadings.dart';
import 'package:jungle_jumper/leaderboard/shared/transition.dart';

class SignIn extends StatefulWidget {
  final Function? toggleView;

  const SignIn({super.key, this.toggleView});

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool resetSuccess = false;

  String email = "";
  String password = "";
  String error = "";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return loading
        ? const Loading()
        : Scaffold(
            backgroundColor: Colors.brown[100],
            body: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Background.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height / 7),
                        child: Text(
                          'Sign Into Account',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width / 25,
                        ),
                        child: Card(
                            color: Colors.green.shade800.withOpacity(0.8),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: screenHeight / 38.0,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width /
                                              15,
                                    ),
                                    child: TextFormField(
                                      decoration: textDecoration.copyWith(
                                          hintText: 'Email'),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter email';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        setState(() => email = value);
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight / 38.0,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width /
                                              15,
                                    ),
                                    child: TextFormField(
                                      decoration: textDecoration.copyWith(
                                          hintText: 'Password'),
                                      validator: (val) {
                                        if (val == null || val.length < 6) {
                                          return 'Password needs 6+ characters';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        setState(() => password = value);
                                      },
                                      obscureText: true,
                                    ),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        handlePasswordReset();
                                      },
                                      child: Text(
                                        resetSuccess
                                            ? 'Password reset email sent!'
                                            : 'Forgot your password?',
                                        style: TextStyle(
                                          color: resetSuccess
                                              ? Colors.green
                                              : Colors.white,
                                        ),
                                      )),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(1.0)),
                                            backgroundColor: Colors.white),
                                        child: Text(
                                          'Return To Game',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: screenWidth / 40),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pushReplacement(
                                            PageTransition(
                                              page: const MainMenu(),
                                              transitionType:
                                                  TransitionType.fade,
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(
                                        width: screenWidth / 40,
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(1.0)),
                                            backgroundColor: Colors.white),
                                        child: Text(
                                          "Sign In",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: screenWidth / 40),
                                        ),
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            setState(() {
                                              loading = true;
                                            });
                                            dynamic result = await _auth
                                                .signInWithEmailAndPassword(
                                                    email, password);
                                            if (result == null) {
                                              setState(() {
                                                error = "Incorrect Information";
                                                loading = false;
                                              });
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(
                                    error,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        widget.toggleView?.call();
                                      },
                                      child: const Text(
                                        'Do Not Have An Account?',
                                        style: TextStyle(color: Colors.white),
                                      )),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom: screenHeight / 38.0),
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  void handlePasswordReset() async {
    if (email.isEmpty) {
      setState(() {
        error = 'Please enter an email address.';
      });
      return;
    }

    try {
      await _auth.changePassword(email);
      setState(() {
        resetSuccess = true;
        error = '';
      });
    } catch (e) {
      setState(() {
        error = 'An error occurred while sending the reset email.';
        resetSuccess = false;
      });
    }
  }
}
