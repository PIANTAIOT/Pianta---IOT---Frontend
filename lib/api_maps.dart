import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pianta/modelmaps.dart';

const baseUrl = "http://127.0.0.1:8000";

Future<Locationes?> getLocationes(String token) async {
  var url = Uri.parse("$baseUrl/user/project/"); // Actualiza la URL a la ruta correspondiente para obtener la ubicación del proyecto
  var res = await http.get(url, headers: {
    'Authorization': 'Token $token',
  });
  if (res.statusCode == 200) {
    var json = jsonDecode(res.body);
    Locationes location = Locationes.fromJson(json);
    return location;
  } else {
    return null;
  }
}

Future<String?> getProjectLocation(String token) async {
  final Locationes? location = await getLocationes(token);
  return location?.locationes;
}



Future<LocationeDevice?> getDeviceLocationes(String token) async {
  var url = Uri.parse("$baseUrl/user/devices/");
  var res = await http.get(url, headers: {
    'Authorization': 'Token $token',
  });
  if (res.statusCode == 200) {
    var json = jsonDecode(res.body);
    LocationeDevice location = LocationeDevice.fromJson(json);
    return location;
  } else {
    return null;
  }
}

Future<String?> getDeviceLocation(String token) async {
  final location = await getDeviceLocationes(token);
  return location?.location;
}