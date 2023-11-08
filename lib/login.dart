import 'dart:convert';

import 'package:absen/home.dart';
import 'package:absen/simpan.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;

import 'model/login-response.dart';

class login extends StatefulWidget {
  const login({Key? key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late Future<String> _name, _token;
  bool isPasswordVisible = false;
  Color customColor = Color.fromARGB(255, 218, 222, 241);// Gunakan kode warna hexadecimal di sini

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
    checkToken(_token, _name);
  }

  checkToken(token, name) async {
    String tokenStr = await token;
    String? nameStr = await name;
    if (tokenStr != "" && nameStr != "") {
      Future.delayed(Duration(seconds: 1), () async {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => simpan()))
            .then((value) {
          setState(() {});
        });
      });
    }
  }

  Future login(email, password) async {
    LoginResponse? loginResponse;
    Map<String, String> body = {"email": email, "password": password};
    var response = await myHttp
        .post(Uri.parse('http://10.0.2.2:8000/api/login'), body: body);
    if (response.statusCode == 401) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Email atau password salah")));
    } else {
      loginResponse = LoginResponse.fromJson(json.decode(response.body));
      print('HASIL ' + response.body);
      saveUser(loginResponse.data.token, loginResponse.data.name);
    }
  }

  Future saveUser(token, name) async {
    try {
      print("LEWAT SINI " + token + " | " + name);
      final SharedPreferences pref = await _prefs;
      pref.setString("name", name);
      pref.setString("token", token);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => home()))
          .then((value) {
        setState(() {});
      });
    } catch (err) {
      print('ERROR :' + err.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   backgroundColor:customColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Welcome"),
            Text(
              "Sign In",
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 40.0),
            Text("Email"),
            SizedBox(height: 20.0),
            Container(
              width: 300,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 218, 236, 241),
                borderRadius: BorderRadius.circular(100.0),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    offset: Offset(-1, 10),
                    blurRadius: 10.7,
                    spreadRadius: 8.0,
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(255, 254, 255, 0.875),
                    offset: Offset(-5, -5),
                    blurRadius: 5.2,
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Email",
                ),
              ),
            ),
            SizedBox(height: 15.0),
            Text("Password"),
            SizedBox(height: 20.0),
            Container(
              width: 300,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 218, 236, 241),
                borderRadius: BorderRadius.circular(100.0),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    offset: Offset(-1, 10),
                    blurRadius: 10.7,
                    spreadRadius: 8.0,
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(255, 254, 255, 0.875),
                    offset: Offset(-5, -5),
                    blurRadius: 5.2,
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              child: TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 40.0),
          ElevatedButton(
              onPressed: () {
                login(emailController.text, passwordController.text);
              },
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 218, 236, 241),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                shadowColor: Color.fromARGB(255, 246, 246, 247),
                elevation: 15,
              ),
              child: Container(
                height: 50,
                width: 150,
                child: Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class Login {}
