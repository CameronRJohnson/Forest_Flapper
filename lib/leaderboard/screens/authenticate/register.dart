import 'package:flutter/material.dart';
import 'package:jungle_jumper/home/main_menu.dart';
import 'package:jungle_jumper/leaderboard/services/auth.dart';
import 'package:jungle_jumper/leaderboard/shared/costs.dart';
import 'package:jungle_jumper/leaderboard/shared/loadings.dart';
import 'package:jungle_jumper/leaderboard/shared/transition.dart';

class Register extends StatefulWidget {
  final Function? toggleView;

  const Register({super.key, this.toggleView});

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

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
                          'Register Account',
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width / 18,
                              color: Colors.white),
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
                                      onChanged: (val) {
                                        if (mounted) {
                                          setState(() => email = val);
                                        }
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
                                      onChanged: (val) {
                                        if (mounted) {
                                          setState(() => password = val);
                                        }
                                      },
                                      obscureText: true,
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight / 38.0,
                                  ),
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
                                      SizedBox(width: screenWidth / 40),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(1.0)),
                                            backgroundColor: Colors.white),
                                        child: Text(
                                          "Register",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: screenWidth / 40),
                                        ),
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            if (mounted) {
                                              setState(() {
                                                loading = true;
                                              });
                                            }
                                            dynamic result = await _auth
                                                .registerWithEmailAndPassword(
                                                    email, password);
                                            if (result == null) {
                                              if (mounted) {
                                                setState(() {
                                                  error =
                                                      "Please Enter A Valid Email";
                                                  loading = false;
                                                });
                                              }
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
                                        'Have An Account Already?',
                                        style: TextStyle(color: Colors.white),
                                      )),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom: screenHeight / 38.0),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [],
                                    ),
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

  @override
  void dispose() {
    super.dispose();
  }
}
