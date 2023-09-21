import 'package:flutter/material.dart';

void main() {
  runApp(project());
}

class project extends StatelessWidget {
  const project({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Text("LOGIN")),
              SizedBox(height: 20),
              Text("Email"),
              TextField(),
              Text("Password"),
              TextField(),
              SizedBox(height: 20),
              ElevatedButton(onPressed: () {}, child: Text("Masuk"))
            ],
          ),
        ),
      )),
    );
  }
}
//  ini halaman login yang di buat mercy //