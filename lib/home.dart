import 'dart:convert';

import 'package:absen/simpan.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'model/home-response.dart';
import 'package:http/http.dart' as myHttp;

class home extends StatefulWidget {
  const home({Key? key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _name, _token;
  HomeResponse? homeResponse;
  Datum? hariIni;
  List<Datum> riwayat = [];
  Color customColor = Color.fromARGB(255, 218, 222, 241);

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
  }

  Future getData() async {
    final Map<String, String> headres = {
      'Authorization': 'Bearer ' + await _token
    };
    var response = await myHttp.get(
        Uri.parse('http://10.0.2.2:8000/api/get-presensi'),
        headers: headres);
    homeResponse = HomeResponse.fromJson(json.decode(response.body));
    riwayat.clear();
    homeResponse!.data.forEach((element) {
      if (element.isHariIni) {
        hariIni = element;
      } else {
        riwayat.add(element);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: customColor,
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return SafeArea(
                child: Center(
                  // Widget Center ditambahkan di sini
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Memastikan bahwa Column berada di tengah secara horizontal
                    children: [
                      FutureBuilder(
                          future: _name,
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else {
                              if (snapshot.hasData) {
                                return Text(
                                  snapshot.data!,
                                  style: TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w900),
                                );
                              } else {
                                return Text("-");
                              }
                            }
                          }),
                      SizedBox(height: 20),
                      Container(
                        width: 400,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 218, 236, 241),
                          borderRadius: BorderRadius.circular(20.0),
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
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(hariIni?.tanggal ?? '-',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16)),
                              SizedBox(height: 30),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(hariIni?.masuk ?? '-',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16)),
                                      Text("Masuk",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(hariIni?.pulang ?? '-',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16)),
                                      Text("Keluar",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Riwayat Presensi",
                        style: TextStyle(
                            fontSize: 13.0, fontWeight: FontWeight.w900),
                      ),
                      // Card Widgets
                      Expanded(
                        child: ListView.builder(
                          itemCount: riwayat.length,
                          itemBuilder: (context, index) => Card(
                             color: Color.fromARGB(255, 218, 236, 241),
                            child: ListTile(
                              leading: Text(riwayat[index].tanggal),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(riwayat[index].masuk,
                                          style: TextStyle(fontSize: 16)),
                                      Text("Masuk",
                                          style: TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                  SizedBox(width: 20),
                                  Column(
                                    children: [
                                      Text(riwayat[index].pulang,
                                          style: TextStyle(fontSize: 16)),
                                      Text("Pulang",
                                          style: TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Card Widgets (Tambahkan lebih banyak di sini jika diperlukan)
                    ],
                  ),
                ),
              );
            }
          }),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Define a circular shape
          border: Border.all(
              color: Colors.transparent,
              width: 3.0), // Define the border color and width
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => simpan()))
                .then((value) {
              setState(() {});
            });
          },
          child: Icon(Icons.add, color: Colors.black),
          backgroundColor: Colors.white, // Set the background color to white
        ),
      ),
    );
  }
}
