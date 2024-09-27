import 'package:flutter/material.dart';
import 'package:searchaholic/firebase_.dart'; // Ensure this file has the appropriate methods
import 'package:searchaholic/imports.dart';
import 'package:quickalert/quickalert.dart';
import 'package:email_otp/email_otp.dart';
import 'package:google_fonts/google_fonts.dart';

class Forget extends StatefulWidget {
  const Forget({super.key});

  @override
  _ForgetState createState() => _ForgetState();
}

class _ForgetState extends State<Forget> {
  bool otpVerified = false;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final otpController = TextEditingController();
  bool _isObscure = true;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void showAlert(String title, String text, {QuickAlertType type = QuickAlertType.error}) {
    QuickAlert.show(
      context: context,
      type: type,
      title: title,
      text: text,
    );
  }

  void sendOTP() async {
    EmailOTP myAuth = EmailOTP();
    myAuth.setConfig(
      appEmail: "Searchaholic@gmail.com",
      appName: "Searchaholic",
      userEmail: _email.text,
      otpLength: 4,
      otpType: OTPType.numeric,
    );

    var res = await myAuth.sendOTP(); // Call static method directly on class
    if (res) {
      showAlert('Success', 'OTP Successfully sent!', type: QuickAlertType.success);
    } else {
      showAlert('Error', 'Failed to send OTP.');
    }
  }

  void verifyOtp() async {
    var res = EmailOTP.verifyOTP(otp: otpController.text); // Call static method directly on class
    if (res) {
      setState(() {
        otpVerified = true;
      });
      showAlert('Success', 'OTP verified', type: QuickAlertType.success);
    } else {
      showAlert('Error', 'OTP was not verified');
    }
  }

  Future<bool> forgetPassword() async {
    // Ensure this method exists in your Flutter_api class
    return await Flutter_api().forgetPassword(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.02),
            width: MediaQuery.of(context).size.width * 0.5,
            color: Colors.white,
            child: Expanded(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.116,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          "Confirm Credentials",
                          style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.10),
                      width: MediaQuery.of(context).size.width * 0.37,
                      child: TextFormField(
                        controller: _email,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email Required';
                          RegExp regExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                          if (!regExp.hasMatch(value)) return 'Please enter a valid email address';
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: GoogleFonts.montserrat(fontSize: 15, color: Colors.grey[450]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.035),
                      width: MediaQuery.of(context).size.width * 0.37,
                      child: TextFormField(
                        obscureText: _isObscure,
                        controller: _password,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password required';
                          RegExp regExp = RegExp(r"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$");
                          if (!regExp.hasMatch(value)) return 'Please enter a valid password';
                          return null;
                        },
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                          hintText: "New Password",
                          hintStyle: GoogleFonts.montserrat(fontSize: 15, color: Colors.grey[450]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
                      width: MediaQuery.of(context).size.width * 0.20,
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: TextFormField(
                        controller: otpController,
                        decoration: InputDecoration(
                          hintText: "Enter OTP",
                          suffixIcon: TextButton(
                            child: const Text("Send OTP"),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                sendOTP();
                              }
                            },
                          ),
                          suffix: TextButton(
                            child: const Text("Verify"),
                            onPressed: () {
                              verifyOtp();
                            },
                          ),
                          hintStyle: GoogleFonts.montserrat(fontSize: 10, color: Colors.grey[450]),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    // Add other UI components as needed
                  ],
                ),
              ),
            ),
          ),
          // Right Side
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            color: const Color.fromRGBO(8, 92, 228, 1),
            child: Expanded(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.119,
                    margin: const EdgeInsets.only(top: 60),
                    child: Text(
                      "Change Password",
                      style: GoogleFonts.montserrat(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    color: const Color.fromRGBO(53, 108, 254, 1),
                    child: Image.asset(
                      'images/password_recover.jpg',
                      fit: BoxFit.contain,
                      height: MediaQuery.of(context).size.height * 0.5,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Text(
                      'SearchaHolic',
                      style: GoogleFonts.montserrat(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
