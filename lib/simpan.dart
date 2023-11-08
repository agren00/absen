import 'dart:convert';
import 'package:absen/model/home-response.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:http/http.dart ' as myHttp;
import 'model/save-presensi-response.dart';

class simpan extends StatefulWidget {
  const simpan({super.key});

  @override
  State<simpan> createState() => _simpanState();
}

class _simpanState extends State<simpan> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _token;
  HomeResponse? homeResponseModel;
  Datum? hariIni;
  List<Datum> riwayat = [];
 Color customColor = Color.fromARGB(255, 218, 222, 241);
  void initState() {
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });
  }

  Future<LocationData?> _currenctlocation() async {
    bool serviceEnable;
    PermissionStatus permisssiongranted;

    Location location = new Location();
    // print("coding :tengah");
    serviceEnable = await location.serviceEnabled();

    if (!serviceEnable) {
      serviceEnable = await location.requestService();
      if (!serviceEnable) {
        return null;
      }
    }

    permisssiongranted = await location.hasPermission();

    if (permisssiongranted == PermissionStatus.denied) {
      permisssiongranted = await location.requestPermission();
      if (permisssiongranted != PermissionStatus.granted) {
        return null;
      }
    }

    return await location.getLocation();
  }

  Future savePresensi(latitude, longitude) async {
    SavePresensiResponse savePresensiResponse;
    Map<String, String> body = {
      "latitude": latitude.toString(),
      "longitude": longitude.toString()
    };

    Map<String, String> headers = {'Authorization': 'Bearer ' + await _token};
    
    var response = await myHttp.post(
        Uri.parse('http://10.0.2.2:8000/api/save-presensi'),
        body: body,
        headers: headers);

    savePresensiResponse =
        SavePresensiResponse.fromJson(json.decode(response.body));

    if (savePresensiResponse.success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sukses simpan Presensi')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal simpan Presensi')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("presensi"),
      ),
       backgroundColor:customColor,
      body: FutureBuilder<LocationData?>(
          future: _currenctlocation(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              final LocationData currenctlocation = snapshot.data;
              print("coding :" +
                  currenctlocation.altitude.toString() +
                  " | " +
                  currenctlocation.longitude.toString());
              return SafeArea(
                  child: Column(
                children: [
                  Container(
                    height: 300,
                    child: SfMaps(
                      layers: [
                        MapTileLayer(
                          initialFocalLatLng: MapLatLng(
                              currenctlocation.latitude!,
                              currenctlocation.longitude!),
                          initialZoomLevel: 15,
                          initialMarkersCount: 1,
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          markerBuilder: (BuildContext context, int index) {
                            return MapMarker(
                              latitude: currenctlocation.longitude!,
                              longitude: currenctlocation.longitude!,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 40.0),
                  ElevatedButton(
                    onPressed: () {
                      savePresensi(currenctlocation.latitude,
                          currenctlocation.longitude);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFEFF3F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      shadowColor: Color.fromARGB(255, 180, 171, 182),
                      elevation: 8,
                    ),
                    child: Container(
                      height: 50,
                      width: 150,
                      child: Center(
                        child: Text(
                          "Simpan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
