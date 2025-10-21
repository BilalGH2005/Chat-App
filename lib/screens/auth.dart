import 'dart:io';

import 'package:chat_practice/util/loading_dialog_util.dart';
import 'package:chat_practice/util/snackbar_util.dart';
import 'package:chat_practice/widgets/profile_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthScreen extends StatefulWidget {
  final void Function(bool hasSignedUp, String username, File? selectedImage)
  onSignUp;
  const AuthScreen({required this.onSignUp, super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // This boolean is used to show different UI components when the user is signing up
  var _isLogin = true;
  // This is the global key for the current form widget
  final _formKey = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredUsername = '';
  var _enteredPassword = '';
  File? _selectedImage;

  void submitAuthentication() async {
    if (!_formKey.currentState!.validate()) {
      SnackbarUtil.showErrorSnacbar(context, 'Please fill in the form');
      return;
    }
    // If the previous check was met, the following code will never excute
    _formKey.currentState!.save();
    final firebaseAuth = FirebaseAuth.instance;
    LoadingDialogUtil.showLoadingDialog(context);
    try {
      if (_isLogin) {
        await firebaseAuth.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        if (_selectedImage != null) {
          await firebaseAuth.createUserWithEmailAndPassword(
            email: _enteredEmail,
            password: _enteredPassword,
          );
          widget.onSignUp(true, _enteredUsername, _selectedImage!);
        } else {
          SnackbarUtil.showErrorSnacbar(context, 'You must choose an image');
        }
      }
    } on FirebaseAuthException catch (authException) {
      SnackbarUtil.showErrorSnacbar(context, authException.message!);
    } catch (exception) {
      SnackbarUtil.showErrorSnacbar(context, 'An error occurred');
    } finally {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/globe.svg',
                    width: 44,
                    height: 44,
                  ),
                  SizedBox(width: 24),
                  Text(
                    'Global Chat',
                    style: TextStyle(
                      color: const Color(0xFFFAF9FB),
                      fontFamily: 'Poppins',
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Card(
                color: const Color(0xFF2F2B33),
                margin: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 16,
                        right: 16,
                        left: 16,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text(
                              _isLogin ? 'Sign in' : 'Sign up',
                              style: TextStyle(
                                color: Color(0xFFFAF9FB),
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              /*
                              The key is used to preserve the entered text when
                              the user switches from login to signup and vice versa
                              */
                              key: const ValueKey('email'),
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 20,
                                ),
                                fillColor: const Color(0xFF423D47),
                                filled: true,
                                hintText: 'Email',
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xA6DFDCE1),
                                ),
                              ),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFF3F1F6),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().length < 3 ||
                                    !value.contains('@')) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _enteredEmail = newValue!;
                              },
                            ),
                            if (!_isLogin) const SizedBox(height: 10),
                            if (!_isLogin)
                              TextFormField(
                                /*
                                The key is used to preserve the entered text when
                                the user switches from login to signup and vice versa
                                */
                                key: const ValueKey('username'),
                                textInputAction: TextInputAction.next,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFF3F1F6),
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 20,
                                  ),
                                  fillColor: const Color(0xFF423D47),
                                  filled: true,
                                  hintText: 'Username',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xA6DFDCE1),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 3 ||
                                      value.trim().length > 20) {
                                    return 'Username must be 3-20 characters';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  _enteredUsername = newValue!;
                                },
                              ),
                            const SizedBox(height: 8),
                            TextFormField(
                              /*
                              The key is used to preserve the entered text when
                              the user switches from login to signup and vice versa
                              */
                              key: const ValueKey('password'),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => submitAuthentication(),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFFF3F1F6),
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 20,
                                ),
                                fillColor: const Color(0xFF423D47),
                                filled: true,
                                hintText: 'Password',
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xA6DFDCE1),
                                ),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().length < 8 ||
                                    value.trim().length > 30) {
                                  return 'Password must be 8-30 characters';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _enteredPassword = newValue!;
                              },
                            ),
                            if (!_isLogin) ...[
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  ProfilePicker(
                                    onImagePick:
                                        (selectedImage) =>
                                            _selectedImage = selectedImage,
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            InkWell(
                              borderRadius: BorderRadius.circular(360),
                              onTap: submitAuthentication,
                              child: Ink(
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 115, 96, 172),
                                  borderRadius: BorderRadius.circular(360),
                                ),
                                child: Align(
                                  child: Text(
                                    _isLogin ? 'Login' : 'Signup',
                                    style: TextStyle(
                                      color: Color(0xFFF4F1F6),
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: _isLogin ? 'Sign up' : 'Sign in',
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                        255,
                                        115,
                                        96,
                                        172,
                                      ),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      decoration: TextDecoration.underline,
                                      decorationThickness: 2,
                                      decorationColor: const Color.fromARGB(
                                        255,
                                        115,
                                        96,
                                        172,
                                      ),
                                      fontFamily: 'Poppins',
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            setState(() {
                                              _isLogin = !_isLogin;
                                            });
                                          },
                                  ),
                                  TextSpan(
                                    text:
                                        _isLogin
                                            ? ' if you don\'t have an account'
                                            : ' if you have an account',
                                    style: TextStyle(
                                      color: const Color(0x80FAF9FB),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Poppins',
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            setState(() {
                                              _isLogin = !_isLogin;
                                            });
                                          },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
